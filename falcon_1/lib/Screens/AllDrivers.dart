// ignore_for_file: file_names, non_constant_identifier_names

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:falcon_1/DetailScreens/DriverProfileDetails.dart';
import 'package:falcon_1/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class AllDrivers extends StatefulWidget {
  const AllDrivers({Key? key, required this.jwt}) : super(key: key);
  final String jwt;
  @override
  State<AllDrivers> createState() => _AllDriversState();
}
List<dynamic> DriverList = [];
Dio dio = Dio();
Future<String> get loadData async {
    var res = await dio.post("$SERVER_IP/api/GetDriverProfileData").then((response) {
    // Print Json Response  where date is = DateFrom
    for (var i = 0; i < response.data.length; i++) {
      DriverList.add(response.data[i]);
    }
    DriverList.sort((a, b) => a['Name'].compareTo(b['Name']));
    return "";
  });
  return "";
}

class _AllDriversState extends State<AllDrivers> {

  @override
  void initState() {
    dio.options.headers["Cookie"] = "jwt=${widget.jwt}";
    dio.options.headers["Content-Type"] = "application/json";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(50, 75, 205, 1),
        title: const Text('السائقين'),
      ),
      body: FutureBuilder(
          future: loadData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
             return ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DriverProfileDetails(
                                driver: DriverList[index],
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
                              "Driver ${DriverList[index]["DriverId"]
                                  .toString()}",
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
                                DriverList[index]['Name'],
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
                itemCount: DriverList.length,
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
          }

    ),);
  }
}
