// ignore_for_file: non_constant_identifier_names, file_names, unused_local_variable, use_build_context_synchronously

import 'dart:convert';

import 'package:falcon_1/DetailScreens/CarProgressDetail.dart';
import 'package:falcon_1/Screens/CarProgressScreen.dart';
import 'package:falcon_1/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class CloseTripConfirmation extends StatefulWidget {
  const CloseTripConfirmation({
    super.key,
    required this.trip,
    required this.jwt,
  });
  final dynamic trip;
  final String jwt;

  @override
  State<CloseTripConfirmation> createState() => _CloseTripConfirmationState();
}

class _CloseTripConfirmationState extends State<CloseTripConfirmation> {
  late BuildContext dialogContext;
  DateTime? start_time;
  DateTime? end_time;
  final DateTime currentDateTime = DateTime.now();
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  @override
  void initState() {
    print(widget.trip.startTime);
    start_time = DateTime(
      currentDateTime.year,
      currentDateTime.month,
      currentDateTime.day,
      currentDateTime.hour,
      currentDateTime.minute,
      currentDateTime.second,
    );
    if (widget.trip.startTime != "" || widget.trip.startTime == null) {
      start_time = DateTime(
        int.parse(
          widget.trip.startTime.substring(6, 10),
        ),
        int.parse(
          widget.trip.startTime.substring(0, 2),
        ),
        int.parse(
          widget.trip.startTime.substring(3, 5),
        ),
        int.parse(
          widget.trip.startTime.substring(13, 15),
        ),
        int.parse(
          widget.trip.startTime.substring(16, 18),
        ),
        int.parse(
          widget.trip.startTime.substring(19, 21),
        ),
      );
    }
    end_time = DateTime(
      currentDateTime.year,
      currentDateTime.month,
      currentDateTime.day,
      currentDateTime.hour,
      currentDateTime.minute,
      currentDateTime.second,
    );
    if (widget.trip.endTime != "") {
      end_time = DateTime(
        int.parse(
          widget.trip.endTime!.substring(6, 10),
        ),
        int.parse(
          widget.trip.endTime!.substring(0, 2),
        ),
        int.parse(
          widget.trip.endTime!.substring(3, 5),
        ),
        int.parse(
          widget.trip.endTime!.substring(13, 15),
        ),
        int.parse(
          widget.trip.endTime!.substring(16, 18),
        ),
        int.parse(
          widget.trip.endTime!.substring(19, 21),
        ),
      );
    }
    _startController.text = start_time.toString();
    _endController.text = end_time.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text("تأكيد اغلاق النقلة"),
      ),
      body: ListView(
        children: [
          const SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: GestureDetector(
              onTap: () async {
                DateTime? pickDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2099));
                if (pickDate != null) {
                  start_time = pickDate;
                }
                TimeOfDay? pickTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                    hour: start_time!.hour,
                    minute: start_time!.minute,
                  ),
                );
                if (pickTime != null) {
                  start_time = DateTime(
                    start_time!.year,
                    start_time!.month,
                    start_time!.day,
                    pickTime.hour,
                    pickTime.minute,
                  );
                }
                setState(() {
                  _startController.text = start_time.toString();
                });
              },
              // child: Text(_startController.text),
              child: TextField(
                enabled: false,
                controller: _startController,
                decoration: const InputDecoration(
                  suffixIcon: Icon(Icons.calendar_today),
                  label: Text("Start *"),
                  disabledBorder: OutlineInputBorder(),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: GestureDetector(
              onTap: () async {
                DateTime? pickDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2099));
                if (pickDate != null) {
                  end_time = pickDate;
                }
                TimeOfDay? pickTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                    hour: end_time!.hour,
                    minute: end_time!.minute,
                  ),
                );
                if (pickTime != null) {
                  end_time = DateTime(
                    end_time!.year,
                    end_time!.month,
                    end_time!.day,
                    pickTime.hour,
                    pickTime.minute,
                  );
                }
                setState(() {
                  _endController.text = end_time.toString();
                });
              },
              // child: Text(_startController.text),
              child: TextField(
                enabled: false,
                controller: _endController,
                decoration: const InputDecoration(
                  suffixIcon: Icon(Icons.calendar_today),
                  label: Text("End *"),
                  disabledBorder: OutlineInputBorder(),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Center(
            // ignore: deprecated_member_use
            child: TextButton(
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
                      "$SERVER_IP/api/CompleteTrip",
                      data: jsonEncode(
                        {
                          "StartTimeFormatted":
                              DateFormat('HH:mm:ss').format(start_time!),
                          "StartTime":
                              DateFormat("hh:mm a").format(start_time!),
                          "StartDateFormatted":
                              DateFormat("MM/dd/yyyy").format(start_time!),
                          "EndTimeFormatted":
                              DateFormat('HH:mm:ss').format(end_time!),
                          "EndTime": DateFormat("hh:mm a").format(end_time!),
                          "EndDateFormatted":
                              DateFormat("MM/dd/yyyy").format(end_time!),
                          "CurrentTime":
                              DateFormat("hh:mm a'").format(DateTime.now()),
                          "TripId": widget.trip.id,
                        },
                      ),
                    )
                    .timeout(
                      const Duration(seconds: 8),
                    );
                setState(() {
                  Navigator.pop(dialogContext);
                  // Rebuild Whole Page
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CarProgressScreen(
                        jwt: widget.jwt,
                      ),
                    ),
                  );
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                width: 200,
                height: 50,
                alignment: Alignment.center,
                child: const Text(
                  "اغلاق النقلة",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
