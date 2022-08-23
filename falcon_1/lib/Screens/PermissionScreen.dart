// ignore_for_file: file_names

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:falcon_1/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

List<dynamic> users = [];
Dio dio = Dio();
Future<Object> loadData(String jwt) async {
  var res = await dio.post("$SERVER_IP/api/GetNonDriverUsers").then((response) {
    users = response.data["Users"];
  });
  return {
    "Users": users,
  };
}

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({Key? key, required this.jwt}) : super(key: key);
  final String jwt;
  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  late BuildContext dialogContext;
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
        title: Text(
          'الصلاحيات',
          style: GoogleFonts.josefinSans(
            textStyle: const TextStyle(
              fontSize: 22,
            ),
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        // Hamburger Menu
      ),
      body: FutureBuilder(
        future: loadData(widget.jwt),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            //Return a listtile check list of users
            return Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 50,
                  color: Colors.black,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Write Permission',
                        style: GoogleFonts.josefinSans(
                          textStyle: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        users[index]["Name"],
                        style: GoogleFonts.josefinSans(
                          textStyle: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                      trailing: Checkbox(
                        value: users[index]["Permission"] >= 3 ? true : false,
                        onChanged: (value) async {
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) {
                                dialogContext = context;
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: SizedBox(
                                    height: 400,
                                    width: double.infinity,
                                    child: Center(
                                      // Display lottie animation
                                      child: Lottie.asset(
                                        "lottie/SplashScreen.json",
                                        height: 200,
                                        width: 200,
                                      ),
                                    ),
                                  ),
                                );
                              });

                          await http.post(
                            Uri.parse("$SERVER_IP/api/UpdateTempPermission"),
                            headers: {
                              "Content-Type": "application/json",
                              "Cookie": "jwt=${widget.jwt}",
                            },
                            body: jsonEncode(
                              {
                                "Id": users[index]["Id"],
                              },
                            ),
                          );
                          setState(() {
                            Navigator.pop(dialogContext);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PermissionScreen(
                                  jwt: widget.jwt,
                                ),
                              ),
                            );
                          });
                        },
                      ),
                    );
                  },
                ),
              ],
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
        },
      ),
    );
  }
}
