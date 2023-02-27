// ignore_for_file: file_names, unused_local_variable, non_constant_identifier_names

import 'package:dio/dio.dart';
import 'package:falcon_1/DetailScreens/ServiceDetailsScreen.dart';
import 'package:falcon_1/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:lottie/lottie.dart';

class AllServiceEvents extends StatefulWidget {
  const AllServiceEvents({super.key, required this.jwt});
  final String jwt;
  @override
  State<AllServiceEvents> createState() => _AllServiceEventsState();
}

class _AllServiceEventsState extends State<AllServiceEvents> {
  Dio dio = Dio();
  List<ServiceEvent> serviceEvents = [];
  Future<Object?> get loadData async {
    serviceEvents.clear();
    try {
      var Request =
          await dio.get("$SERVER_IP/api/GetAllServiceEvents").then((response) {
        var str = response.data;
        var events = str["ServiceEvents"];
        if (events == null) {
          return;
        }
        // print(events);
        for (var event in events) {
          ServiceEvent parsedEvent = ServiceEvent();
          parsedEvent.ServiceId = event["ID"];
          parsedEvent.CarNoPlate = event["car_no_plate"];
          parsedEvent.ServiceType = event["service_type"];
          parsedEvent.Date = event["date_of_service"];
          parsedEvent.Odometer = event["odometer_reading"];
          parsedEvent.ImageName = event["proof_image_name"];
          // parsedEvent.CurrentOdometer = event["current_odometer_reading"];
          serviceEvents.add(
            parsedEvent,
          );
        }
      }).timeout(
        const Duration(seconds: 4),
      );
    } catch (e) {
      return "Error";
    }
    if (serviceEvents.isEmpty) {
      return "Empty";
    }
    return {
      "ServiceEvents": serviceEvents,
    };
  }

  Future<void> reloadData() async {
    var Request =
        await dio.get("$SERVER_IP/api/GetAllServiceEvents").then((response) {
      var str = response.data;

      var events = str["ServiceEvents"];
      // print(events);
      for (var event in events) {
        ServiceEvent parsedEvent = ServiceEvent();
        parsedEvent.ServiceId = event["ID"];
        parsedEvent.CarNoPlate = event["car_no_plate"];
        parsedEvent.ServiceType = event["service_type"];
        parsedEvent.Date = event["date_of_service"];
        parsedEvent.Odometer = event["odometer_reading"];
        parsedEvent.ImageName = event["proof_image_name"];
        // parsedEvent.CurrentOdometer = event["current_odometer_reading"];
        serviceEvents.add(
          parsedEvent,
        );
      }
    }).timeout(
      const Duration(seconds: 4),
    );
  }

  @override
  void initState() {
    selectedBottomIndex = 1;
    dio.options.headers["Cookie"] = "jwt=${widget.jwt}";
    dio.options.headers["Content-Type"] = "application/json";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: loadData,
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
                              builder: (_) => AllServiceEvents(jwt: widget.jwt),
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
              bottomNavigationBar: BottomNavigationWidget(
                jwt: widget.jwt,
              ),
              appBar: AppBar(
                centerTitle: true,
                backgroundColor: Theme.of(context).primaryColor,
                title: const Text("كل الصيانات"),
              ),
              body: Scrollbar(
                scrollbarOrientation: ScrollbarOrientation.left,
                thickness: 8,
                child: LiquidPullToRefresh(
                  onRefresh: reloadData,
                  animSpeedFactor: 1.5,
                  backgroundColor: Colors.grey[300],
                  color: Theme.of(context).primaryColor,
                  height: 200,
                  child: snapshot.data.toString() == "Empty"
                      ? const Center(
                          child: Text("No Service Events"),
                        )
                      : GroupedListView<dynamic, String>(
                          physics: const BouncingScrollPhysics(),
                          useStickyGroupSeparators: true,
                          scrollDirection: Axis.vertical,
                          groupBy: (element) => element.Date,
                          sort: true,
                          elements: serviceEvents,
                          groupSeparatorBuilder: (value) => Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            color: Colors.black,
                            child: Text(
                              value,
                              style: GoogleFonts.josefinSans(
                                textStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          itemBuilder: (context, element) => GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ServiceDetailsScreen(
                                    event: element,
                                    jwt: widget.jwt,
                                    dio: dio,
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              elevation: 4,
                              child: Row(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Hero(
                                      tag: "Service ${element.ServiceId}",
                                      child: const CircleAvatar(
                                        backgroundImage:
                                            AssetImage('images/truck.jpg'),
                                        radius: 35,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        element.CarNoPlate,
                                        style: GoogleFonts.josefinSans(
                                          textStyle: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            );
          }
        });
  }
}

class ServiceEvent {
  late int ServiceId;
  late String CarNoPlate;
  late String ServiceType;
  late String Date;
  late String ImageName;
  late int Odometer;
}
