// ignore_for_file: unused_local_variable, file_names

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:falcon_1/EditScreens/EditFuelEvent.dart';
import 'package:falcon_1/Screens/AllServiceEvents.dart';
import 'package:falcon_1/main.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../Screens/AllFuelEvents.dart';

class FuelEventDetailsScreen extends StatelessWidget {
  const FuelEventDetailsScreen(
      {super.key, required this.event, required this.jwt, required this.dio});
  final FuelEvent event;
  final String jwt;
  final Dio dio;
  @override
  Widget build(BuildContext context) {
    late BuildContext dialogContext;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: <IconButton>[
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditFuelEvent(
                    jwt: jwt,
                    event: event,
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
              try {
                var res = await dio
                    .post(
                  "$SERVER_IP/api/protected/DeleteFuelEvent",
                  data: jsonEncode(
                    {
                      "id": event.EventId,
                    },
                  ),
                )
                    .then((value) {
                  Navigator.pop(dialogContext);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AllServiceEvents(
                        jwt: jwt.toString(),
                      ),
                    ),
                  );
                }).timeout(
                  const Duration(seconds: 4),
                );
              } catch (e) {
                Navigator.pop(dialogContext);
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
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const MainWidget(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Close",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    });
              }
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
            'تفويلة للعربية ${event.CarNoPlate}',
            textDirection: TextDirection.rtl,
          ),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(shrinkWrap: true, children: <Widget>[
          SizedBox(
            width: double.infinity,
            height: 250,
            child: Hero(
              tag: "Fuel ${event.EventId}",
              child: const Image(
                fit: BoxFit.cover,
                image: AssetImage('images/truck.jpg'),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                "معدل الاستخدام: ${event.FuelRate}",
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                "السعر: ${event.Price} EGP",
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "التاريخ: ${event.Date}",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "سعر اللتر: ${event.PricePerLiter} EGP",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "عدد الاترات: ${event.Liters}",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "عدد الكيلو مترات: ${event.OdometerAfter - event.OdometerBefore}",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "عداد التفويلة الماضية: ${event.OdometerBefore}",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "العداد الحالي: ${event.OdometerAfter}",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
