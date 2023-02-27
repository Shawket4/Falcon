// ignore_for_file: unused_local_variable, file_names

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:falcon_1/EditScreens/EditServiceEvent.dart';
import 'package:falcon_1/Screens/AllServiceEvents.dart';
import 'package:falcon_1/main.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ServiceDetailsScreen extends StatelessWidget {
  const ServiceDetailsScreen(
      {super.key, required this.event, required this.jwt, required this.dio});
  final ServiceEvent event;
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
                  builder: (_) => EditServiceEvent(
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
                  "$SERVER_IP/api/DeleteServiceEvent",
                  data: jsonEncode(
                    {
                      "ID": event.ServiceId,
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
            'صيانة للعربية ${event.CarNoPlate}',
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
              tag: "Service ${event.ServiceId}",
              child: const Image(
                fit: BoxFit.cover,
                image: AssetImage('images/truck.jpg'),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Center(
            child: Text(
              event.ServiceType,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
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
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "عداد الصيانة: ${event.Odometer}",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // FutureBuilder(
          //   future: loadImage(),
          //   builder: (context, snapshot) {
          //     return Image.network(
          //         "$SERVER_IP/ServiceProofs/${event.ImageName}");
          //   },
          // ),

          // Padding(
          //   padding: const EdgeInsets.all(20.0),
          //   child: Text(
          //     "العداد الحالي: ${event.CurrentOdometer}",
          //     style: const TextStyle(
          //       fontSize: 22,
          //       fontWeight: FontWeight.w500,
          //     ),
          //   ),
          // ),
        ]),
      ),
    );
  }
}
