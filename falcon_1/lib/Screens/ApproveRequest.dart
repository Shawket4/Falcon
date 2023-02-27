// ignore_for_file: non_constant_identifier_names, file_names, unused_local_variable

import 'package:falcon_1/DetailScreens/CarProfileDetails.dart';
import 'package:falcon_1/DetailScreens/DriverProfileDetails.dart';
import 'package:falcon_1/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:lottie/lottie.dart';

List<dynamic> Cars = [];
var Drivers = [];

Future<Object> loadRequest(String jwt) async {
  Dio dio = Dio();
  // print(jwt);
  dio.options.headers["Cookie"] = "jwt=$jwt";
  dio.options.headers["Content-Type"] = "application/json";
  try {
    var res =
        await dio.get("$SERVER_IP/api/GetPendingRequests").then((response) {
      var str = response.data;
      if (str["Cars"] != null) {
        Cars = str["Cars"];
      }
      if (str["Drivers"] != null) {
        Drivers = str["Drivers"];
      }
    }).timeout(
      const Duration(seconds: 4),
    );
  } catch (e) {
    return "Error";
  }
  if (Drivers.isEmpty && Cars.isEmpty) {
    return "Empty";
  }
  return {
    "Cars": Cars,
    "Drivers": Drivers,
  };
}

class ApproveRequestScreen extends StatefulWidget {
  const ApproveRequestScreen({
    Key? key,
    required this.jwt,
  }) : super(key: key);
  final String jwt;
  @override
  State<ApproveRequestScreen> createState() => _ApproveRequestScreenState();
}

class _ApproveRequestScreenState extends State<ApproveRequestScreen> {
  @override
  void initState() {
    super.initState();
  }

  Future<String> reloadData() async {
    Dio dio = Dio();
    // print(jwt);
    dio.options.headers["Cookie"] = "jwt=${widget.jwt}";
    dio.options.headers["Content-Type"] = "application/json";
    try {
      var res =
          await dio.get("$SERVER_IP/api/GetPendingRequests").then((response) {
        var str = response.data;
        if (str["Cars"] != null) {
          Cars = str["Cars"];
        }
        if (str["Drivers"] != null) {
          Drivers = str["Drivers"];
        }
      });
    } catch (e) {
      return "Error";
    }
    setState(() {});
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SizedBox(
            width: 50,
            height: 50,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                (Cars.length + Drivers.length).toString(),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          'الطلبات',
          style: GoogleFonts.josefinSans(
            textStyle: const TextStyle(
              fontSize: 22,
            ),
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      endDrawer: AppDrawer(
        jwt: widget.jwt,
      ),
      body: FutureBuilder(
        future: loadRequest(widget.jwt),
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
                              builder: (_) => ApproveRequestScreen(
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
          } else if (snapshot.data.toString() == "Empty") {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    'No Current Requests Found.',
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
                          builder: (_) => ApproveRequestScreen(
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
                  // physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  children: [
                    Cars.isNotEmpty
                        ? Container(
                            width: double.infinity,
                            color: Colors.black,
                            height: 50,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: Text(
                                  "Car Requests",
                                  style: GoogleFonts.josefinSans(
                                    textStyle: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(),
                    Cars.isNotEmpty
                        ? ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: Cars.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CarProfileDetails(
                                      car: Cars[index],
                                      jwt: widget.jwt.toString(),
                                    ),
                                  ),
                                ),
                                child: Card(
                                  elevation: 4,
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(14),
                                        child: Hero(
                                          tag:
                                              "Car ${Cars[index]["CarId"].toString()}",
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
                                            Cars[index]['CarNoPlate'],
                                            style: GoogleFonts.josefinSans(
                                              textStyle: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            Cars[index]['TankCapacity']
                                                .toString(),
                                            style: GoogleFonts.josefinSans(
                                              textStyle: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(),
                    Drivers.isNotEmpty
                        ? Container(
                            width: double.infinity,
                            color: Colors.black,
                            height: 50,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: Text(
                                  "Driver Requests",
                                  style: GoogleFonts.josefinSans(
                                    textStyle: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(),
                    Drivers.isNotEmpty
                        ? ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: Drivers.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DriverProfileDetails(
                                        driver: Drivers[index],
                                        jwt: widget.jwt,
                                      ),
                                    ),
                                  );
                                },
                                child: Card(
                                  elevation: 4,
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(14),
                                        child: Hero(
                                          tag:
                                              "Driver ${Drivers[index]["DriverId"].toString()}",
                                          child: const CircleAvatar(
                                            backgroundImage:
                                                AssetImage('images/driver.png'),
                                            radius: 35,
                                          ),
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            Drivers[index]['Name'],
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
                              );
                            },
                          )
                        : Container(),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
