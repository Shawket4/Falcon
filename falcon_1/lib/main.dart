// ignore_for_file: constant_identifier_names, non_constant_identifier_names, unused_local_variable, deprecated_member_use

import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:falcon_1/Forms/AddFuelEvent.dart';
import 'package:falcon_1/Forms/AddServiceEvent.dart';
import 'package:falcon_1/Forms/GenerateFuelTable.dart';
import 'package:falcon_1/Screens/AllFuelEvents.dart';
import 'package:falcon_1/Screens/AllServiceEvents.dart';
import 'package:falcon_1/Screens/CarProgressScreen.dart';
import 'package:falcon_1/bridge_generated.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_compression/image_compression.dart';
import 'package:lottie/lottie.dart';
import 'Forms/AddCar.dart';
import 'Forms/AddDriver.dart';
import 'Forms/AddTrip.dart';
import 'Forms/GenerateXlsxTable.dart';
import 'Screens/AllCars.dart';
import 'Screens/AllDrivers.dart';
import 'Screens/Login.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart' as bridge;

// const String SERVER_IP = 'http://192.168.1.8:3001';
const String SERVER_IP = 'https://dentex.app:3001';
// const SERVER_IP = 'http://localhost:3001/api';
// const SERVER_IP = 'http://92.205.60.182:3001/api';

var jwt = "";

var brightness = SchedulerBinding.instance.window.platformBrightness;
bool isDarkMode = brightness == Brightness.dark;
late DynamicLibrary lib;

late ApexImpl impl;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid || Platform.isWindows) {
    ByteData data = await rootBundle.load('cert/dentex.pem');
    SecurityContext context = SecurityContext.defaultContext;
    context.setTrustedCertificatesBytes(data.buffer.asUint8List());
  }
  lib = bridge.loadLibForFlutter("libApex.so");
  // lib = DynamicLibrary.process();
  impl = ApexImpl(lib);
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(const MainWidget());
}

int? CurrentIndex = 0;
int selectedBottomIndex = 0;
Future<Uint8List?> CompressFile(File file) async {
  if (Platform.isAndroid || Platform.isIOS) {
    final result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      quality: 30,
    );
    return result;
  } else {
    final input = ImageFile(
      rawBytes: file.readAsBytesSync(),
      filePath: file.path,
    );
    final output = await compressInQueue(ImageFileConfiguration(input: input));
    return output.rawBytes;
  }
}

String permission = "";
String name = "";

Future<Object> getPermission(String jwt) async {
  try {
    Dio dio = Dio();
    dio.options.headers["Cookie"] = "jwt=$jwt";
    dio.options.headers["Content-Type"] = "application/json";
    var res = await dio.post("$SERVER_IP/api/user").then((response) {
      var str = response.data;
      permission = str["permission"].toString();
      name = str["name"];
    }).timeout(
      const Duration(seconds: 4),
    );
  } catch (e) {
    return "Error";
  }
  return {
    "permission": permission,
    "name": name,
  };
}

Future<String> get jwtOrEmpty async {
  try {
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
    }).timeout(
      const Duration(seconds: 4),
    );
    return jwt;
  } catch (e) {
    return "Error";
  }
}

class Palette {
  static MaterialColor primarySwatch = const MaterialColor(
    0xFF466995, // 0% comes in here, this will be color picked if no shade is selected when defining a Color property which doesn’t require a swatch.
    <int, Color>{
      50: Color(0xFF4464AD), //10%
      100: Color(0xFF4464AD), //20%
      200: Color(0xFF4464AD), //30%
      300: Color(0xFF4464AD), //40%
      400: Color(0xFF4464AD), //50%
      500: Color(0xFF4464AD), //60%
      600: Color(0xFF4464AD), //70%
      700: Color(0xFF4464AD), //80%
      800: Color(0xFF4464AD), //90%
      900: Color(0xFF4464AD), //100%
    },
  );
}

class MainWidget extends StatelessWidget {
  const MainWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Falcon',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        focusColor: Colors.black,
        primarySwatch: Palette.primarySwatch,
        // primaryColor:
        //     isDarkMode ? const Color(0xFF00796B) : const Color(0xFF009688),
        primaryColor: const Color(0xFF466995),
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: const Color(0xFF212121),
              displayColor: const Color(0xFF212121),
            ),
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
            } else if (snapshot.data.toString() == "Error") {
              storage.delete(key: 'jwt');
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
                                builder: (_) => const MainWidget(),
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
            }
            if (snapshot.data != "") {
              var str = snapshot.data.toString();
              jwt = jsonDecode(str)["jwt"];
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
                                          builder: (_) => const MainWidget(),
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
                      }
                      // var data =
                      //     json.decode(json.encode(snapshot.data.toString()));
                      // print(data);
                      if (int.parse(permission) >= 3) {
                        return CarProgressScreen(
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
  // const color = Colors.black;
  return Column(
    children: [
      Padding(
        padding:
            const EdgeInsets.only(top: 2.5, bottom: 2.5, right: 10, left: 10),
        child: ListTile(
          onTap: onTap,
          title: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: GoogleFonts.josefinSans(
                textStyle: const TextStyle(
                  // color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    ],
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
      // backgroundColor: Theme.of(context).primaryColor,
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Stack(
            children: [
              Container(
                color: Theme.of(context).primaryColor,
                height: 160,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 75.0),
                child: ListTile(
                  leading: Image.asset(
                    "images/OLA_Logo.png",
                    scale: 1.5,
                  ),
                  trailing: Padding(
                    padding: const EdgeInsets.only(
                      right: 5,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.logout,
                        color: Colors.white,
                        size: 30,
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
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // int.parse(permission) >= 3
          //     ? buildDrawerItem(
          //         title: "الطلبات",
          //         onTap: () {
          //           Navigator.pushReplacement(
          //             context,
          //             MaterialPageRoute(
          //               builder: (_) => ApproveRequestScreen(
          //                 jwt: widget.jwt,
          //               ),
          //             ),
          //           );
          //         })
          //     : Container(),
          const SizedBox(
            height: 2.5,
          ),
          buildDrawerItem(
              title: "Trips",
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
                    builder: (_) => AddCar(jwt: widget.jwt.toString()),
                  ),
                );
              }),
          // int.parse(permission) > 1
          //     ? buildDrawerItem(
          //         title: "إضافة مقاول",
          //         onTap: () {
          //           Navigator.push(
          //             context,
          //             MaterialPageRoute(
          //               builder: (_) => AddTransporter(
          //                 jwt: widget.jwt,
          //               ),
          //             ),
          //           );
          //         },
          //       )
          //     : Container(),
          int.parse(permission) > 1
              ? buildDrawerItem(
                  title: "Add Trip",
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
          int.parse(permission) > 1
              ? buildDrawerItem(
                  title: "Add Service Event",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AddServiceEvent(jwt: widget.jwt.toString()),
                      ),
                    );
                  },
                )
              : Container(),
          int.parse(permission) > 1
              ? buildDrawerItem(
                  title: "Add Fuel Event",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AddFuelEvent(jwt: widget.jwt.toString()),
                      ),
                    );
                  },
                )
              : Container(),
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
                  builder: (_) => AllDrivers(jwt: widget.jwt.toString()),
                ),
              );
            },
          ),
          buildDrawerItem(
            title: "All Service Events",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AllServiceEvents(jwt: widget.jwt.toString()),
                ),
              );
            },
          ),
          buildDrawerItem(
            title: "All Fuel Events",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AllFuelEvents(jwt: widget.jwt.toString()),
                ),
              );
            },
          ),
          buildDrawerItem(
            title: "Extract Fuel Table",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      GenerateFuelTableScreen(jwt: widget.jwt.toString()),
                ),
              );
            },
          ),
          // int.parse(permission) > 1
          //     ? buildDrawerItem(
          //         title: "كل المقاولين",
          //         onTap: () {
          //           Navigator.push(
          //             context,
          //             MaterialPageRoute(
          //               builder: (_) =>
          //                   AllTransporters(jwt: widget.jwt.toString()),
          //             ),
          //           );
          //         },
          //       )
          //     : Container(),
          // int.parse(permission) > 3
          //     ? buildDrawerItem(
          //         title: "الصلاحيات",
          //         onTap: () {
          //           Navigator.push(
          //             context,
          //             MaterialPageRoute(
          //               builder: (_) =>
          //                   PermissionScreen(jwt: widget.jwt.toString()),
          //             ),
          //           );
          //         },
          //       )
          //     : Container(),

          buildDrawerItem(
            title: "Extract Trips Table",
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

class BottomNavigationWidget extends StatefulWidget {
  const BottomNavigationWidget({super.key, required this.jwt});
  final String jwt;
  @override
  State<BottomNavigationWidget> createState() => _BottomNavigationWidgetState();
}

class _BottomNavigationWidgetState extends State<BottomNavigationWidget> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt),
          label: "Trips",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.tire_repair_rounded),
          label: "Service Events",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_gas_station),
          label: "Fuel Events",
        ),
      ],
      currentIndex: selectedBottomIndex,
      selectedItemColor: Theme.of(context).primaryColor,
      iconSize: 28,
      onTap: (int index) => setState(() {
        selectedBottomIndex = index;
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CarProgressScreen(jwt: widget.jwt),
            ),
          );
        } else if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AllServiceEvents(jwt: widget.jwt),
            ),
          );
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AllFuelEvents(jwt: widget.jwt),
            ),
          );
        }
      }),
    );
  }
}
