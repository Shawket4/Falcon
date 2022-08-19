// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:falcon_1/Screens/ApproveRequest.dart';
import 'package:falcon_1/Screens/CarProgressScreen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'Screens/Login.dart';

const String SERVER_IP = 'http://92.205.60.182:3001';
// const String SERVER_IP = 'http://localhost:3001';
// const SERVER_IP = 'http://localhost:3001/api';
// const SERVER_IP = 'http://92.205.60.182:3001/api';

void main() {
  runApp(const MainWidget());
}

String permission = "";
String name = "";

Future<Object> getPermission(String jwt) async {
  Dio dio = Dio();
  dio.options.headers["Cookie"] = "jwt=$jwt";
  dio.options.headers["Content-Type"] = "application/json";
  var res = await dio.post("$SERVER_IP/api/user").then((response) {
    var str = response.data;
    print(response.statusCode);
    permission = str["permission"].toString();
    name = str["name"];
  });
  return {
    "permission": permission,
    "name": name,
  };
}
Future<String> get jwtOrEmpty async {
  var jwt = await storage.read(key: "jwt");
  if (jwt == null) {
    await storage.delete(key: "jwt");
    return "";
  }
  var jwt2 = jsonDecode((jwt))["jwt"].toString();
  Dio dio = Dio();
  dio.options.headers["Cookie"] = "jwt=$jwt2";
  dio.options.headers["Content-Type"] = "application/json";
  var res = await dio.post("$SERVER_IP/api/user").then((response) async {
    var str = response.data;
    print(response.statusCode);
    if (response.statusCode == 401) {
    await storage.delete(key: "jwt");
    }
    permission = str["permission"].toString();
    name = str["name"];
  });
  return jwt;
}

class MainWidget extends StatelessWidget {
  const MainWidget({Key? key}) : super(key: key);

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
              var str = snapshot.data.toString();
              var jwt = jsonDecode(str)["jwt"];
              // var jwt = jsonDecode(str)["jwt"];
              if (jwt.length < 3) {
                return const LoginScreen();
              } else {
                // var payload = json.decode(utf8.decode(jwt.codeUnits));
                return FutureBuilder(
                    future: getPermission(jwt),
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
                      // var data =
                      //     json.decode(json.encode(snapshot.data.toString()));
                      // print(data);
                      if (int.parse(permission) >= 3) {
                        return ApproveRequestScreen(
                          jwt: jwt.toString(),
                        );
                      } else if (int.parse(permission) == 2 ||
                          int.parse(permission) == 1) {
                        // print(snapshot.data);
                        return CarProgressScreen(
                          jwt: jwt.toString(),
                        );
                      } else {
                        return const LoginScreen();
                      }
                      //
                    });
              }
            } else {
              return const LoginScreen();
            }
          }),
    );
  }
}
