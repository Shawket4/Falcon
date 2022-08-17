// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:convert';

import 'package:falcon_driver_app/Screens/DriverTripControls.dart';
import 'package:falcon_driver_app/Screens/Login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

const SERVER_IP = 'http://92.205.60.182:3001/api';
// const SERVER_IP = 'http://localhost:3001/api';

void main() {
  runApp(const MainWidget());
}

class MainWidget extends StatelessWidget {
  const MainWidget({Key? key}) : super(key: key);

  Future<String?> get jwtOrEmpty async {
    var jwt = await storage.read(key: "jwt");
    if (jwt == null) {
      await storage.delete(key: "jwt");
      return "";
    }
    jwt = jsonDecode(jwt)["jwt"];
    // print(jwt);
    // storage.delete(key: "jwt");
    // make post request to user
    await http.post(Uri.parse("$SERVER_IP/user"), headers: {
      "Cookie": "jwt=$jwt",
    }).then((value) {
      if (value.statusCode == 401) {
        storage.delete(key: "jwt");
        return "";
      }
    });

    return jwt;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Authentication Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
          future: jwtOrEmpty,
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
            if (snapshot.data != "") {
              var jwt = snapshot.data.toString();
              // var jwt = jsonDecode(str)["jwt"];
              // var jwt = jsonDecode(str)["jwt"];
              if (jwt.length < 3) {
                return const LoginScreen();
              } else {
                // var payload = json.decode(utf8.decode(jwt.codeUnits));
                return FutureBuilder(
                  future: CheckIfInTrip,
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
                    } else {
                      // Get Snapshot.data["TripID"]
                      var res = jsonEncode(snapshot.data);
                      dynamic car =
                          json.decode(utf8.decode(res.codeUnits))["Car"];
                      dynamic tripId =
                          json.decode(utf8.decode(res.codeUnits))["TripId"];
                      if (jsonDecode(res)["IsInTrip"] == true) {
                        return DriverTripControls(jwt, car, tripId);
                        // return MapScreen();
                      } else {
                        return Scaffold(
                          appBar: AppBar(
                            backgroundColor:
                                const Color.fromRGBO(50, 75, 205, 1),
                            title: const Text("ليس لديك نقلة حالية"),
                            actions: [
                              // Logout Button
                              IconButton(
                                padding: const EdgeInsets.only(right: 15),
                                icon: const Icon(Icons.exit_to_app),
                                onPressed: () {
                                  storage.delete(key: "jwt");
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginScreen()));
                                },
                              ),
                            ],
                          ),
                          body: const Center(
                            child: Text(
                              ".ليس لديك نقلة جارية",
                              style: TextStyle(
                                fontSize: 24,
                              ),
                            ),
                          ),
                        );
                      }
                    }
                  },
                );
              }
            } else {
              return const LoginScreen();
            }
          }),
    );
  }

  // Function That Checks If User Is In A Trip
  Future<Object> get CheckIfInTrip async {
    var jwt = await storage.read(key: "jwt");
    jwt = jsonDecode(jwt!)["jwt"];
    // Define bool
    // print("object");
    var inTrip = false;
    dynamic car;
    dynamic tripId;
    // Get Current Date In The Format Of YYYY-MM-DD
    var currentDate = DateTime.now().toString().substring(0, 10);
    await http
        .post(
      Uri.parse('$SERVER_IP/GetDriverTrip'),
      // Cookie
      headers: {
        "Content-Type": "application/json",
        "Cookie": "jwt=$jwt",
      },
      body: jsonEncode({
        "Date": currentDate,
      }),
    )
        .then((value) {
      var jsonData = jsonDecode(value.body);
      if (jsonData["IsInTrip"] == true) {
        inTrip = true;
        car = jsonData["Trip"];
        tripId = jsonData["TripID"];
        return {"IsInTrip": true, "Car": car, "TripId": tripId};
      } else {
        return {"IsInTrip": false};
      }
    });
    return {"IsInTrip": inTrip, "Car": car, "TripId": tripId};
  }
}
//   Future<bool> CheckIfInTrip(jwt) async {
//     var result = false;
//     http.post(Uri.parse('$SERVER_IP/GetDriverTrip'), headers: {
//       "Cookie": "jwt=$jwt",
//     }).then((value) {
//       var res = jsonDecode(value.body);
//       // print(res["IsInTrip"]);
//       if (res["IsInTrip"] == true) {
//         // print(true);
//         result = true;
//         // print(result);
//       }
//     }).catchError((error) {
//       print(error);
//       return false;
//     });
//     return result;
//   }
// }
