// ignore_for_file: non_constant_identifier_names, file_names

import 'package:falcon_1/DetailScreens/CarProfileDetails.dart';
import 'package:falcon_1/DetailScreens/DriverProfileDetails.dart';
import 'package:falcon_1/Forms/AddCar.dart';
import 'package:falcon_1/Forms/AddDriver.dart';
import 'package:falcon_1/Forms/AddTransporter.dart';
import 'package:falcon_1/Forms/AddTrip.dart';
import 'package:falcon_1/Screens/AllCars.dart';
import 'package:falcon_1/Screens/AllDrivers.dart';
import 'package:falcon_1/Screens/AllTransporters.dart';
import 'package:falcon_1/Screens/CarProgressScreen.dart';
import 'package:falcon_1/Screens/PermissionScreen.dart';
import 'package:falcon_1/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:lottie/lottie.dart';

import 'Login.dart';

List<dynamic> Cars = [];
var Drivers = [];

Future<Object> loadRequest(String jwt) async {
  Dio dio = Dio();
  // print(jwt);
  dio.options.headers["Cookie"] = "jwt=$jwt";
  dio.options.headers["Content-Type"] = "application/json";
  var res = await dio.get("$SERVER_IP/api/GetPendingRequests").then((response) {
    var str = response.data;
    if (str["Cars"] != null) {
      Cars = str["Cars"];
    }
    if (str["Drivers"] != null) {
      Drivers = str["Drivers"];
    }
  });

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
  Widget buildDrawerItem({
    // required IconData icon,
    required String title,
    required void Function() onTap,
  }) {
    const color = Colors.white;
    return Padding(
      padding: const EdgeInsets.only(top: 2.5, bottom: 2.5),
      child: ListTile(
        // leading: Icon(
        //   Icons.home,
        //   color: color,
        // ),
        onTap: onTap,
        title: Text(
          title,
          style: GoogleFonts.josefinSans(
            textStyle: const TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
          return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: Text(
                  'الطلبات',
                  style: GoogleFonts.josefinSans(
                    textStyle: const TextStyle(
                      fontSize: 22,
                    ),
                  ),
                ),
                backgroundColor:  Theme.of(context).primaryColor,
                // Hamburger Menu
                leading: InkWell(
                  child: Builder(
                    builder: (context) {
                      return IconButton(
                        icon: const Icon(Icons.list),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      );
                    },
                  ),
                ),
              ),
              drawer: Drawer(
                backgroundColor: Theme.of(context).primaryColor,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const SizedBox(
                      height: 65,
                    ),
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundImage: AssetImage(
                          "images/user.png",
                        ),
                        radius: 25,
                      ),
                      trailing: Padding(
                        padding: const EdgeInsets.only(
                          right: 5,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.logout,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () {
                            Dio dio = Dio();
                            dio.options.headers["Cookie"] = "jwt=${widget.jwt}";
                            dio.options.headers["Content-Type"] =
                                "application/json";
                            dio.post("$SERVER_IP/api/logout");
                            storage.delete(key: "jwt");
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      title: Text(
                        name,
                        style: GoogleFonts.josefinSans(
                          textStyle: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    buildDrawerItem(
                      title: "Current System Requests",
                      onTap: () => Navigator.pop(context),
                    ),
                    buildDrawerItem(
                        title: "Current Trips",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CarProgressScreen(
                                jwt: widget.jwt.toString(),
                              ),
                            ),
                          );
                        }),
                    buildDrawerItem(
                        title: "Add Driver",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddDriver(
                                jwt: widget.jwt.toString(),
                              ),
                            ),
                          );
                        }),
                    buildDrawerItem(
                        title: "Add Car",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AddCar(jwt: widget.jwt.toString()),
                            ),
                          );
                        }),
                    int.parse(permission) > 1 ?
                    buildDrawerItem(
                      title: "Add Transporter",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddTransporter(jwt: widget.jwt,),
                          ),
                        );
                      },
                    ) : Container(),
                    int.parse(permission) > 1 ?
                    buildDrawerItem(
                      title: "Add Trip",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                NewCarTripScreen(widget.jwt.toString()),
                          ),
                        );
                      },
                    ) : Container(),
                    buildDrawerItem(
                      title: int.parse(permission) > 1 ? "All Cars" : "My Cars",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AllCars(jwt: widget.jwt.toString()),
                          ),
                        );
                      },
                    ),
                    buildDrawerItem(
                      title: int.parse(permission) > 1 ? "All Drivers" : "My Drivers",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AllDrivers(jwt: widget.jwt.toString()),
                          ),
                        );
                      },
                    ),
                    int.parse(permission) > 1 ?
                    buildDrawerItem(
                      title: "All Transporters",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AllTransporters(jwt: widget.jwt.toString()),
                          ),
                        );
                      },
                    ) : Container(),

                    int.parse(permission) > 3
                        ? buildDrawerItem(
                            title: "Permissions",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PermissionScreen(
                                      jwt: widget.jwt.toString()),
                                ),
                              );
                            },
                          )
                        : Container(),

                    // FlatButton(
                    //   onPressed: () {},
                    //   child: Container(
                    //     width: 200,
                    //     height: 55,
                    //     decoration: const BoxDecoration(
                    //       color: Colors.orange,
                    //       borderRadius: BorderRadius.all(
                    //         Radius.circular(8),
                    //       ),
                    //     ),
                    //     child: const Center(
                    //       child: Text(
                    //         "Logout",
                    //         style: TextStyle(
                    //           color: Colors.white,
                    //           fontSize: 24,
                    //           fontWeight: FontWeight.bold,
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
              body: FutureBuilder(
              future: loadRequest(widget.jwt),
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
      }
             return ListView(
                physics: const BouncingScrollPhysics(),
                // shrinkWrap: true,
                children: [
                  Cars.isNotEmpty ? Container(
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
                  ) : Container(),
                  Cars.isNotEmpty ?
                  ListView.builder(
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
                                  tag: "Car ${Cars[index]["CarId"].toString()}",
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
                                    Cars[index]['CarNoPlate'],
                                    style: GoogleFonts.josefinSans(
                                      textStyle: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    Cars[index]['TankCapacity'].toString(),
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
                  ) : Container(),
                  Drivers.isNotEmpty ?
                  Container(
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
                  ) : Container(),
                  Drivers.isNotEmpty ?
                  ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: Drivers.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DriverProfileDetails(
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                  ) : Container(),
                ],
    );
        },
              ),
          );
  }
}
