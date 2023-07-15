// ignore_for_file: file_names, unused_local_variable, non_constant_identifier_names

import 'package:dio/dio.dart';
import 'package:falcon_1/DetailScreens/FuelEventDetailScreen.dart';
import 'package:falcon_1/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:lottie/lottie.dart';

class AllFuelEvents extends StatefulWidget {
  const AllFuelEvents({super.key, required this.jwt});
  final String jwt;
  @override
  State<AllFuelEvents> createState() => _AllFuelEventsState();
}

class _AllFuelEventsState extends State<AllFuelEvents> {
  Dio dio = Dio();
  List<FuelEvent> fuelEvents = [];
  Future<Object?> get loadData async {
    fuelEvents.clear();
    try {
      var Request = await dio
          .get("$SERVER_IP/api/protected/GetFuelEvents")
          .then((response) {
        var events = response.data;
        if (events == null) {
          return;
        }
        // print(events);
        for (var event in events) {
          FuelEvent parsedEvent = FuelEvent();
          parsedEvent.EventId = event["ID"];
          parsedEvent.CarNoPlate = event["car_no_plate"];
          parsedEvent.Date = event["date"];
          parsedEvent.Liters = double.parse(event["liters"].toStringAsFixed(2));
          parsedEvent.PricePerLiter =
              double.parse(event["price_per_liter"].toStringAsFixed(2));
          parsedEvent.Price = double.parse(event["price"].toStringAsFixed(2));
          parsedEvent.FuelRate =
              double.parse(event["fuel_rate"].toStringAsFixed(2));
          parsedEvent.OdometerBefore = event["odometer_before"];
          parsedEvent.OdometerAfter = event["odometer_after"];

          fuelEvents.add(
            parsedEvent,
          );
        }
      }).timeout(
        const Duration(seconds: 4),
      );
    } catch (e) {
      return "Error";
    }
    if (fuelEvents.isEmpty) {
      return "Empty";
    }
    fuelEvents.sort((a, b) => b.CarNoPlate.compareTo(a.CarNoPlate));
    return {
      "FuelEvents": fuelEvents,
    };
  }

  Future<void> reloadData() async {
    fuelEvents.clear();
    var Request = await dio
        .get("$SERVER_IP/api/protected/GetFuelEvents")
        .then((response) {
      var events = response.data;
      if (events == null) {
        return;
      }
      for (var event in events) {
        FuelEvent parsedEvent = FuelEvent();
        parsedEvent.EventId = event["ID"];
        parsedEvent.CarNoPlate = event["car_no_plate"];
        parsedEvent.Date = event["date"];
        parsedEvent.Liters = double.parse(event["liters"].toStringAsFixed(2));
        parsedEvent.PricePerLiter =
            double.parse(event["price_per_liter"].toStringAsFixed(2));
        parsedEvent.Price = double.parse(event["price"].toStringAsFixed(2));
        parsedEvent.FuelRate =
            double.parse(event["fuel_rate"].toStringAsFixed(2));
        parsedEvent.OdometerBefore = event["odometer_before"];
        parsedEvent.OdometerAfter = event["odometer_after"];

        fuelEvents.add(
          parsedEvent,
        );
      }
    }).timeout(
      const Duration(seconds: 4),
    );
  }

  @override
  void initState() {
    selectedBottomIndex = 2;
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
                              builder: (_) => AllFuelEvents(jwt: widget.jwt),
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
                title: const Text("All Fuel Events"),
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
                          child: Text("No Fuel Events"),
                        )
                      : GroupedListView<dynamic, String>(
                          physics: const BouncingScrollPhysics(),
                          useStickyGroupSeparators: true,
                          scrollDirection: Axis.vertical,
                          groupBy: (element) => element.CarNoPlate,
                          elements: fuelEvents,
                          sort: true,
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
                                  builder: (context) => FuelEventDetailsScreen(
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
                                      tag: "Fuel ${element.EventId}",
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
                                      Text(
                                        "${element.Liters} Liters",
                                        style: GoogleFonts.josefinSans(
                                          textStyle: const TextStyle(
                                            fontSize: 18,
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

class FuelEvent {
  late int EventId;
  late String CarNoPlate;
  late String Date;
  late double Liters;
  late double PricePerLiter;
  late double Price;
  late double FuelRate;
  late int OdometerBefore;
  late int OdometerAfter;
}
