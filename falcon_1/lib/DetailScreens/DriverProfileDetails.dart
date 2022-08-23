// ignore_for_file: file_names, unrelated_type_equality_checks

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:falcon_1/EditScreens/EditDriver.dart';
import 'package:falcon_1/Screens/CarProgressScreen.dart';
import 'package:falcon_1/main.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
// import 'package:http/http.dart' as http;

class DriverProfileDetails extends StatefulWidget {
  const DriverProfileDetails(
      {Key? key, required this.driver, required this.jwt})
      : super(key: key);
  final dynamic driver;
  final String jwt;
  @override
  State<DriverProfileDetails> createState() => _DriverProfileDetailsState();
}

class _DriverProfileDetailsState extends State<DriverProfileDetails> {
  List<dynamic> driverDetails = [];
  late BuildContext dialogContext;
  Dio dio = Dio();
  @override
  void initState() {
    dio.options.headers["Cookie"] = "jwt=${widget.jwt}";
    dio.options.headers["Content-Type"] = "application/json";
    driverDetails.add(
      Text(
        "أسم السائق: ${widget.driver["Name"]}",
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
    driverDetails.add(
      Text(
        "البريد الالكتروني: ${widget.driver["Email"]}",
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
    driverDetails.add(
      Text(
        "رقم هاتف السائق: ${widget.driver["MobileNumber"]}",
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          overflow: TextOverflow.clip,
        ),
      ),
    );
    driverDetails.add(
      Text(
        "رخصة القيادة ساريه حتي: ${widget.driver["LicenseExpirationDate"]}",
        style: TextStyle(
          color: !DateTime.now()
                  .difference(
                      DateTime.parse(widget.driver["LicenseExpirationDate"]))
                  .isNegative
              ? Colors.red
              : Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          overflow: TextOverflow.clip,
        ),
      ),
    );
    driverDetails.add(
      Text(
        "رخصة القيادة الأمنة ساريه حتي: ${widget.driver["SafetyExpirationDate"]}",
        style: TextStyle(
          color: !DateTime.now()
                  .difference(
                      DateTime.parse(widget.driver["SafetyExpirationDate"]))
                  .isNegative
              ? Colors.red
              : Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
    driverDetails.add(
      Text(
        "شهادة المخضرات ساريه حتي: ${widget.driver["DrugTestExpirationDate"]}",
        style: TextStyle(
          color: !DateTime.now()
                  .difference(
                      DateTime.parse(widget.driver["DrugTestExpirationDate"]))
                  .isNegative
              ? Colors.red
              : Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: <IconButton>[
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      EditDriverScreen(jwt: widget.jwt, driver: widget.driver),
                ),
              );
            },
            icon: const Icon(
              Icons.edit,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () async {
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
              var res = await dio.post("$SERVER_IP/api/DeleteDriver", data:
                jsonEncode(
                  {
                    "Name": widget.driver["Name"],
                  },
                ),
              ).then((value) {
                Navigator.pop(dialogContext);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CarProgressScreen(
                      jwt: widget.jwt.toString(),
                    ),
                  ),
                );
              });
            },

            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
          )
        ],
        backgroundColor: Theme.of(context).primaryColor,
        title: Center(
          child: Text(
            'تفاصيل السائق: ${widget.driver["Name"]}',
            textDirection: TextDirection.rtl,
          ),
        ),
      ),
      body: ListView(
        shrinkWrap: true,
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            height: 250,
            child: Hero(
              tag: "Driver ${widget.driver["DriverId"].toString()}",
              child: const Image(
                fit: BoxFit.cover,
                image: AssetImage('images/driver.png'),
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Container(
            padding: const EdgeInsets.all(15),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: driverDetails.length,
                itemBuilder: (context, index) {
                  return Padding(
                    child: driverDetails[index],
                    padding: const EdgeInsets.all(
                      10,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          widget.driver["IsApproved"] == 0
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () async {
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
                        var res = await dio.post("$SERVER_IP/api/RejectRequest", data:
                          jsonEncode({
                            "TableName": "users",
                            "ColumnIdName": "id",
                            "Id": widget.driver["DriverId"],
                          }),
                        );
                        setState(() {
                          Navigator.pop(dialogContext);
                          // Rebuild Whole Page
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MainWidget(),
                            ),
                          );
                        });
                      },
                      child: Container(
                        width: 160,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.red,
                        ),
                        child: const Center(
                          child: Text(
                            "رفض الطلب",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
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
                        var res = await dio.post("$SERVER_IP/api/ApproveRequest", data:
                          jsonEncode({
                            "TableName": "users",
                            "ColumnIdName": "id",
                            "Id": widget.driver["DriverId"],
                          }),
                        );
                        setState(() {
                          Navigator.pop(dialogContext);
                          // Rebuild Whole Page
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MainWidget(),
                            ),
                          );
                        });
                      },
                      child: Container(
                        width: 160,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.green,
                        ),
                        child: const Center(
                          child: Text(
                            "تأكيد الطلب",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Container(),
          const SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }
}
