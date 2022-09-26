// ignore_for_file: file_names, non_constant_identifier_names, unused_local_variable

import 'package:dio/dio.dart';
import 'package:falcon_1/DetailScreens/CarProfileDetails.dart';
import 'package:falcon_1/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:lottie/lottie.dart';

class AllCars extends StatefulWidget {
  const AllCars({Key? key, required this.jwt}) : super(key: key);
  final String jwt;
  @override
  State<AllCars> createState() => _AllCarsState();
}

List<dynamic> CarList = [];
Dio dio = Dio();

class _AllCarsState extends State<AllCars> {
  Future<String> get loadData async {
    if (CarList.isEmpty) {
      try {
        var res =
            await dio.post("$SERVER_IP/api/GetCarProfileData").then((response) {
          // Print Json Response  where date is = DateFrom
          for (var i = 0; i < response.data.length; i++) {
            CarList.add(response.data[i]);
          }
          CarList.sort((a, b) => a['CarNoPlate'].compareTo(b['CarNoPlate']));
        });
      } catch (e) {
        return "Error";
      }
    }
    setState(() {});
    return "";
  }

  Future<void> reloadData() async {
    CarList.clear();
    var res =
        await dio.post("$SERVER_IP/api/GetCarProfileData").then((response) {
      // Print Json Response  where date is = DateFrom
      for (var i = 0; i < response.data.length; i++) {
        CarList.add(response.data[i]);
      }
      CarList.sort((a, b) => a['CarNoPlate'].compareTo(b['CarNoPlate']));
    });

    setState(() {});
    return;
  }

  @override
  void initState() {
    //Clear list
    CarList.clear();
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
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('السيارات'),
      ),
      body: FutureBuilder(
          future: loadData,
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
                                builder: (_) => AllCars(
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
            } else {
              return CarList.isEmpty
                  ? const Center(
                      child: Text("No Cars Found"),
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
                        elements: CarList.toList(),
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
                                builder: (context) => CarProfileDetails(
                                  car: element,
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
                                    tag: "Car ${element["CarId"].toString()}",
                                    child: const CircleAvatar(
                                      backgroundImage:
                                          AssetImage('images/truck.jpg'),
                                      radius: 35,
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      element['CarNoPlate'],
                                      style: GoogleFonts.josefinSans(
                                        textStyle: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      element["TankCapacity"].toString(),
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
                        ),
                      ),
                    );
            }
          }),
    );
  }
}
