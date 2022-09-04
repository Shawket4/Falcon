// ignore_for_file: file_names, non_constant_identifier_names, unused_local_variable

import 'dart:ffi';

import 'package:dio/dio.dart';
import 'package:falcon_1/DetailScreens/DriverProfileDetails.dart';
import 'package:falcon_1/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:lottie/lottie.dart';

class AllDrivers extends StatefulWidget {
  const AllDrivers({Key? key, required this.jwt}) : super(key: key);
  final String jwt;
  @override
  State<AllDrivers> createState() => _AllDriversState();
}

List<dynamic> DriverList = [];
Dio dio = Dio();

class _AllDriversState extends State<AllDrivers> {
  Future<String> get loadData async {
    if (DriverList.isEmpty) {
      var res = await dio
          .post("$SERVER_IP/api/GetDriverProfileData")
          .then((response) {
        // Print Json Response  where date is = DateFrom
        for (var i = 0; i < response.data.length; i++) {
          DriverList.add(response.data[i]);
        }
        DriverList.sort((a, b) => a['Name'].compareTo(b['Name']));
      });
    }
    setState(() {});
    return "";
  }

  Future<void> reloadData() async {
    DriverList.clear();
    var res =
        await dio.post("$SERVER_IP/api/GetDriverProfileData").then((response) {
      // Print Json Response  where date is = DateFrom
      for (var i = 0; i < response.data.length; i++) {
        DriverList.add(response.data[i]);
      }
      DriverList.sort((a, b) => a['Name'].compareTo(b['Name']));
    });
    setState(() {});
    return;
  }

  @override
  void initState() {
    DriverList.clear();
    dio.options.headers["Cookie"] = "jwt=${widget.jwt}";
    dio.options.headers["Content-Type"] = "application/json";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('السائقين'),
      ),
      body: FutureBuilder(
          future: loadData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return DriverList.isEmpty
                  ? const Center(
                      child: Text("No Drivers Found"),
                    )
                  : LiquidPullToRefresh(
                      onRefresh: reloadData,
                      animSpeedFactor: 1.5,
                      backgroundColor: Colors.grey[300],
                      color: Theme.of(context).primaryColor,
                      height: 200,
                      child: GroupedListView<dynamic, String>(
                        physics: const BouncingScrollPhysics(),
                        useStickyGroupSeparators: true,
                        scrollDirection: Axis.vertical,
                        groupBy: (element) => element["Transporter"],
                        sort: false,
                        elements: DriverList.toList(),
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
                                builder: (context) => DriverProfileDetails(
                                  driver: element,
                                  jwt: widget.jwt,
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
                                    tag:
                                        "Driver ${element["DriverId"].toString()}",
                                    child: CircleAvatar(
                                      backgroundImage:
                                          const AssetImage('images/driver.png'),
                                      backgroundColor: Colors.grey.shade300,
                                      radius: 35,
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      element['Name'],
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
                    );
            } else {
              return Center(
                // Display lottie animation
                child: Lottie.asset(
                  "lottie/SplashScreen.json",
                  height: 200,
                  width: 200,
                ),
              );
            }
          }),
    );
  }
}
