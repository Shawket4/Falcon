// ignore_for_file: prefer_const_constructors_in_immutables, import_of_legacy_library_into_null_safe, file_names, non_constant_identifier_names, use_build_context_synchronously

import 'dart:convert';
import 'package:falcon_driver_app/main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:lottie/lottie.dart';
import 'package:vertical_stepper/vertical_stepper.dart' as step;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

import 'Login.dart';

class DriverTripControls extends StatefulWidget {
  DriverTripControls(this.jwt, this.car, this.tripId, {Key? key})
      : super(key: key);
  final dynamic car;
  final String jwt;
  final int tripId;

  @override
  State<DriverTripControls> createState() => _DriverTripControlsState();
}

// Make Loading Screen
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Display lottie animation
        child: Lottie.asset(
          "lottie/SplashScreen.json",
          height: 200,
          width: 200,
        ),
      ),
    );
  }
}

class _DriverTripControlsState extends State<DriverTripControls> {
  List<step.Step> steps = [];
  // Current Date YYYY-MM-DD
  // final String currentDate = DateTime.now().toString().substring(0, 10);
  // Current Time HH:MM 12 hour format + AM/PM
  final String currentTime = intl.DateFormat('hh:mm a').format(DateTime.now());
  late BuildContext dialogContext;
  var isCompleted = false;
  final channel = WebSocketChannel.connect(
    Uri.parse('ws://$SERVER_IP:/ws'),
  );
  @override
  void initState() {
    var StepsJson = jsonDecode(widget.car["StepCompleteTime"]);
    if (StepsJson["DropOffPoints"][widget.car["NoOfDropOffPoints"] - 1][2] ==
        true) {
      isCompleted = true;
    }

    if (StepsJson["TruckLoad"][2] != false) {
      steps.add(
        step.Step(
          shimmer: false,
          title: "تحميل الشاحنة",
          iconStyle: Colors.green,
          content: Padding(
            padding: const EdgeInsets.only(right: 18.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                "${StepsJson["TruckLoad"][0]} تم تحميل الشاحنة من مستودع ${StepsJson["TruckLoad"][1]} الساعة",
                style: const TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w500,
                ),
                textDirection: TextDirection.ltr,
              ),
            ),
          ),
        ),
      );
    } else {
      steps.add(
        step.Step(
          shimmer: false,
          title: "تحميل الشاحنة",
          iconStyle: Colors.grey,
          content: Padding(
            padding: const EdgeInsets.only(right: 18.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Row(
                children: [
                  Text(
                    "تحميل الشاحنة من مستودع ${StepsJson["TruckLoad"][1]}",
                    style: const TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w500,
                    ),
                    textDirection: TextDirection.ltr,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    // Loop through the steps and add them to the list.
    for (int i = 0; i < widget.car["NoOfDropOffPoints"]; i++) {
      if (StepsJson["DropOffPoints"][i][2] != false) {
        steps.add(
          step.Step(
            shimmer: false,
            title: "تفريغ ${StepsJson["DropOffPoints"][i][1]}",
            iconStyle: Colors.green,
            content: Padding(
              padding: const EdgeInsets.only(right: 18.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "${StepsJson["DropOffPoints"][i][0]} تم التفريغ في ${StepsJson["DropOffPoints"][i][1]} الساعة",
                  style: const TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w500,
                  ),
                  textDirection: TextDirection.ltr,
                ),
              ),
            ),
          ),
        );
      } else {
        steps.add(
          step.Step(
            shimmer: false,
            title: "تفريغ ${StepsJson["DropOffPoints"][i][1]}",
            iconStyle: Colors.grey,
            content: const Padding(
              padding: EdgeInsets.only(right: 18.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "",
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w500,
                  ),
                  textDirection: TextDirection.ltr,
                ),
              ),
            ),
          ),
        );
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          // Logout Button
          IconButton(
            padding: const EdgeInsets.only(right: 15),
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              http.post(Uri.parse("$SERVER_IP/logout"), headers: {
                "Content-Type": "application/json",
                "Cookie": "jwt=${widget.jwt}",
              });
              storage.delete(key: "jwt");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
          ),
        ],
        title: const Text('تفاصيل النقلة'),
      ),
      body: content(),
    );
  }

  Widget content() {
    return ListView(
      children: <Widget>[
        Container(
          height: 350,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(50.0),
              bottomLeft: Radius.circular(50.0),
            ),
          ),
          child: Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Column(
                children: <Widget>[
                  Image.asset(
                    "assets/images/truck.jpeg",
                  ),
                  Text(
                    "Falcon Tracker",
                    style: GoogleFonts.josefinSans(
                      textStyle: const TextStyle(
                          fontSize: 32, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  Text(
                    widget.car["CarNoPlate"],
                    style: GoogleFonts.josefinSans(
                      textStyle: const TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  Text(
                    "${widget.car['DriverName']} : اسم السائق",
                    style: GoogleFonts.josefinSans(
                      textStyle: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body()
      ],
    );
  }

  Widget body() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            height: 35.0,
          ),
          const Padding(
            padding: EdgeInsets.only(right: 30.0),
            child: Text(
              "حالة النقلة",
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(
            height: 10.0,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: step.VerticalStepper(
                steps: steps,
                dashLength: 0,
              ),
            ),
          ),
          // Add Two Buttons To Continue And Cancel The Trip.
          const SizedBox(
            height: 20.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              isCompleted != true
                  ? GestureDetector(
                      onTap: () async {
                        // Show Loading Screen Until http Request is Completed.
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) {
                              dialogContext = context;
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: SizedBox(
                                  height: 400,
                                  width: double.infinity,
                                  child: Center(
                                    // Display lottie animation
                                    child: Lottie.asset(
                                      "lottie/SplashScreen.json",
                                      height: 200,
                                      width: 200,
                                    ),
                                  ),
                                ),
                              );
                            });
                        // Connect to websocket and send message
                        channel.sink.add("Refresh");
                        setState(() {});
                        await http
                            .post(
                              Uri.parse("$SERVER_IP/NextStep"),
                              headers: {
                                "Content-Type": "application/json",
                                "Cookie": "jwt=${widget.jwt}",
                              },
                              body: jsonEncode({
                                "Date":
                                    DateTime.now().toString().substring(0, 10),
                                "Time": currentTime,
                                "TripId": widget.tripId,
                              }),
                            )
                            .then(
                              (value) => {},
                            );
                        setState(() {
                          Navigator.pop(dialogContext);
                          // Rebuild Whole Page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MainWidget(),
                            ),
                          );
                        });
                      },
                      child: Container(
                        width: 160,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.green,
                        ),
                        child: const Center(
                          child: Text(
                            "الخطوة التالية",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: () async {
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) {
                              dialogContext = context;
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: SizedBox(
                                  height: 400,
                                  width: double.infinity,
                                  child: Center(
                                    // Display lottie animation
                                    child: Lottie.asset(
                                      "lottie/SplashScreen.json",
                                      height: 200,
                                      width: 200,
                                    ),
                                  ),
                                ),
                              );
                            });
                        channel.sink.add("Refresh");
                        await http.post(
                          Uri.parse("$SERVER_IP/CompleteTrip"),
                          headers: {
                            "Content-Type": "application/json",
                            "Cookie": "jwt=${widget.jwt}",
                          },
                          body: jsonEncode({
                            "Date": DateTime.now().toString().substring(0, 10),
                            "CarNoPlate": widget.car["CarNoPlate"],
                            "TripId": widget.tripId,
                            "DriverName": widget.car["DriverName"],
                          }),
                        );
                        setState(() {
                          Navigator.pop(dialogContext);
                          // Rebuild Whole Page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MainWidget(),
                            ),
                          );
                        });
                      },
                      child: Container(
                        width: 160,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.green,
                        ),
                        child: const Center(
                          child: Text(
                            "اتمام النقلة",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
              GestureDetector(
                onTap: () async {
                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        dialogContext = context;
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: SizedBox(
                            height: 400,
                            width: double.infinity,
                            child: Center(
                              // Display lottie animation
                              child: Lottie.asset(
                                "lottie/SplashScreen.json",
                                height: 200,
                                width: 200,
                              ),
                            ),
                          ),
                        );
                      });
                  channel.sink.add("Refresh");
                  await http.post(
                    Uri.parse("$SERVER_IP/PreviousStep"),
                    headers: {
                      "Content-Type": "application/json",
                      "Cookie": "jwt=${widget.jwt}",
                    },
                    body: jsonEncode({
                      "Date": DateTime.now().toString().substring(0, 10),
                      "TripId": widget.tripId,
                    }),
                  );
                  setState(() {
                    Navigator.pop(dialogContext);
                    // Rebuild Whole Page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MainWidget(),
                      ),
                    );
                  });
                },
                child: Container(
                  height: 50,
                  width: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.red,
                  ),
                  child: const Center(
                    child: Text(
                      "استرجاع خطوة",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
