// ignore_for_file: file_names

import 'dart:convert';

import 'package:falcon_1/Screens/CarProgressScreen.dart';
import 'package:falcon_1/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;
import 'package:lottie/lottie.dart';

class AddCar extends StatefulWidget {
  const AddCar({Key? key, required this.jwt}) : super(key: key);
  final String jwt;
  @override
  State<AddCar> createState() => _AddCarState();
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

class _AddCarState extends State<AddCar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(50, 75, 205, 1),
        title: Text(
          'إضافة سيارة',
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
                    "تفاصيل السيارة",
                  ),
                  children: [
                    CupertinoFormRow(
                      prefix: const Text("رقم السيارة"),
                      child: CupertinoTextFormFieldRow(
                        controller: _carPlateNoController,
                        placeholder: "رقم السيارة*",
                      ),
                    ),
                    CupertinoFormRow(
                      prefix: const Text("عين ١"),
                      child: CupertinoTextFormFieldRow(
                        controller: _compartment1Controller,
                        placeholder: "عين ١*",
                      ),
                    ),
                    CupertinoFormRow(
                      prefix: const Text("عين ٢"),
                      child: CupertinoTextFormFieldRow(
                        controller: _compartment2Controller,
                        placeholder: "عين ٢*",
                      ),
                    ),
                    CupertinoFormRow(
                      prefix: const Text("عين ٣"),
                      child: CupertinoTextFormFieldRow(
                        controller: _compartment3Controller,
                        placeholder: "عين ٣*",
                      ),
                    ),
                    CupertinoFormRow(
                      prefix: const Text("عين ٤"),
                      child: CupertinoTextFormFieldRow(
                        controller: _compartment4Controller,
                        placeholder: "عين ٤*",
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
                            Text("أنتهاء الرخصة"),
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
                          placeholder: "أنتهاء الرخصة*",
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
                            Text("أنتهاء شهادة العيار"),
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
                          placeholder: "أنتهاء الرخصة*",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                // ignore: deprecated_member_use
                child: FlatButton(
                  onPressed: () async => {
                    if (_carPlateNoController.text.isEmpty ||
                        _compartment1Controller.text.isEmpty ||
                        _licenseExpiryDateController.text.isEmpty ||
                        _calibrationExpiryDateController.text.isEmpty)
                      {
                        showCupertinoDialog(
                          context: context,
                          builder: (context) => CupertinoAlertDialog(
                            title: const Text("خطأ"),
                            content: const Text("يرجى ملء جميع الحقول"),
                            actions: <Widget>[
                              CupertinoDialogAction(
                                child: const Text("حسنا"),
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
                          Uri.parse("$SERVER_IP/api/RegisterCar"),
                          headers: {
                            "Content-Type": "application/json",
                            "Cookie": "jwt=${widget.jwt}"
                          },
                          body: jsonEncode(
                            {
                              "CarNoPlate": _carPlateNoController.text,
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

                          Navigator.of(context).pop();
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
                      color: const Color.fromRGBO(50, 75, 205, 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    width: 200,
                    height: 50,
                    alignment: Alignment.center,
                    child: const Text(
                      "إضافة السيارة",
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