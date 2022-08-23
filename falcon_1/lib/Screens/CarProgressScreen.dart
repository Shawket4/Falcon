// ignore_for_file: non_constant_identifier_names, file_names, use_build_context_synchronously

import 'dart:convert';

import 'package:falcon_1/DetailScreens/CarProgressDetail.dart';
import 'package:falcon_1/Forms/AddCar.dart';
import 'package:falcon_1/Forms/AddTransporter.dart';
import 'package:falcon_1/Forms/AddTrip.dart';
import 'package:falcon_1/Screens/AllCars.dart';
import 'package:falcon_1/Screens/AllDrivers.dart';
import 'package:falcon_1/Screens/AllTransporters.dart';
import 'package:falcon_1/Screens/ApproveRequest.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

import '../main.dart';
import '../Forms/AddDriver.dart';
import 'Login.dart';
import 'PermissionScreen.dart';

class CarProgressScreen extends StatefulWidget {
  const CarProgressScreen({Key? key, required this.jwt}) : super(key: key);
  final String jwt;
  @override
  State<CarProgressScreen> createState() => _CarProgressScreenState();
}

class _CarProgressScreenState extends State<CarProgressScreen> {
  // This is the SERVER_IP for the web API
  List<dynamic> CarList = [];
  // Make a map of dates and Carlists
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
  String? username;

  //Make post request and store body response in this variable
  @override
  void initState() {
    // Empty the list of cars
    if (isLoaded == false) {
      http
          .post(
        Uri.parse("$SERVER_IP/GetProgressOfCars"),
        headers: {
          "Content-Type": "application/json",
          "Cookie": "jwt=${widget.jwt}",
        },
        body: jsonEncode({
          "DateFrom": DateFrom,
          "DateTo": DateTo,
        }),
      )
          .then((value) {
        if (value.statusCode != 204) {
          var jsonResponse = json.decode(utf8.decode(value.bodyBytes));
          // Print Json Response  where date is = DateFrom

          for (var i = 0; i < jsonResponse.length; i++) {
            CarList.add(jsonResponse[i]);
            if (CarMap[(jsonResponse)[i]["Date"]] == null) {
              CarMap[(jsonResponse[i]["Date"])] = [];
            }
            CarMap[(jsonResponse[i]["Date"])]!.add(jsonResponse[i]);
          }
        }
        setState(() {
          isLoaded = true;
        });
      });
      http.post(
        Uri.parse("$SERVER_IP/api/User"),
        headers: {
          "Content-Type": "application/json",
          "Cookie": "jwt=${widget.jwt}",
        },
      ).then((value) {
        var jsonRes = json.decode(utf8.decode(value.bodyBytes));
        username = jsonRes["name"];
        setState(() {});
      });
      super.initState();
    }
  }

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
    // Return Scaffold with ListView builder from CarList and CarListItem has image and text
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        // Hamburger Menu
        leading: InkWell(
          // onTap: _onTapped,
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
        actions: [
          // Hamburger Menu
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                CarList.clear();
                isLoaded = false;
              });
              http
                  .post(
                Uri.parse("$SERVER_IP/GetProgressOfCars"),
                headers: {
                  "Content-Type": "application/json",
                  "Cookie": "jwt=${widget.jwt}",
                },
                body: jsonEncode({
                  "DateFrom": DateFrom,
                  "DateTo": DateTo,
                }),
              )
                  .then((value) {
                if (value.statusCode != 204) {
                  var jsonResponse = json.decode(utf8.decode(value.bodyBytes));
                  // Print Json Response  where date is = DateFrom

                  for (var i = 0; i < jsonResponse.length; i++) {
                    CarList.add(jsonResponse[i]);
                    if (CarMap[(jsonResponse)[i]["Date"]] == null) {
                      CarMap[(jsonResponse[i]["Date"])] = [];
                    }
                    CarMap[(jsonResponse[i]["Date"])]!.add(jsonResponse[i]);
                  }
                }
                setState(() {
                  isLoaded = true;
                });
              });
            },
          ),
          // Logout button
        ],
        title: Text(
          'النقلات',
          style: GoogleFonts.josefinSans(
            textStyle: const TextStyle(
              fontSize: 22,
            ),
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
                    http.post(Uri.parse("$SERVER_IP/api/logout"), headers: {
                      "Content-Type": "application/json",
                      "Cookie": "jwt=${widget.jwt}",
                    });
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
                "$username",
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
            int.parse(permission) >= 3
                ? buildDrawerItem(
                    title: "Current System Requests",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ApproveRequestScreen(
                            jwt: widget.jwt,
                          ),
                        ),
                      );
                    })
                : Container(),
            buildDrawerItem(
              title: "Current Trips",
              onTap: () => Navigator.pop(context),
            ),
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
          ],
        ),
      ),
      body: isLoaded
          ? CarMap.isEmpty == true
              ? const Center(
                  child: Text('No Current Trips Found'),
                )
              : GroupedListView<dynamic, String>(
                  physics: const BouncingScrollPhysics(),
                  useStickyGroupSeparators: true,
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
                  itemBuilder: (context, element) => Card(
                    elevation: 4,
                    child: GestureDetector(
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
                )
          : Center(
              // Display lottie animation
              child: Lottie.asset(
                "lottie/SplashScreen.json",
                height: 200,
                width: 200,
              ),
            ),
    );
  }
}
