// ignore_for_file: non_constant_identifier_names, import_of_legacy_library_into_null_safe, file_names, unused_local_variable

import 'dart:convert';

import 'package:falcon_1/DetailScreens/CloseTripConfirmationScreen.dart';
import 'package:falcon_1/EditScreens/EditTrip.dart';
import 'package:falcon_1/Maps/MapHistory.dart';
import 'package:falcon_1/Screens/CarProgressScreen.dart';
import 'package:falcon_1/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:vertical_stepper/vertical_stepper.dart' as step;
import 'package:dio/dio.dart';
import 'package:intl/intl.dart' as intl;

class CarProgressDetailScreen extends StatefulWidget {
  const CarProgressDetailScreen({Key? key, this.trip, required this.jwt})
      : super(key: key);
  final dynamic trip;
  final String jwt;
  @override
  State<CarProgressDetailScreen> createState() =>
      _CarProgressDetailScreenState();
}

late BuildContext dialogContext;
var isCompleted = false;
// final String currentTime = intl.DateFormat('hh:mm a').format(DateTime.now());
// int TotalVolume = 0;
Dio dio = Dio();

class _CarProgressDetailScreenState extends State<CarProgressDetailScreen>
    with TickerProviderStateMixin {
  List<step.Step> steps = [];
  late BuildContext dialogContext;

  @override
  void initState() {
    isCompleted = widget.trip["is_closed"];
    dio.options.headers["Cookie"] = "jwt=${widget.jwt}";
    dio.options.headers["Content-Type"] = "application/json";

    var StepsJson = widget.trip["step_complete_time_db"];
    if (StepsJson["drop_off_points"][widget.trip["no_of_drop_off_points"] - 1]
            ["status"] ==
        true) {
      isCompleted = true;
    }
    // if (StepsJson["DropOffPoints"][widget.trip["NoOfDropOffPoints"] - 1][2] ==
    //     true) {
    //   isCompleted = true;
    // }

    if (StepsJson["terminal"]["status"] == true) {
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
                "${StepsJson["terminal"]["time_stamp"]} الساعة ${StepsJson["terminal"]["terminal_name"]} تم تحميل الشاحنة من مستودع",
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
              child: Text(
                "${StepsJson["terminal"]["terminal_name"]} تحميل الشاحنة من مستودع",
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
    for (int i = 0; i < StepsJson["drop_off_points"].length; i++) {
      if (StepsJson["drop_off_points"][i]["status"] == true) {
        steps.add(
          step.Step(
            shimmer: false,
            title: "تفريغ ${StepsJson["drop_off_points"][i]["location_name"]}",
            iconStyle: Colors.green,
            content: Padding(
              padding: const EdgeInsets.only(right: 18.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  // "${StepsJson["DropOffPoints"][i][0]} تم تفريغ في ${StepsJson["DropOffPoints"][i][1]} الساعة",
                  "${StepsJson["drop_off_points"][i]["time_stamp"]} الساعة (${StepsJson["drop_off_points"][i]["gas_type"]}) (${StepsJson["drop_off_points"][i]["capacity"]}) ${StepsJson["drop_off_points"][i]["location_name"]} تم التفريغ في ",
                  // "9:40 A.M في اكتوبر الساعة Gas 92 تم تفريغ 13500",
                  // "في ${StepsJson["DropOffPoints"][i][1]} الساعة ${StepsJson["DropOffPoints"][i][0]} (${widget.trip["Compartments"][i][2]}) تم تفريغ ${widget.trip["Compartments"][i][0]}",
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
            title: "تفريغ ${StepsJson["drop_off_points"][i]["location_name"]}",
            iconStyle: Colors.grey,
            content: Padding(
              padding: const EdgeInsets.only(right: 18.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  // "(${StepsJson["drop_off_points"][i]["gas_type"]}) تفريغ ${StepsJson["drop_off_points"][i]["location_name"]} ${StepsJson["drop_off_points"][i]["capacity"]}",
                  "(${StepsJson["drop_off_points"][i]["gas_type"]}) (${StepsJson["drop_off_points"][i]["capacity"]}) ${StepsJson["drop_off_points"][i]["location_name"]} تفريغ",
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
    // print(widget.trip["StepCompleteTime"]);

    // Return Scaffold with 3 part linear progress bar filled green based on trip.ProgressIndex int
    // Make timeline with trip["ProgressIndex"] int
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
                  builder: (_) => EditCarTripScreen(
                    widget.jwt,
                    widget.trip["ID"],
                    widget.trip,
                  ),
                ),
              );
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
                    "TripId": widget.trip["ID"],
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
              }).timeout(
                const Duration(seconds: 4),
              );
            },
            icon: const Icon(Icons.delete),
            color: Colors.red,
          ),
        ],
        title: Center(
          child: Text(
            'تفاصيل النقلة',
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
                    widget.trip["car_no_plate"] +
                        " (${widget.trip["tank_capacity"]})",
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
                    "اسم السائق: ${widget.trip['driver_name']} ",
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
                  "الفئة: ${widget.trip["fee_rate"]}",
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
                  "المسافة: ${widget.trip["mileage"].toString()}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              widget.trip['is_closed']
                  ? IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => MapHistory(
                                    tripID: widget.trip["ID"], jwt: jwt)));
                      },
                      icon: const Icon(Icons.map_rounded),
                    )
                  : Container(),
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
                  "حالة النقلة",
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
              isCompleted == false
                  ? GestureDetector(
                      onLongPress: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CloseTripConfirmation(
                              trip: widget.trip,
                              jwt: widget.jwt,
                            ),
                          ),
                        );
                      },
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
                        setState(() {});
                        var res = await dio
                            .post(
                              "$SERVER_IP/api/NextStep",
                              data: jsonEncode(
                                {
                                  "Date": DateTime.now()
                                      .toString()
                                      .substring(0, 10),
                                  "DateFormatted": intl.DateFormat("MM/dd/yyyy")
                                      .format(DateTime.now()),
                                  "Time": intl.DateFormat('hh:mm a')
                                      .format(DateTime.now()),
                                  "TimeFormatted": intl.DateFormat('HH:mm:ss')
                                      .format(DateTime.now()),
                                  "TripId": widget.trip["ID"],
                                },
                              ),
                            )
                            .timeout(
                              const Duration(seconds: 4),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CloseTripConfirmation(
                              trip: widget.trip,
                              jwt: widget.jwt,
                            ),
                          ),
                        );
                        // showDialog(
                        //     context: context,
                        //     barrierDismissible: false,
                        //     builder: (context) {
                        //       dialogContext = context;
                        //       return Dialog(
                        //         shape: RoundedRectangleBorder(
                        //           borderRadius: BorderRadius.circular(12.0),
                        //         ),
                        //         child: SizedBox(
                        //           height: 400,
                        //           width: double.infinity,
                        //           child: Center(
                        //             // Display lottie animation
                        //             child: Lottie.asset(
                        //               "lottie/SplashScreen.json",
                        //               height: 200,
                        //               width: 200,
                        //             ),
                        //           ),
                        //         ),
                        //       );
                        //     });
                        // var res = await dio
                        //     .post(
                        //       "$SERVER_IP/api/CompleteTrip",
                        //       data: jsonEncode(
                        //         {
                        //           "Date": DateTime.now()
                        //               .toString()
                        //               .substring(0, 10),
                        //           "CarNoPlate": widget.trip["CarNoPlate"],
                        //           "TimeFormatted": intl.DateFormat('HH:mm:ss')
                        //               .format(DateTime.now()),
                        //           "DateFormatted": intl.DateFormat("MM/dd/yyyy")
                        //               .format(DateTime.now()),
                        //           "TripId": widget.trip["CardID"],
                        //           "DriverName": widget.trip["DriverName"],
                        //         },
                        //       ),
                        //     )
                        //     .timeout(
                        //       const Duration(seconds: 4),
                        //     );
                        // setState(() {
                        //   Navigator.pop(dialogContext);
                        //   // Rebuild Whole Page
                        //   Navigator.pushReplacement(
                        //     context,
                        //     MaterialPageRoute(
                        //       builder: (_) => CarProgressScreen(
                        //         jwt: widget.jwt,
                        //       ),
                        //     ),
                        //   );
                        // });
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
                  var res = await dio
                      .post(
                        "$SERVER_IP/api/PreviousStep",
                        data: jsonEncode(
                          {
                            "TripId": widget.trip["ID"],
                          },
                        ),
                      )
                      .timeout(
                        const Duration(seconds: 4),
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
          const SizedBox(height: 20.0),
        ],
      ),
    );
  }
}
