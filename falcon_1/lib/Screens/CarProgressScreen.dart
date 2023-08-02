// ignore_for_file: non_constant_identifier_names, file_names, use_build_context_synchronously, unused_local_variable

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:falcon_1/DetailScreens/CarProgressDetail.dart';
import 'package:falcon_1/bridge_generated.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:lottie/lottie.dart';
import '../main.dart';

class CarProgressScreen extends StatefulWidget {
  const CarProgressScreen(
      {Key? key, required this.jwt, required this.changeDrawerState})
      : super(key: key);
  final String jwt;
  final Function changeDrawerState;
  @override
  State<CarProgressScreen> createState() => _CarProgressScreenState();
}

class _CarProgressScreenState extends State<CarProgressScreen> {
  // This is the SERVER_IP for the web API
  // List<dynamic> CarList = [];
  List<Trip> trips = [];
  List<String> SortItems = ["Date", "Car", "Driver", "Completed Trips"];
  late bool isSortAscending;
  late BuildContext dialogContext;
  late String selectedSortItem;
  late String sortStringItem;
  final ScrollController scrollController = ScrollController();
  // final GlobalKey<ScaffoldState> _key = GlobalKey();
  // Map<String, dynamic> CarMap = {};
  bool isLoaded = false;
  List<dynamic> notificationList = [];
  //Current Date In YYYY--MM--DD Format
  String DateTo =
      DateTime.now().add(const Duration(days: 1)).toString().substring(0, 10);
  // Date From 2 Days Before In YYYY--MM--DD Format
  String DateFrom = DateTime.now()
      .subtract(const Duration(days: 30))
      .toString()
      .substring(0, 10);
  Dio dio = Dio();
  int _tripCount = 0;
  Future<String> loadData(String jwt) async {
    if (!isLoaded) {
      trips.clear();
      try {
        var GetCars = await dio
            .post(
              "$SERVER_IP/GetProgressOfCars",
              data: jsonEncode({
                "DateFrom": DateFrom,
                "DateTo": DateTo,
              }),
              options: Options(
                responseType: ResponseType.plain,
              ),
            )
            .timeout(
              const Duration(seconds: 8),
            );
        if (GetCars.statusCode != 204) {
          var jsonResponse = GetCars.data;
          // print(jsonResponse);
          trips = await impl.returnTrips(json: jsonResponse);
          // for (var i = 0; i < jsonResponse.length; i++) {
          //   CarList.add(jsonResponse[i]);
          //   if (CarMap[(jsonResponse)[i]["date"]] == null) {
          //     CarMap[(jsonResponse[i]["date"])] = [];
          //   }
          //   await CarMap[(jsonResponse[i]["date"])]!.add(jsonResponse[i]);
          // }
          // for (var trip in CarList) {
          //   if (trip["date"] == DateTime.now().toString().substring(0, 10)) {
          //     _tripCount++;
          //   }
          // }
        }
        var GetNotifications = await dio
            .get(
          "$SERVER_IP/api/GetNotifications/",
        )
            .then((value) {
          setState(() {
            if (value.data != null && value.data.isNotEmpty) {
              notificationList = value.data;
            }
          });
        });
        isLoaded = true;
        setState(() {});
      } catch (e) {
        return "Error";
      }
    }
    return "";
  }

  Future<String> reloadData() async {
    // CarList.clear();
    // CarMap.clear();
    trips.clear();
    isLoaded = false;
    // if (!isLoaded) {
    //   try {
    //     var GetCars = await dio
    //         .post(
    //           "$SERVER_IP/GetProgressOfCars",
    //           data: jsonEncode({
    //             "DateFrom": DateFrom,
    //             "DateTo": DateTo,
    //           }),
    //         )
    //         .timeout(
    //           const Duration(seconds: 4),
    //         );
    //     if (GetCars.statusCode != 204) {
    //       var jsonResponse = GetCars.data;
    //       for (var i = 0; i < jsonResponse.length; i++) {
    //         // CarList.add(jsonResponse[i]);
    //         // if (CarMap[(jsonResponse)[i]["date"]] == null) {
    //         //   CarMap[(jsonResponse[i]["date"])] = [];
    //         // }
    //         // await CarMap[(jsonResponse[i]["date"])]!.add(jsonResponse[i]);
    //       }
    //     }
    //     isLoaded = true;
    //     setState(() {});
    //   } catch (e) {
    //     return "Error";
    //   }
    // }
    // setState(() {});
    await loadData(jwt);
    return "";
  }

  //Make post request and store body response in this variable
  @override
  void initState() {
    print("Reached");
    isLoaded = false;
    trips.clear();
    selectedSortItem = SortItems[0];
    sortStringItem = "date";
    isSortAscending = true;
    selectedBottomIndex = 0;
    dio.options.headers["Cookie"] = "jwt=${widget.jwt}";
    dio.options.headers["Content-Type"] = "application/json";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Return Scaffold with ListView builder from CarList and CarListItem has image and text
    return Scaffold(
      // key: _key,
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
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: SizedBox(
              width: 50,
              height: 50,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  _tripCount.toString(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
        leading: IconButton(
          onPressed: () => widget.changeDrawerState(),
          icon: const Icon(
            Icons.menu,
            size: 30,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        // Hamburger Menu
        title: Text(
          'Trips',
          style: GoogleFonts.jost(
            textStyle: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
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
            Padding(
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
                            builder: (_) => HomeScreen(
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
            );
          }
          if (trips.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    'No Current Trips Found.',
                    style: TextStyle(color: Colors.black),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HomeScreen(
                            jwt: widget.jwt,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
            );
          } else {
            return Scrollbar(
              scrollbarOrientation: ScrollbarOrientation.left,
              thickness: 8,
              child: LiquidPullToRefresh(
                onRefresh: reloadData,
                animSpeedFactor: 1.5,
                backgroundColor: Colors.grey[300],
                color: Theme.of(context).primaryColor,
                height: 200,
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 12.0, right: 12.0, bottom: 2.0, top: 2.0),
                      child: Row(
                        children: [
                          Text(
                            "Sort By ->",
                            style: GoogleFonts.josefinSans(
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              dialogContext = context;
                              showDialog(
                                  context: dialogContext,
                                  builder: (dialogContext) => sortDialog(),
                                  barrierDismissible: true);
                            },
                            icon: const Icon(
                              Icons.sort_rounded,
                              size: 26,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GroupedListView<dynamic, String>(
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      // useStickyGroupSeparators: true,
                      scrollDirection: Axis.vertical,
                      groupBy: (element) => element.date,
                      sort: true,
                      elements: trips,
                      groupSeparatorBuilder: (value) => Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        color: Colors.black,
                        child: Text(
                          value.toString(),
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
                                trip: element,
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
                                  backgroundImage:
                                      AssetImage('images/truck.jpg'),
                                  radius: 35,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    element.carNoPlate,
                                    style: GoogleFonts.josefinSans(
                                      textStyle: element.isClosed == true
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
                                    element.driverName.toString(),
                                    style: GoogleFonts.josefinSans(
                                      textStyle: element.isClosed == true
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
                                    element.isClosed == true
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
      //         sort: true,
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

  Widget sortDialog() {
    return Dialog(
      child: SizedBox(
        width: 600,
        height: 500,
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            Center(
              child: Text(
                "Sort",
                style: GoogleFonts.josefinSans(
                  textStyle: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: DropdownSearch<String>(
                dropdownSearchDecoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(),
                  ),
                  labelText: "Sort By*",
                ),
                mode: Mode.MENU,
                showSelectedItems: true,
                enabled: true,
                items: SortItems,
                selectedItem: selectedSortItem,
                onChanged: (item) {
                  setState(() {
                    selectedSortItem = item as String;
                  });
                },
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Padding(
            //       padding: const EdgeInsets.only(left: 30.0, right: 30.0),
            //       child: TextButton(
            //         onPressed: () {
            //           setState(() {
            //             isSortAscending = true;
            //           });
            //         },
            //         child: Container(
            //           width: 150,
            //           height: 50,
            //           decoration: BoxDecoration(
            //             border: Border.all(
            //               color: Theme.of(context).primaryColor,
            //               width: 3,
            //             ),
            //             borderRadius: BorderRadius.circular(10),
            //             color: isSortAscending
            //                 ? Theme.of(context).primaryColor
            //                 : null,
            //           ),
            //           child: Center(
            //             child: Text(
            //               "Ascending",
            //               style: GoogleFonts.josefinSans(
            //                 textStyle: const TextStyle(
            //                   fontSize: 18,
            //                   color: Colors.black,
            //                   fontWeight: FontWeight.bold,
            //                 ),
            //               ),
            //             ),
            //           ),
            //         ),
            //       ),
            //     ),
            //     Padding(
            //       padding: const EdgeInsets.only(left: 30.0, right: 30.0),
            //       child: TextButton(
            //         onPressed: () {
            //           setState(() {
            //             isSortAscending = false;
            //           });
            //         },
            //         child: Container(
            //           width: 150,
            //           height: 50,
            //           decoration: BoxDecoration(
            //             border: Border.all(
            //               color: Theme.of(context).primaryColor,
            //               width: 3,
            //             ),
            //             color: !isSortAscending
            //                 ? Theme.of(context).primaryColor
            //                 : null,
            //             borderRadius: BorderRadius.circular(10),
            //           ),
            //           child: Center(
            //             child: Text(
            //               "Descending",
            //               style: GoogleFonts.josefinSans(
            //                 textStyle: const TextStyle(
            //                   fontSize: 18,
            //                   color: Colors.black,
            //                   fontWeight: FontWeight.bold,
            //                 ),
            //               ),
            //             ),
            //           ),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            const Spacer(),
            TextButton(
              onPressed: () {
                setState(() {
                  if (selectedSortItem == "Date") {
                    sortStringItem = "date";
                  } else if (selectedSortItem == "Car") {
                    sortStringItem = "car_no_plate";
                  } else if (selectedSortItem == "Driver") {
                    sortStringItem = "driver_name";
                  } else if (selectedSortItem == "Completed Trips") {
                    sortStringItem = "is_closed";
                  }
                });
                Navigator.pop(dialogContext);
              },
              child: Text(
                "Done",
                style: GoogleFonts.josefinSans(
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
