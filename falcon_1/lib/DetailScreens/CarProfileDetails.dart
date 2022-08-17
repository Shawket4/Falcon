// ignore_for_file: file_names

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:falcon_1/EditScreens/EditCar.dart';
import 'package:falcon_1/Screens/CarProgressScreen.dart';
import 'package:falcon_1/main.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

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
  Dio dio = Dio();

  @override
  void initState() {
    dio.options.headers["Cookie"] = "jwt=${widget.jwt}";
    dio.options.headers["Content-Type"] =
    "application/json";
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
              var response = await dio.post(
                "$SERVER_IP/api/DeleteCar",
                data: jsonEncode(
                  {
                    "CarNoPlate": widget.car["CarNoPlate"],
                  },
                ),
              ).then((value) {
                Navigator.of(context).pop();
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
        backgroundColor: const Color.fromRGBO(50, 75, 205, 1),
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
}
