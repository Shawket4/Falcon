// ignore_for_file: constant_identifier_names, non_constant_identifier_names, unused_local_variable

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:falcon_1/Screens/ApproveRequest.dart';
import 'package:falcon_1/Screens/CarProgressScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'Forms/AddCar.dart';
import 'Forms/AddDriver.dart';
import 'Forms/AddTransporter.dart';
import 'Forms/AddTrip.dart';
import 'Forms/GenerateXlsxTable.dart';
import 'Maps/Map.dart';
import 'Screens/AllCars.dart';
import 'Screens/AllDrivers.dart';
import 'Screens/AllTransporters.dart';
import 'Screens/Login.dart';
import 'Screens/PermissionScreen.dart';
import 'package:http/http.dart' as http;

const String SERVER_IP = 'http://92.205.60.182:3001';
// const String SERVER_IP = 'http://localhost:3001';
// const SERVER_IP = 'http://localhost:3001/api';
// const SERVER_IP = 'http://92.205.60.182:3001/api';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(const MainWidget());
}

int? CurrentIndex = 0;

Future<Uint8List?> CompressFile(File file) async {
  final result = await FlutterImageCompress.compressWithFile(
    file.absolute.path,
    quality: 30,
  );
  return result;
}

String permission = "";
String name = "";

Future<Object> getPermission(String jwt) async {
  Dio dio = Dio();
  dio.options.headers["Cookie"] = "jwt=$jwt";
  dio.options.headers["Content-Type"] = "application/json";
  var res = await dio.post("$SERVER_IP/api/user").then((response) {
    var str = response.data;
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
    if (response.statusCode == 401) {
      await storage.delete(key: "jwt");
    }
    permission = str["permission"].toString();
    name = str["name"];
  });
  return jwt;
}

class Palette {
  static const MaterialColor primarySwatch = MaterialColor(
    0xFF183BA0, // 0% comes in here, this will be color picked if no shade is selected when defining a Color property which doesn’t require a swatch.
    <int, Color>{
      50: Color(0xFF2f4faa), //10%
      100: Color(0xFF4662b3), //20%
      200: Color(0xFF5d76bd), //30%
      300: Color(0xFF7489c6), //40%
      400: Color(0xFF8c9dd0), //50%
      500: Color(0xFFa3b1d9), //60%
      600: Color(0xFFbac4e3), //70%
      700: Color(0xFFd1d8ec), //80%
      800: Color(0xFFe8ebf6), //90%
      900: Color(0xFFffffff), //100%
    },
  );
}

class MainWidget extends StatelessWidget {
  const MainWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Authentication Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Palette.primarySwatch,
        primaryColor: const Color(0xFF183BA0),
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

Widget buildDrawerItem({
  // required IconData icon,
  required String title,
  required void Function() onTap,
}) {
  const color = Colors.white;
  return Padding(
    padding: const EdgeInsets.only(top: 2.5, bottom: 2.5, right: 10, left: 10),
    child: ListTile(
      onTap: onTap,
      title: Align(
        alignment: Alignment.centerRight,
        child: Text(
          title,
          style: GoogleFonts.josefinSans(
            textStyle: const TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    ),
  );
}

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key, required this.jwt}) : super(key: key);
  final String jwt;
  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
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
          int.parse(permission) >= 3
              ? buildDrawerItem(
                  title: "الطلبات",
                  onTap: () {
                    Navigator.pushReplacement(
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
              title: "النقلات",
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CarProgressScreen(
                      jwt: widget.jwt.toString(),
                    ),
                  ),
                );
              }),
          buildDrawerItem(
              title: "إضافة سائق",
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
              title: "إضافة سيارة",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddCar(jwt: widget.jwt.toString()),
                  ),
                );
              }),
          int.parse(permission) > 1
              ? buildDrawerItem(
                  title: "إضافة مقاول",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddTransporter(
                          jwt: widget.jwt,
                        ),
                      ),
                    );
                  },
                )
              : Container(),
          int.parse(permission) > 1
              ? buildDrawerItem(
                  title: "إضافة نقلة",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NewCarTripScreen(widget.jwt.toString()),
                      ),
                    );
                  },
                )
              : Container(),
          buildDrawerItem(
            title: int.parse(permission) > 1
                ? "كل السيارات"
                : "السيارات الخاصة بي",
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
            title: int.parse(permission) > 1
                ? "كل السائقين"
                : "السائقين الخاصة بي",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AllDrivers(jwt: widget.jwt.toString()),
                ),
              );
            },
          ),
          int.parse(permission) > 1
              ? buildDrawerItem(
                  title: "كل المقاولين",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AllTransporters(jwt: widget.jwt.toString()),
                      ),
                    );
                  },
                )
              : Container(),
          int.parse(permission) > 3
              ? buildDrawerItem(
                  title: "الصلاحيات",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            PermissionScreen(jwt: widget.jwt.toString()),
                      ),
                    );
                  },
                )
              : Container(),
          buildDrawerItem(
              title: "الخريطة",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MapScreen(
                      jwt: widget.jwt,
                    ),
                  ),
                );
              }),
          buildDrawerItem(
            title: "Excel استخراج جدول",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GenerateTableScreen(
                    jwt: widget.jwt,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
