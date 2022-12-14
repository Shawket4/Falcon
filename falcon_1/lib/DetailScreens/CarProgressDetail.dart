// ignore_for_file: non_constant_identifier_names, import_of_legacy_library_into_null_safe, file_names, unused_local_variable

import 'dart:convert';

import 'package:falcon_1/EditScreens/EditTrip.dart';
import 'package:falcon_1/Screens/CarProgressScreen.dart';
import 'package:falcon_1/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:vertical_stepper/vertical_stepper.dart' as step;
import 'package:dio/dio.dart';
import 'package:intl/intl.dart' as intl;

class CarProgressDetailScreen extends StatefulWidget {
  const CarProgressDetailScreen({Key? key, this.car, required this.jwt})
      : super(key: key);
  final dynamic car;
  final String jwt;
  @override
  State<CarProgressDetailScreen> createState() =>
      _CarProgressDetailScreenState();
}

late BuildContext dialogContext;
var isCompleted = false;
final String currentTime = intl.DateFormat('hh:mm a').format(DateTime.now());
late int Speed;
Dio dio = Dio();

Future<String> loadData(String CarNoPlate) async {
  try {
    await dio
        .post("$SERVER_IP/api/GetVehicleStatus",
            data: jsonEncode({
              "CarNoPlate": CarNoPlate,
            }))
        .then((value) {
      // var jsonResponse = json.decode(utf8.decode(value.data));
      Speed = value.data["Speed"];
    });
  } catch (e) {
    return "Error";
  }
  return "";
}

class _CarProgressDetailScreenState extends State<CarProgressDetailScreen>
    with TickerProviderStateMixin {
  List<step.Step> steps = [];
  late BuildContext dialogContext;

  @override
  void initState() {
    isCompleted = false;
    dio.options.headers["Cookie"] = "jwt=${widget.jwt}";
    dio.options.headers["Content-Type"] = "application/json";
    var StepsJson = jsonDecode(widget.car["StepCompleteTime"]);
    if (StepsJson["DropOffPoints"][widget.car["NoOfDropOffPoints"] - 1][2] ==
        true) {
      isCompleted = true;
    }
    if (StepsJson["TruckLoad"][2] != false) {
      steps.add(
        step.Step(
          shimmer: false,
          title: "?????????? ??????????????",
          iconStyle: Colors.green,
          content: Padding(
            padding: const EdgeInsets.only(right: 18.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                "${StepsJson["TruckLoad"][0]} ???? ?????????? ?????????????? ???? ???????????? ${StepsJson["TruckLoad"][1]} ????????????",
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
          title: "?????????? ??????????????",
          iconStyle: Colors.grey,
          content: Padding(
            padding: const EdgeInsets.only(right: 18.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                "?????????? ?????????????? ???? ???????????? ${StepsJson["TruckLoad"][1]}",
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
    }
    // Loop through the steps and add them to the list.
    for (int i = 0; i < widget.car["NoOfDropOffPoints"]; i++) {
      if (StepsJson["DropOffPoints"][i][2] != false) {
        steps.add(
          step.Step(
            shimmer: false,
            title: "?????????? ${StepsJson["DropOffPoints"][i][1]}",
            iconStyle: Colors.green,
            content: Padding(
              padding: const EdgeInsets.only(right: 18.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  // "${StepsJson["DropOffPoints"][i][0]} ???? ?????????? ???? ${StepsJson["DropOffPoints"][i][1]} ????????????",
                  "${StepsJson["DropOffPoints"][i][0]} ???? ${StepsJson["DropOffPoints"][i][1]} ???????????? (${widget.car["Compartments"][i][2].toString()}) ???? ?????????? ${widget.car["Compartments"][i][0].toString()}",
                  // "9:40 A.M ???? ???????????? ???????????? Gas 92 ???? ?????????? 13500",
                  // "???? ${StepsJson["DropOffPoints"][i][1]} ???????????? ${StepsJson["DropOffPoints"][i][0]} (${widget.car["Compartments"][i][2]}) ???? ?????????? ${widget.car["Compartments"][i][0]}",
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
            title: "?????????? ${StepsJson["DropOffPoints"][i][1]}",
            iconStyle: Colors.grey,
            content: Padding(
              padding: const EdgeInsets.only(right: 18.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "(${widget.car["Compartments"][i][2]}) ?????????? ${StepsJson["DropOffPoints"][i][1]} ${widget.car["Compartments"][i][0]}",
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
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print(widget.car["StepCompleteTime"]);

    // Return Scaffold with 3 part linear progress bar filled green based on car.ProgressIndex int
    // Make timeline with car["ProgressIndex"] int
    return FutureBuilder(
        future: loadData(widget.car["CarNoPlate"]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
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
          } else if (snapshot.data.toString() == "Error") {
            return Scaffold(
              body: Padding(
                padding: const EdgeInsets.only(bottom: 100.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Center(
                          // Display lottie animation
                          child: Lottie.asset(
                            "lottie/Error.json",
                            height: 300,
                            width: 300,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CarProgressDetailScreen(
                                jwt: widget.jwt,
                                car: widget.car,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                backgroundColor: Theme.of(context).primaryColor,
                actions: <IconButton>[
                  IconButton(
                    onPressed: () async {
                      // await getTripData;
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => EditCarTripScreen(widget.jwt,
                                  widget.car["CardID"], widget.car)));
                    },
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
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
                      var res = await dio
                          .post(
                        "$SERVER_IP/api/DeleteCarTrip",
                        data: jsonEncode(
                          {
                            "TripId": widget.car["CardID"],
                            "CarNoPlate": widget.car["CarNoPlate"],
                            "DriverName": widget.car["DriverName"],
                          },
                        ),
                      )
                          .then((value) {
                        Navigator.pop(dialogContext);
                        // setState(() {
                        //   Navigator.pop(context);
                        // });
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CarProgressScreen(
                              jwt: widget.jwt.toString(),
                            ),
                          ),
                        );
                      });
                    },
                    icon: const Icon(Icons.delete),
                    color: Colors.red,
                  ),
                ],
                title: Center(
                  child: Text(
                    '???????????? ????????????',
                    style: GoogleFonts.josefinSans(
                      textStyle: const TextStyle(
                        fontSize: 22,
                      ),
                    ),
                  ),
                ),
              ),
              body: content(),
            );
          }
        });
  }

  Widget content() {
    return ListView(
      physics: const BouncingScrollPhysics(),
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image.asset("images/truckDetail.jpeg"),
                  Text(
                    "OLA Tracker",
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
                    "?????? ????????????: ${widget.car['DriverName']} ",
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
        const SizedBox(
          height: 20,
        ),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  "??????????: ${widget.car["FeeRate"]}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              Center(
                child: Text(
                  "???????????? ??????????????: ${Speed.toString()}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        body(),
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
          Row(
            children: const <Widget>[
              Padding(
                padding: EdgeInsets.only(right: 30.0),
                child: Text(
                  "???????? ????????????",
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
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
          const SizedBox(
            height: 10.0,
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
                        setState(() {});
                        var res = await dio.post(
                          "$SERVER_IP/api/NextStep",
                          data: jsonEncode(
                            {
                              "Date":
                                  DateTime.now().toString().substring(0, 10),
                              "Time": currentTime,
                              "TripId": widget.car["CardID"],
                            },
                          ),
                        );
                        setState(() {
                          Navigator.pop(dialogContext);
                          // Rebuild Whole Page
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CarProgressScreen(
                                jwt: widget.jwt,
                              ),
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
                            "???????????? ??????????????",
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
                        var res = await dio.post(
                          "$SERVER_IP/api/CompleteTrip",
                          data: jsonEncode(
                            {
                              "Date":
                                  DateTime.now().toString().substring(0, 10),
                              "CarNoPlate": widget.car["CarNoPlate"],
                              "TripId": widget.car["CardID"],
                              "DriverName": widget.car["DriverName"],
                            },
                          ),
                        );
                        setState(() {
                          Navigator.pop(dialogContext);
                          // Rebuild Whole Page
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CarProgressScreen(
                                jwt: widget.jwt,
                              ),
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
                            "?????????? ????????????",
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
                  var res = await dio.post(
                    "$SERVER_IP/api/PreviousStep",
                    data: jsonEncode(
                      {
                        "Date": DateTime.now().toString().substring(0, 10),
                        "TripId": widget.car["CardID"],
                      },
                    ),
                  );
                  setState(() {
                    Navigator.pop(dialogContext);
                    // Rebuild Whole Page
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CarProgressScreen(
                          jwt: widget.jwt,
                        ),
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
                      "?????????????? ????????",
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
          const SizedBox(height: 20.0),
        ],
      ),
    );
  }
}
