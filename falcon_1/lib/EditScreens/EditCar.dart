// ignore_for_file: file_names

import 'dart:convert';

import 'package:falcon_1/Screens/CarProgressScreen.dart';
import 'package:falcon_1/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;

class EditCarScreen extends StatefulWidget {
  const EditCarScreen({Key? key, @required this.car, @required this.jwt})
      : super(key: key);
  final dynamic car;
  final String? jwt;
  @override
  State<EditCarScreen> createState() => _EditCarScreenState();
}

int tankCapacity = 0;
final _carPlateNoController = TextEditingController();
final _compartment1Controller = TextEditingController();
final _compartment2Controller = TextEditingController();
final _compartment3Controller = TextEditingController();
final _compartment4Controller = TextEditingController();
final _licenseExpiryDateController = TextEditingController();
final _calibrationExpiryDateController = TextEditingController();
late BuildContext dialogContext;

class _EditCarScreenState extends State<EditCarScreen> {
  @override
  void initState() {
    _carPlateNoController.text = widget.car["CarNoPlate"];
    // Loop over car["Compartments"] and set the text controllers to the values
    List compartments = widget.car["Compartments"];
    for (int i = 0; i < compartments.length; i++) {
      switch (i) {
        case 0:
          _compartment1Controller.text = compartments[i].toString();
          break;
        case 1:
          _compartment2Controller.text = compartments[i].toString();
          break;
        case 2:
          _compartment3Controller.text = compartments[i].toString();
          break;
        case 3:
          _compartment4Controller.text = compartments[i].toString();
          break;
      }
    }
    _licenseExpiryDateController.text =
        widget.car["LicenseExpirationDate"].toString();
    _calibrationExpiryDateController.text =
        widget.car["CalibrationExpirationDate"].toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          '?????????? ???????????? ?????????????? ${widget.car["CarNoPlate"]}',
          style: GoogleFonts.josefinSans(
            textStyle: const TextStyle(
              fontSize: 22,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: <Widget>[
              Directionality(
                textDirection: TextDirection.rtl,
                child: CupertinoFormSection(
                  header: const Text(
                    "???????????? ??????????????",
                  ),
                  children: [
                    CupertinoFormRow(
                      prefix: const Text("?????? ??????????????"),
                      child: CupertinoTextFormFieldRow(
                        controller: _carPlateNoController,
                        placeholder: "?????? ??????????????*",
                      ),
                    ),
                    CupertinoFormRow(
                      prefix: const Text("?????? ??"),
                      child: CupertinoTextFormFieldRow(
                        controller: _compartment1Controller,
                        placeholder: "?????? ??*",
                      ),
                    ),
                    CupertinoFormRow(
                      prefix: const Text("?????? ??"),
                      child: CupertinoTextFormFieldRow(
                        controller: _compartment2Controller,
                        placeholder: "?????? ??*",
                      ),
                    ),
                    CupertinoFormRow(
                      prefix: const Text("?????? ??"),
                      child: CupertinoTextFormFieldRow(
                        controller: _compartment3Controller,
                        placeholder: "?????? ??*",
                      ),
                    ),
                    CupertinoFormRow(
                      prefix: const Text("?????? ??"),
                      child: CupertinoTextFormFieldRow(
                        controller: _compartment4Controller,
                        placeholder: "?????? ??*",
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        DateTime? pickDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2099));
                        if (pickDate != null) {
                          setState(() {
                            _licenseExpiryDateController.text =
                                intl.DateFormat("yyyy-MM-dd").format(pickDate);
                          });
                        }
                      },
                      child: CupertinoFormRow(
                        prefix: Row(
                          children: const [
                            Icon(Icons.calendar_today),
                            SizedBox(
                              width: 10,
                            ),
                            Text("???????????? ????????????"),
                          ],
                        ),
                        child: CupertinoTextFormFieldRow(
                          onTap: () async {
                            DateTime? pickDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2099));
                            if (pickDate != null) {
                              setState(() {
                                _licenseExpiryDateController.text =
                                    intl.DateFormat("yyyy-MM-dd")
                                        .format(pickDate);
                              });
                            }
                          },
                          controller: _licenseExpiryDateController,
                          placeholder: "???????????? ????????????*",
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        DateTime? pickDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2099));
                        if (pickDate != null) {
                          setState(() {
                            _calibrationExpiryDateController.text =
                                intl.DateFormat("yyyy-MM-dd").format(pickDate);
                          });
                        }
                      },
                      child: CupertinoFormRow(
                        prefix: Row(
                          children: const [
                            Icon(Icons.calendar_today),
                            SizedBox(
                              width: 10,
                            ),
                            Text("???????????? ?????????? ????????????"),
                          ],
                        ),
                        child: CupertinoTextFormFieldRow(
                          onTap: () async {
                            DateTime? pickDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2099));
                            if (pickDate != null) {
                              setState(() {
                                _calibrationExpiryDateController.text =
                                    intl.DateFormat("yyyy-MM-dd")
                                        .format(pickDate);
                              });
                            }
                          },
                          controller: _calibrationExpiryDateController,
                          placeholder: "???????????? ????????????*",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                // ignore: deprecated_member_use
                child: TextButton(
                  onPressed: () async => {
                    if (_carPlateNoController.text.isEmpty ||
                        _compartment1Controller.text.isEmpty ||
                        _licenseExpiryDateController.text.isEmpty ||
                        _calibrationExpiryDateController.text.isEmpty)
                      {
                        showCupertinoDialog(
                          context: context,
                          builder: (context) => CupertinoAlertDialog(
                            title: const Text("??????"),
                            content: const Text("???????? ?????? ???????? ????????????"),
                            actions: <Widget>[
                              CupertinoDialogAction(
                                child: const Text("????????"),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        ),
                      }
                    else
                      {
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
                            }),
                        if (_compartment1Controller.text != "")
                          {
                            tankCapacity +=
                                int.parse(_compartment1Controller.text),
                          },
                        if (_compartment2Controller.text != "")
                          {
                            tankCapacity +=
                                int.parse(_compartment2Controller.text),
                          },
                        if (_compartment3Controller.text != "")
                          {
                            tankCapacity +=
                                int.parse(_compartment3Controller.text),
                          },
                        if (_compartment4Controller.text != "")
                          {
                            tankCapacity +=
                                int.parse(_compartment4Controller.text),
                          },
                        await http
                            .post(
                          Uri.parse("$SERVER_IP/api/EditCar"),
                          headers: {
                            "Content-Type": "application/json",
                            "Cookie": "jwt=${widget.jwt}",
                          },
                          body: jsonEncode(
                            {
                              "CurrentCarNoPlate":
                                  widget.car["CarNoPlate"].toString(),
                              "CarNoPlate":
                                  _carPlateNoController.text.toString(),
                              //Tank Capacity to int
                              "TankCapacity": tankCapacity,
                              "Compartments": <int>[
                                if (_compartment1Controller.text != "")
                                  int.parse(_compartment1Controller.text),
                                if (_compartment2Controller.text != "")
                                  int.parse(_compartment2Controller.text),
                                if (_compartment3Controller.text != "")
                                  int.parse(_compartment3Controller.text),
                                if (_compartment4Controller.text != "")
                                  int.parse(_compartment4Controller.text),
                              ],
                              "LicenseExpirationDate":
                                  _licenseExpiryDateController.text,
                              "CalibrationExpirationDate":
                                  _calibrationExpiryDateController.text,
                            },
                          ),
                        )
                            .then((value) {
                          //Clear all the fields
                          tankCapacity = 0;
                          _carPlateNoController.clear();
                          _compartment1Controller.clear();
                          _compartment2Controller.clear();
                          _compartment3Controller.clear();
                          _compartment4Controller.clear();
                          _licenseExpiryDateController.clear();
                          _calibrationExpiryDateController.clear();

                          Navigator.pop(dialogContext);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CarProgressScreen(
                                jwt: widget.jwt.toString(),
                              ),
                            ),
                          );
                        }),
                      },
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
                      "?????????? ??????????????",
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
            // Get Current Date in the format of YYYY-MM-DD
          ),
        ),
      ),
    );
  }
}
