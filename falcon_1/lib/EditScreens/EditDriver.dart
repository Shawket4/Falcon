// ignore_for_file: file_names

import 'dart:convert';
import 'package:falcon_1/Screens/CarProgressScreen.dart';
import 'package:falcon_1/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart' as intl;
import 'package:http/http.dart' as http;

class EditDriverScreen extends StatefulWidget {
  const EditDriverScreen({Key? key, @required this.jwt, @required this.driver})
      : super(key: key);
  final dynamic driver;
  final String? jwt;

  @override
  State<EditDriverScreen> createState() => _EditDriverScreenState();
}

final _driverNameController = TextEditingController();
final _mobileController = TextEditingController();
final _emailController = TextEditingController();
final _passwordController = TextEditingController();
final _licenseExpirationDateController = TextEditingController();
final _safetyLicenseExpirationDateController = TextEditingController();
final _drugTestExpirationDate = TextEditingController();

late BuildContext dialogContext;

class _EditDriverScreenState extends State<EditDriverScreen> {
  @override
  void initState() {
    _driverNameController.text = widget.driver["Name"];
    _mobileController.text = widget.driver["MobileNumber"];
    _emailController.text = widget.driver["Email"];
    _licenseExpirationDateController.text =
        widget.driver["LicenseExpirationDate"];
    _safetyLicenseExpirationDateController.text =
        widget.driver["SafetyExpirationDate"];
    _drugTestExpirationDate.text = widget.driver["DrugTestExpirationDate"];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'تعديل السائق ${widget.driver["Name"]}',
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
                    "تفاصيل السائق",
                  ),
                  children: [
                    CupertinoFormRow(
                      prefix: const Text("أسم السائق"),
                      child: CupertinoTextFormFieldRow(
                        controller: _driverNameController,
                        placeholder: "أسم السائق*",
                      ),
                    ),
                    CupertinoFormRow(
                      prefix: const Text("رقم الهاتف"),
                      child: CupertinoTextFormFieldRow(
                        controller: _mobileController,
                        placeholder: "رقم الهاتف*",
                      ),
                    ),
                    CupertinoFormRow(
                      prefix: const Text("البريد الألكتروني"),
                      child: CupertinoTextFormFieldRow(
                        controller: _emailController,
                        placeholder: "البريد الألكتروني*",
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
                            _licenseExpirationDateController.text =
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
                            Text("انتهاء رخصة السائق"),
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
                                _licenseExpirationDateController.text =
                                    intl.DateFormat("yyyy-MM-dd")
                                        .format(pickDate);
                              });
                            }
                          },
                          controller: _licenseExpirationDateController,
                          placeholder: "انتهاء رخصة السائق*",
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
                            _safetyLicenseExpirationDateController.text =
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
                            Text("انتهاء رخصة القيادة الأمنة"),
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
                                _safetyLicenseExpirationDateController.text =
                                    intl.DateFormat("yyyy-MM-dd")
                                        .format(pickDate);
                              });
                            }
                          },
                          controller: _safetyLicenseExpirationDateController,
                          placeholder: "انتهاء رخصة القيادة الأمنة*",
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
                            _drugTestExpirationDate.text =
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
                            Text("انتهاء شهادة المخدرات"),
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
                                _drugTestExpirationDate.text =
                                    intl.DateFormat("yyyy-MM-dd")
                                        .format(pickDate);
                              });
                            }
                          },
                          controller: _drugTestExpirationDate,
                          placeholder: "انتهاء شهادة المخدرات*",
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
                    if (_driverNameController.text.isEmpty ||
                        _mobileController.text.isEmpty ||
                        _emailController.text.isEmpty ||
                        _licenseExpirationDateController.text.isEmpty ||
                        _safetyLicenseExpirationDateController.text.isEmpty ||
                        _drugTestExpirationDate.text.isEmpty)
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
                        await http
                            .post(
                          Uri.parse("$SERVER_IP/api/EditDriver"),
                          headers: {
                            "Content-Type": "application/json",
                            "Cookie": "jwt=${widget.jwt}",
                          },
                          body: jsonEncode(
                            {
                              "currentEmail": widget.driver["Email"],
                              "name": _driverNameController.text,
                              "email": _emailController.text,
                              "password": _passwordController.text,
                              "mobile_number": _mobileController.text,
                              // "permission": "0",
                              "driver_license_expiration_date":
                                  _licenseExpirationDateController.text,
                              "safety_license_expiration_date":
                                  _safetyLicenseExpirationDateController.text,
                              "drug_test_expiration_date":
                                  _drugTestExpirationDate.text,
                            },
                          ),
                        )
                            .then((value) {
                          //Clear all the fields
                          _driverNameController.clear();
                          _mobileController.clear();
                          _emailController.clear();
                          _passwordController.clear();
                          _licenseExpirationDateController.clear();
                          _safetyLicenseExpirationDateController.clear();
                          _drugTestExpirationDate.clear();
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
                      "تعديلق السائق",
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
