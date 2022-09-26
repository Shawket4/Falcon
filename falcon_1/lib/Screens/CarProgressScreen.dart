// ignore_for_file: non_constant_identifier_names, file_names, use_build_context_synchronously

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:falcon_1/DetailScreens/CarProgressDetail.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:lottie/lottie.dart';
import '../main.dart';

class CarProgressScreen extends StatefulWidget {
  const CarProgressScreen({Key? key, required this.jwt}) : super(key: key);
  final String jwt;
  @override
  State<CarProgressScreen> createState() => _CarProgressScreenState();
}

class _CarProgressScreenState extends State<CarProgressScreen> {
  // This is the SERVER_IP for the web API
  List<dynamic> CarList = [];

  Map<String, dynamic> CarMap = {};
  bool isLoaded = false;
  //Current Date In YYYY--MM--DD Format
  String DateTo =
      DateTime.now().add(const Duration(days: 1)).toString().substring(0, 10);
  // Date From 2 Days Before In YYYY--MM--DD Format
  String DateFrom = DateTime.now()
      .subtract(const Duration(days: 50))
      .toString()
      .substring(0, 10);
  Dio dio = Dio();

  Future<String> loadData(String jwt) async {
    if (!isLoaded) {
      try {
        var GetCars = await dio.post(
          "$SERVER_IP/GetProgressOfCars",
          data: jsonEncode({
            "DateFrom": DateFrom,
            "DateTo": DateTo,
          }),
        );
        if (GetCars.statusCode != 204) {
          var jsonResponse = GetCars.data;
          for (var i = 0; i < jsonResponse.length; i++) {
            CarList.add(jsonResponse[i]);
            if (CarMap[(jsonResponse)[i]["Date"]] == null) {
              CarMap[(jsonResponse[i]["Date"])] = [];
            }
            await CarMap[(jsonResponse[i]["Date"])]!.add(jsonResponse[i]);
          }
        }
        isLoaded = true;
        setState(() {});
      } catch (e) {
        return "Error";
      }
    }
    return "";
  }

  Future<String> reloadData() async {
    CarList.clear();
    CarMap.clear();
    isLoaded = false;
    if (!isLoaded) {
      try {
        var GetCars = await dio.post(
          "$SERVER_IP/GetProgressOfCars",
          data: jsonEncode({
            "DateFrom": DateFrom,
            "DateTo": DateTo,
          }),
        );
        if (GetCars.statusCode != 204) {
          var jsonResponse = GetCars.data;
          for (var i = 0; i < jsonResponse.length; i++) {
            CarList.add(jsonResponse[i]);
            if (CarMap[(jsonResponse)[i]["Date"]] == null) {
              CarMap[(jsonResponse[i]["Date"])] = [];
            }
            await CarMap[(jsonResponse[i]["Date"])]!.add(jsonResponse[i]);
          }
        }
        isLoaded = true;
        setState(() {});
      } catch (e) {
        return "Error";
      }
    }
    return "";
  }

  //Make post request and store body response in this variable
  @override
  void initState() {
    dio.options.headers["Cookie"] = "jwt=${widget.jwt}";
    dio.options.headers["Content-Type"] = "application/json";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Return Scaffold with ListView builder from CarList and CarListItem has image and text
    return Scaffold(
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: CurrentIndex!,
      //   onTap: (value) => setState(() {
      //     if (CurrentIndex != value) {
      //       CurrentIndex = value;
      //       Navigator.pushReplacement(
      //           context,
      //           MaterialPageRoute(
      //               builder: (_) => ApproveRequestScreen(jwt: widget.jwt)));
      //     }
      //   }),
      //   items: const <BottomNavigationBarItem>[
      //     BottomNavigationBarItem(
      //       icon: Icon(
      //         Icons.home,
      //       ),
      //       label: "Trip Status",
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.request_page),
      //       label: "Requests",
      //     ),
      //   ],
      // ),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        // Hamburger Menu
        title: Text(
          'النقلات',
          style: GoogleFonts.josefinSans(
            textStyle: const TextStyle(
              fontSize: 22,
            ),
          ),
        ),
      ),
      endDrawer: AppDrawer(
        jwt: widget.jwt,
      ),
      body: FutureBuilder(
        future: loadData(widget.jwt),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              // Display lottie animation
              child: Lottie.asset(
                "lottie/SplashScreen.json",
                height: 200,
                width: 200,
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
                              builder: (_) => CarProgressScreen(
                                jwt: widget.jwt,
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
          }
          if (CarMap.isEmpty) {
            return const Center(
              child: Text('No Current Trips Found'),
            );
          } else {
            return LiquidPullToRefresh(
              onRefresh: reloadData,
              animSpeedFactor: 1.5,
              backgroundColor: Colors.grey[300],
              color: Theme.of(context).primaryColor,
              height: 200,
              child: ListView(
                children: [
                  GroupedListView<dynamic, String>(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    // useStickyGroupSeparators: true,
                    scrollDirection: Axis.vertical,
                    groupBy: (element) => element["Date"],
                    sort: false,
                    elements: CarList.toList(),
                    groupSeparatorBuilder: (value) => Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: Colors.black,
                      child: Text(
                        "Date: $value",
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
                            builder: (context) => CarProgressDetailScreen(
                              car: element,
                              jwt: widget.jwt.toString(),
                            ),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 4,
                        child: Row(
                          children: <Widget>[
                            // Image.network(
                            //   "",
                            //   width: 100,
                            //   height: 100,
                            // ),
                            const Padding(
                              padding: EdgeInsets.all(14),
                              child: CircleAvatar(
                                backgroundImage: AssetImage('images/truck.jpg'),
                                radius: 35,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  element['CarNoPlate'],
                                  style: GoogleFonts.josefinSans(
                                    textStyle:
                                        element['IsInTrip'].toString() != "true"
                                            ? const TextStyle(
                                                color: Colors.green,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w600,
                                              )
                                            : const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w600,
                                              ),
                                  ),
                                ),
                                Text(
                                  element['DriverName'].toString(),
                                  style: GoogleFonts.josefinSans(
                                    textStyle:
                                        element['IsInTrip'].toString() != "true"
                                            ? const TextStyle(
                                                color: Colors.green,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                              )
                                            : const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                              ),
                                  ),
                                ),
                                Text(
                                  element['IsInTrip'].toString() != "true"
                                      ? "Trip Has Been Completed"
                                      : "",
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
      // ? CarMap.isEmpty == true
      //     ? const Center(
      //         child: Text('No Current Trips Found'),
      //       )
      //     : GroupedListView<dynamic, String>(
      //         physics: const BouncingScrollPhysics(),
      //         useStickyGroupSeparators: true,
      //         scrollDirection: Axis.vertical,
      //         groupBy: (element) => element["Date"],
      //         sort: false,
      //         elements: CarList.toList(),
      //         groupSeparatorBuilder: (value) => Container(
      //           width: double.infinity,
      //           padding: const EdgeInsets.all(16),
      //           color: Colors.black,
      //           child: Text(
      //             "Date: $value",
      //             style: GoogleFonts.josefinSans(
      //               textStyle: const TextStyle(
      //                 color: Colors.white,
      //                 fontSize: 18,
      //                 fontWeight: FontWeight.w500,
      //               ),
      //             ),
      //           ),
      //         ),
      //         itemBuilder: (context, element) => Card(
      //           elevation: 4,
      //           child: GestureDetector(
      //             onTap: () {
      //               Navigator.push(
      //                 context,
      //                 MaterialPageRoute(
      //                   builder: (context) => CarProgressDetailScreen(
      //                     car: element,
      //                     jwt: widget.jwt.toString(),
      //                   ),
      //                 ),
      //               );
      //             },
      //             child: Row(
      //               children: <Widget>[
      //                 // Image.network(
      //                 //   "",
      //                 //   width: 100,
      //                 //   height: 100,
      //                 // ),
      //                 const Padding(
      //                   padding: EdgeInsets.all(14),
      //                   child: CircleAvatar(
      //                     backgroundImage: AssetImage('images/truck.jpg'),
      //                     radius: 35,
      //                   ),
      //                 ),
      //                 Column(
      //                   crossAxisAlignment: CrossAxisAlignment.start,
      //                   children: [
      //                     Text(
      //                       element['CarNoPlate'],
      //                       style: GoogleFonts.josefinSans(
      //                         textStyle:
      //                             element['IsInTrip'].toString() != "true"
      //                                 ? const TextStyle(
      //                                     color: Colors.green,
      //                                     fontSize: 20,
      //                                     fontWeight: FontWeight.w600,
      //                                   )
      //                                 : const TextStyle(
      //                                     fontSize: 20,
      //                                     fontWeight: FontWeight.w600,
      //                                   ),
      //                       ),
      //                     ),
      //                     Text(
      //                       element['DriverName'].toString(),
      //                       style: GoogleFonts.josefinSans(
      //                         textStyle:
      //                             element['IsInTrip'].toString() != "true"
      //                                 ? const TextStyle(
      //                                     color: Colors.green,
      //                                     fontSize: 18,
      //                                     fontWeight: FontWeight.w500,
      //                                   )
      //                                 : const TextStyle(
      //                                     fontSize: 18,
      //                                     fontWeight: FontWeight.w500,
      //                                   ),
      //                       ),
      //                     ),
      //                     Text(
      //                       element['IsInTrip'].toString() != "true"
      //                           ? "Trip Has Been Completed"
      //                           : "",
      //                       style: const TextStyle(
      //                         color: Colors.green,
      //                         fontSize: 16,
      //                         fontWeight: FontWeight.w500,
      //                       ),
      //                     ),
      //                   ],
      //                 ),
      //               ],
      //             ),
      //           ),
      //         ),
      //       )
      // : Center(
      //     // Display lottie animation
      //     child: Lottie.asset(
      //       "lottie/SplashScreen.json",
      //       height: 200,
      //       width: 200,
      //     ),
      //   ),
    );
  }
}
