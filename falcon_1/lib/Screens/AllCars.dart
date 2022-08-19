// ignore_for_file: file_names, non_constant_identifier_names

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:falcon_1/DetailScreens/CarProfileDetails.dart';
import 'package:falcon_1/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class AllCars extends StatefulWidget {
  const AllCars({Key? key, required this.jwt}) : super(key: key);
  final String jwt;
  @override
  State<AllCars> createState() => _AllCarsState();
}
List<dynamic> CarList = [];
Dio dio = Dio();
Future<String> get loadData async {
  var res = await dio.post("$SERVER_IP/api/GetCarProfileData").then((response) {
    // Print Json Response  where date is = DateFrom
    print(response.data);
    for (var i = 0; i < response.data.length; i++) {
      CarList.add(response.data[i]);
    }
    CarList.sort((a, b) => a['CarNoPlate'].compareTo(b['CarNoPlate']));
    return "";
  });
  return "";
}

class _AllCarsState extends State<AllCars> {

  @override
  void initState() {
    // Empty the list of cars
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
        title: const Text('السيارات'),
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
                              CarProfileDetails(
                                car: CarList[index],
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
                              tag: "Car ${CarList[index]["CarId"].toString()}",
                              child: const CircleAvatar(
                                backgroundImage: AssetImage('images/truck.jpg'),
                                radius: 35,
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                CarList[index]['CarNoPlate'],
                                style: GoogleFonts.josefinSans(
                                  textStyle: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                CarList[index]["TankCapacity"].toString(),
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
                itemCount: CarList.length,
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
