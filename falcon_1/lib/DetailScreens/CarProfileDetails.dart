// ignore_for_file: file_names, unused_local_variable, deprecated_member_use, use_build_context_synchronously, non_constant_identifier_names

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:falcon_1/DetailScreens/ImageView.dart';
import 'package:falcon_1/EditScreens/EditCar.dart';
import 'package:falcon_1/Screens/CarProgressScreen.dart';
import 'package:falcon_1/main.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'package:falcon_1/Maps/Map.dart';

class CarProfileDetails extends StatefulWidget {
  const CarProfileDetails({Key? key, this.car, required this.jwt})
      : super(key: key);
  final dynamic car;
  final String jwt;
  @override
  State<CarProfileDetails> createState() => _CarProfileDetailsState();
}

class _CarProfileDetailsState extends State<CarProfileDetails> {
  List<dynamic> compartments = [];
  List<dynamic> carDetails = [];
  late BuildContext dialogContext;
  late int Speed;
  late double Latitude;
  late double Longitude;
  Dio dio = Dio();

  @override
  void initState() {
    dio.options.headers["Cookie"] = "jwt=${widget.jwt}";
    dio.options.headers["Content-Type"] = "application/json";
    compartments = widget.car["Compartments"];
    carDetails.add(
      Text(
        "رقم السيارة: ${widget.car["CarNoPlate"]}",
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
    carDetails.add(
      Text(
        "حجم التانك: ${widget.car["TankCapacity"]}",
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
    carDetails.add(
      Text(
        "الرخصه ساريه حتي: ${widget.car["LicenseExpirationDate"]}",
        style: TextStyle(
          color: !DateTime.now()
                  .difference(
                      DateTime.parse(widget.car["LicenseExpirationDate"]))
                  .isNegative
              ? Colors.red
              : Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          overflow: TextOverflow.clip,
        ),
      ),
    );
    carDetails.add(
      Text(
        "رخصة العيار ساريه حتي: ${widget.car["CalibrationExpirationDate"]}",
        style: TextStyle(
          color: !DateTime.now()
                  .difference(
                      DateTime.parse(widget.car["CalibrationExpirationDate"]))
                  .isNegative
              ? Colors.red
              : Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          overflow: TextOverflow.clip,
        ),
      ),
    );
    carDetails.add(
      Text(
        "عدد عيون التانك: ${widget.car["Compartments"].length}",
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
    for (var i = 0; i < compartments.length; i++) {
      carDetails.add(
        Text(
          'حجم العين رقم ${i + 1}: ${compartments[i]}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    imageBytes.clear();
    super.initState();
  }

  bool gpsCompatible = false;
  Map<String, Uint8List> imageBytes = {};

  Future<Object> loadData(String CarNoPlate) async {
    try {
      await dio
          .post("$SERVER_IP/api/GetVehicleStatus",
              data: jsonEncode({
                "CarNoPlate": CarNoPlate,
              }))
          .then((value) {
        // var jsonResponse = json.decode(utf8.decode(value.data));
        if (value.data.toString() == "{message: Car Not Found}") {
          return;
        } else {
          Speed = value.data["Speed"];
          Longitude = double.parse(value.data["Longitude"]);
          Latitude = double.parse(value.data["Latitude"]);
          gpsCompatible = true;
        }
      });

      if (widget.car["CarLicenseImageName"] == "") {
        return "";
      }
      if (widget.car["CarLicenseImageName"] != "") {
        http.Response carLicenseFront = await http.get(
          Uri.parse(
              "$SERVER_IP/CarLicenses/${widget.car["CarLicenseImageName"]}"),
        );
        if (carLicenseFront.statusCode == HttpStatus.ok) {
          final Uint8List carLicenceBytes = carLicenseFront.bodyBytes;
          imageBytes["صورة وجه رخصة السيارة"] = carLicenceBytes;
        }
      }

      if (widget.car["CarLicenseImageNameBack"] != "") {
        http.Response carLicenseBack = await http.get(
          Uri.parse(
              "$SERVER_IP/CarLicenses/${widget.car["CarLicenseImageNameBack"]}"),
        );
        if (carLicenseBack.statusCode == HttpStatus.ok) {
          final Uint8List carLicenceBytesBack = carLicenseBack.bodyBytes;
          imageBytes["صورة خلف رخصة السيارة"] = carLicenceBytesBack;
        }
      }

      if (widget.car["CalibrationLicenseImageName"] != "") {
        http.Response carCalibrationFront = await http.get(
          Uri.parse(
              "$SERVER_IP/CalibrationLicenses/${widget.car["CalibrationLicenseImageName"]}"),
        );
        if (carCalibrationFront.statusCode == HttpStatus.ok) {
          final Uint8List calibrationLicenceBytes =
              carCalibrationFront.bodyBytes;
          imageBytes["صورة وجه شهادة العيار"] = calibrationLicenceBytes;
        }
      }

      if (widget.car["CalibrationLicenseImageNameBack"] != "") {
        http.Response carCalibrationBack = await http.get(
          Uri.parse(
              "$SERVER_IP/CalibrationLicenses/${widget.car["CalibrationLicenseImageNameBack"]}"),
        );
        if (carCalibrationBack.statusCode == HttpStatus.ok) {
          final Uint8List calibrationLicenceBytesBack =
              carCalibrationBack.bodyBytes;
          imageBytes["صورة خلف شهادة العيار"] = calibrationLicenceBytesBack;
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
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadData(widget.car["CarNoPlate"]),
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
                            builder: (_) => CarProfileDetails(
                              car: widget.car,
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
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              actions: <IconButton>[
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditCarScreen(
                          car: widget.car,
                          jwt: widget.jwt,
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
                    var response = await dio
                        .post(
                      "$SERVER_IP/api/DeleteCar",
                      data: jsonEncode(
                        {
                          "CarNoPlate": widget.car["CarNoPlate"],
                        },
                      ),
                    )
                        .then((value) {
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
                ),
              ],
              backgroundColor: Theme.of(context).primaryColor,
              title: Text(
                'تفاصيل السيارة ${widget.car["CarNoPlate"]}',
                textDirection: TextDirection.ltr,
              ),
            ),
            body: ListView(
              shrinkWrap: true,
              children: <Widget>[
                SizedBox(
                  width: double.infinity,
                  height: 250,
                  child: Hero(
                    tag: "Car ${widget.car["CarId"].toString()}",
                    child: const Image(
                      fit: BoxFit.cover,
                      image: AssetImage('images/truck.jpg'),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                gpsCompatible
                    ? Center(
                        child: Text(
                          "السرعة الحالية: ${Speed.toString()}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : Container(),
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
                      itemCount: carDetails.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          child: carDetails[index],
                          padding: const EdgeInsets.all(
                            10,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // widget.car["CarLicenseImageName"] == ""
                //     ? Container()
                //     : Padding(
                //         padding:
                //             const EdgeInsets.only(left: 100.0, right: 100),
                //         child: FlatButton(
                //           onPressed: () async {
                //             Navigator.push(
                //               context,
                //               MaterialPageRoute(
                //                 builder: (_) => ImageView(
                //                   images: imageBytes,
                //                   name: widget.car["CarNoPlate"],
                //                 ),
                //               ),
                //             );
                //           },
                //           child: Container(
                //             width: double.infinity,
                //             height: 50,
                //             decoration: BoxDecoration(
                //               color: Theme.of(context).primaryColor,
                //               borderRadius: BorderRadius.circular(8.0),
                //             ),
                //             child: const Center(
                //               child: Text(
                //                 "Show Photos",
                //                 style: TextStyle(
                //                   fontSize: 20,
                //                   color: Colors.white,
                //                 ),
                //               ),
                //             ),
                //           ),
                //         ),
                //       ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (widget.car["CarLicenseImageName"] != "")
                      GestureDetector(
                        onTap: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ImageView(
                                images: imageBytes,
                                name: widget.car["CarNoPlate"],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 160,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Theme.of(context).primaryColor,
                          ),
                          child: const Center(
                            child: Text(
                              "عرض الصور",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (gpsCompatible)
                      GestureDetector(
                        onTap: () async {
                          MapUtils.openMap(Latitude, Longitude);
                        },
                        child: Container(
                          width: 160,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Theme.of(context).primaryColor,
                          ),
                          child: const Center(
                            child: Text(
                              "فتح الخرائط",
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
                ),
                const SizedBox(
                  height: 15,
                ),
                widget.car["IsApproved"] == 0
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
                              var response = await dio.post(
                                "$SERVER_IP/api/RejectRequest",
                                data: jsonEncode(
                                  {
                                    "TableName": "Cars",
                                    "ColumnIdName": "CarId",
                                    "Id": widget.car["CarId"],
                                  },
                                ),
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
                              var response = await dio.post(
                                "$SERVER_IP/api/ApproveRequest",
                                data: jsonEncode(
                                  {
                                    "TableName": "Cars",
                                    "ColumnIdName": "CarId",
                                    "Id": widget.car["CarId"],
                                  },
                                ),
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
      },
    );
  }
}
