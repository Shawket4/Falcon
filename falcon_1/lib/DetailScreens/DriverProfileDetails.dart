// ignore_for_file: file_names, unrelated_type_equality_checks, unused_local_variable, deprecated_member_use

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:falcon_1/DriverSalaryScreens/DriverExpenses.dart';
import 'package:falcon_1/DriverSalaryScreens/DriverLoans.dart';
import 'package:falcon_1/DriverSalaryScreens/GetDriverSalary.dart';
import 'package:falcon_1/EditScreens/EditDriver.dart';
import 'package:falcon_1/main.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;

import 'ImageView.dart';

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
  Map<String, Uint8List> imageBytes = {};

  Future<Object> get loadImages async {
    try {
      if (widget.driver["driver_license_image_name"] == "") {
        return "";
      }

      if (widget.driver["id_license_image_name"] != "") {
        http.Response driverLicenseFront = await http.get(
          Uri.parse(
              "$SERVER_IP/IDLicenses/${widget.driver["id_license_image_name"]}"),
        );
        if (driverLicenseFront.statusCode == HttpStatus.ok) {
          final Uint8List driverLicenseBytes = driverLicenseFront.bodyBytes;
          imageBytes["صورة وجه بطاقة السائق"] = driverLicenseBytes;
        }
      }

      if (widget.driver["id_license_image_name_back"] != "") {
        http.Response driverLicenseBack = await http.get(
          Uri.parse(
              "$SERVER_IP/IDLicensesBack/${widget.driver["id_license_image_name_back"]}"),
        );
        if (driverLicenseBack.statusCode == HttpStatus.ok) {
          final Uint8List driverLicenseBytesBack = driverLicenseBack.bodyBytes;
          imageBytes["صورة خلف بطاقة السائق"] = driverLicenseBytesBack;
        }
      }

      if (widget.driver["driver_license_image_name"] != "") {
        http.Response driverLicenseFront = await http.get(
          Uri.parse(
              "$SERVER_IP/DriverLicenses/${widget.driver["driver_license_image_name"]}"),
        );
        if (driverLicenseFront.statusCode == HttpStatus.ok) {
          final Uint8List driverLicenseBytes = driverLicenseFront.bodyBytes;
          imageBytes["صورة وجه رخصة القيادة"] = driverLicenseBytes;
        }
      }

      if (widget.driver["safety_license_image_name"] != "") {
        http.Response safetyLicenseFront = await http.get(
          Uri.parse(
              "$SERVER_IP/SafetyLicenses/${widget.driver["safety_license_image_name"]}"),
        );
        if (safetyLicenseFront.statusCode == HttpStatus.ok) {
          final Uint8List safetyLicenceBytes = safetyLicenseFront.bodyBytes;
          imageBytes["صورة رخصة القيادة الامنة"] = safetyLicenceBytes;
        }
      }

      if (widget.driver["drug_test_image_name"] != "") {
        http.Response drugTestFront = await http.get(
          Uri.parse(
              "$SERVER_IP/DrugTests/${widget.driver["drug_test_image_name"]}"),
        );
        if (drugTestFront.statusCode == HttpStatus.ok) {
          final Uint8List drugTestBytes = drugTestFront.bodyBytes;
          imageBytes["صورة شهادة المخضرات"] = drugTestBytes;
        }
      }
      if (widget.driver["criminal_record_image_name"] != "") {
        http.Response drugTestFront = await http.get(
          Uri.parse(
              "$SERVER_IP/CriminalRecords/${widget.driver["criminal_record_image_name"]}"),
        );
        if (drugTestFront.statusCode == HttpStatus.ok) {
          final Uint8List drugTestBytes = drugTestFront.bodyBytes;
          imageBytes["صورة فيش"] = drugTestBytes;
        }
      }
    } catch (e) {
      return "Error";
    }

    return {
      "Images": imageBytes,
    };
  }

  @override
  void initState() {
    dio.options.headers["Cookie"] = "jwt=${widget.jwt}";
    dio.options.headers["Content-Type"] = "application/json";
    driverDetails.add(
      Text(
        "Name: ${widget.driver["name"]}",
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
    driverDetails.add(
      Text(
        "Phone: ${widget.driver["mobile_number"]}",
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          overflow: TextOverflow.clip,
        ),
      ),
    );

    driverDetails.add(
      Text(
        "ID Expiration: ${widget.driver["id_license_expiration_date"]}",
        style: TextStyle(
          color: DateTime.parse(widget.driver["id_license_expiration_date"])
                  .isBefore(DateTime.now())
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
        "Driving License Expiration: ${widget.driver["driver_license_expiration_date"]}",
        style: TextStyle(
          color: DateTime.parse(widget.driver["driver_license_expiration_date"])
                  .isBefore(DateTime.now())
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
        "Safety License Expiration: ${widget.driver["safety_license_expiration_date"]}",
        style: TextStyle(
          color: DateTime.parse(widget.driver["safety_license_expiration_date"])
                  .isBefore(DateTime.now())
              ? Colors.red
              : Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
    driverDetails.add(
      Text(
        "Drug Test Expiration: ${widget.driver["drug_test_expiration_date"]}",
        style: TextStyle(
          color: DateTime.parse(widget.driver["drug_test_expiration_date"])
                  .isBefore(DateTime.now())
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
    return FutureBuilder(
        future: loadImages,
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
                              builder: (_) => DriverProfileDetails(
                                jwt: widget.jwt,
                                driver: widget.driver,
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
            return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                actions: <IconButton>[
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditDriverScreen(
                            jwt: widget.jwt,
                            driver: widget.driver,
                          ),
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
                      var res = await dio
                          .post(
                        "$SERVER_IP/api/DeleteDriver",
                        data: jsonEncode(
                          {
                            "ID": widget.driver["ID"],
                          },
                        ),
                      )
                          .then((value) {
                        Navigator.pop(dialogContext);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HomeScreen(
                              jwt: widget.jwt.toString(),
                            ),
                          ),
                        );
                      }).timeout(
                        const Duration(seconds: 4),
                      );
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
                    '${widget.driver["name"]}',
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
                      tag: "Driver ${widget.driver["ID"].toString()}",
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DriverExpenses(
                                jwt: widget.jwt,
                                driverName: widget.driver["name"],
                                id: widget.driver["ID"],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 14.0, horizontal: 35.0),
                            child: Text(
                              "Expenses",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DriverLoans(
                                jwt: widget.jwt,
                                id: widget.driver["ID"],
                                driverName: widget.driver["name"],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 14.0, horizontal: 50.0),
                            child: Text(
                              "Loans",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GetDriverSalary(
                            driverID: widget.driver["ID"],
                            jwt: widget.jwt,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        width: double.infinity,
                        height: 52.0,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            "Salaries",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  widget.driver["driver_license_image_name"] == ""
                      ? Container()
                      : Padding(
                          padding:
                              const EdgeInsets.only(left: 100.0, right: 100),
                          child: TextButton(
                            onPressed: () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ImageView(
                                    images: imageBytes,
                                    name: widget.driver["name"],
                                    type: "Driver",
                                    id: widget.driver["ID"],
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: const Center(
                                child: Text(
                                  "Show Photos",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(
                    height: 15,
                  ),
                  widget.driver["is_approved"] == 0
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
                                          borderRadius:
                                              BorderRadius.circular(12.0),
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
                                var res = await dio
                                    .post(
                                      "$SERVER_IP/api/RejectRequest",
                                      data: jsonEncode({
                                        "TableName": "users",
                                        "ColumnIdName": "id",
                                        "Id": widget.driver["ID"],
                                      }),
                                    )
                                    .timeout(
                                      const Duration(seconds: 4),
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
                                          borderRadius:
                                              BorderRadius.circular(12.0),
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
                                var res = await dio
                                    .post(
                                      "$SERVER_IP/api/ApproveRequest",
                                      data: jsonEncode({
                                        "TableName": "users",
                                        "ColumnIdName": "id",
                                        "Id": widget.driver["ID"],
                                      }),
                                    )
                                    .timeout(
                                      const Duration(seconds: 4),
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
        });
  }
}
