// ignore_for_file: file_names

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:falcon_1/Screens/CarProgressScreen.dart';
import 'package:falcon_1/main.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:http_parser/http_parser.dart';

class AddDriver extends StatefulWidget {
  const AddDriver({Key? key, required this.jwt}) : super(key: key);
  final String jwt;
  @override
  State<AddDriver> createState() => _AddDriverState();
}
Dio dio = Dio();
List<String> _transporterList = [];
String? selectedTransporter;

Future<Object> get loadData async {
  if (selectedTransporter == null) {
    var res = await dio.post("$SERVER_IP/api/GetTransporters").then((response) {
      var str = response.data;
      for (var transporter in str) {
        _transporterList.add(transporter);
      }
      selectedTransporter = _transporterList[0];
    });

    return {
      "Transporters": _transporterList,
    };

  }
  return {
    "Transporters": _transporterList,
  };
}

final _driverNameController = TextEditingController();
final _mobileController = TextEditingController();
final _emailController = TextEditingController();
final _passwordController = TextEditingController();
final _licenseExpirationDateController = TextEditingController();
final _safetyLicenseExpirationDateController = TextEditingController();
final _drugTestExpirationDate = TextEditingController();
var request = http.MultipartRequest("POST", Uri.parse("$SERVER_IP/api/RegisterUser"));
late BuildContext dialogContext;
late PlatformFile driverLicenseFile;
late File driverLicenseImgFile;
late Uint8List driverLicenseImgBytes;
late PlatformFile safetyLicenseFile;
late File safetyLicenseImgFile;
late Uint8List safetyLicenseImgBytes;
late PlatformFile drugTestFile;
late File drugTestImgFile;
late Uint8List drugTestImgBytes;

class _AddDriverState extends State<AddDriver> {
  @override
  void initState() {
    dio.options.headers["Cookie"] = "jwt=${widget.jwt}";
    dio.options.headers["Content-Type"] = "application/json";
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'إضافة سائق',
          style: GoogleFonts.josefinSans(
            textStyle: const TextStyle(
              fontSize: 22,
            ),
          ),
        ),
      ),
      body: FutureBuilder(
        future: loadData,
        builder: (context, snapshot)
    {
      if (!snapshot.hasData) {
        return Center(
          // Display lottie animation
          child: Lottie.asset(
            "lottie/SplashScreen.json",
            height: 200,
            width: 200,
          ),
        );
      }
      return SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: <Widget>[
              int.parse(permission) > 1 ?
              Row(
                textDirection: TextDirection.rtl,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    ' :أسم المقاول',
                    style: GoogleFonts.josefinSans(
                      textStyle: const TextStyle(
                        fontSize: 22,
                      ),
                    ),
                  ),
                  DropdownButton<String>(
                    style: const TextStyle(
                      fontSize: 15,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    items: _transporterList.map((item) =>
                        DropdownMenuItem<String>(
                            value: item,
                            child: Text(item))).toList(),
                    value: selectedTransporter,
                    onChanged: (item) => setState(() {
                      selectedTransporter = item;
                    }),
                  ),
                ],
              ) : Container(),
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
                    CupertinoFormRow(
                      prefix: const Text("كلمة المرور"),
                      child: CupertinoTextFormFieldRow(
                        obscureText: true,
                        controller: _passwordController,
                        placeholder: "كلمة المرور*",
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        DateTime? pickDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2099));
                        final result = await FilePicker.platform.pickFiles();
                        if (result == null) return;
                        driverLicenseFile = result.files.first;
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
                            final result = await FilePicker.platform.pickFiles();
                            if (result == null) return;
                            driverLicenseFile = result.files.first;
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
                        final result = await FilePicker.platform.pickFiles();
                        if (result == null) return;
                        safetyLicenseFile = result.files.first;
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
                            final result = await FilePicker.platform.pickFiles();
                            if (result == null) return;
                            safetyLicenseFile = result.files.first;
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
                        final result = await FilePicker.platform.pickFiles();
                        if (result == null) return;
                        drugTestFile = result.files.first;
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
                            final result = await FilePicker.platform.pickFiles();
                            if (result == null) return;
                            drugTestFile = result.files.first;
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
              // Container(
              //   constraints: const BoxConstraints(
              //     maxWidth: 400
              //   ),
              //   padding: const EdgeInsets.only(left: 32, right: 32, top: 10),
              //   alignment: Alignment.center,
              //   child: ElevatedButton(
              //     style: ElevatedButton.styleFrom(
              //       primary: Theme.of(context).primaryColor,
              //     ),
              //     onPressed: () async {
              //       final result = await FilePicker.platform.pickFiles();
              //       if (result == null) return;
              //       driverLicenseFile = result.files.first;
              //     },
              //     child: const Text("Choose File"),
              //   ),
              // ),
              const SizedBox(height: 20),
              Center(
                // ignore: deprecated_member_use
                child: FlatButton(
                  onPressed: () async =>
                  {
                    if (_driverNameController.text.isEmpty ||
                        _mobileController.text.isEmpty ||
                        _emailController.text.isEmpty ||
                        _passwordController.text.isEmpty ||
                        _licenseExpirationDateController.text.isEmpty ||
                        _safetyLicenseExpirationDateController.text.isEmpty ||
                        _drugTestExpirationDate.text.isEmpty)
                      {
                        showCupertinoDialog(
                          context: context,
                          builder: (context) =>
                              CupertinoAlertDialog(
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
                        // request.headers['Content-Type'] = "multipart/form",
                        request.headers['Cookie'] = "jwt=${widget.jwt}",
                        request.fields['request'] = jsonEncode({
                          "name": _driverNameController.text,
                          "email": _emailController.text,
                          "password": _passwordController.text,
                          "mobile_number": _mobileController.text,
                          "permission": "0",
                          "DriverLicenseExpirationDate":
                          _licenseExpirationDateController.text,
                          "SafetyLicenseExpirationDate":
                          _safetyLicenseExpirationDateController.text,
                          "DrugTestExpirationDate":
                          _drugTestExpirationDate.text,
                          "Transporter": selectedTransporter,
                          },
                        ),
                        driverLicenseImgFile = File(driverLicenseFile.path!),
                        driverLicenseImgBytes = await driverLicenseImgFile.readAsBytes(),
                        safetyLicenseImgFile = File(safetyLicenseFile.path!),
                        safetyLicenseImgBytes = await safetyLicenseImgFile.readAsBytes(),
                        drugTestImgFile = File(driverLicenseFile.path!),
                        drugTestImgBytes = await drugTestImgFile.readAsBytes(),
                        request.files.add(http.MultipartFile.fromBytes('DriverLicense', driverLicenseImgBytes, filename: "${_driverNameController.text} Driver_License.${driverLicenseFile.extension}", contentType: MediaType("image", "jpeg"),),),
                        request.files.add(http.MultipartFile.fromBytes('SafetyLicense', safetyLicenseImgBytes, filename: "${_driverNameController.text} Safety_License.${safetyLicenseFile.extension}", contentType: MediaType("image", "jpeg"),),),
                        request.files.add(http.MultipartFile.fromBytes('DrugTest', drugTestImgBytes, filename: "${_driverNameController.text} Drug_Test.${drugTestFile.extension}", contentType: MediaType("image", "jpeg"),),),
                        // await http
                        //     .post(
                        //   Uri.parse("$SERVER_IP/api/RegisterUser"),
                        //   headers: {
                        //     "Content-Type": "application/json",
                        //     "Cookie": "jwt=${widget.jwt}",
                        //   },
                        //   body: jsonEncode(
                        //     {
                        //       "name": _driverNameController.text,
                        //       "email": _emailController.text,
                        //       "password": _passwordController.text,
                        //       "mobile_number": _mobileController.text,
                        //       "permission": "0",
                        //       "DriverLicenseExpirationDate":
                        //       _licenseExpirationDateController.text,
                        //       "SafetyLicenseExpirationDate":
                        //       _safetyLicenseExpirationDateController.text,
                        //       "DrugTestExpirationDate":
                        //       _drugTestExpirationDate.text,
                        //       "Transporter": selectedTransporter,
                        //     },
                        //   ),
                        // )
                  request.send().then((value) {
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
                              builder: (_) =>
                                  CarProgressScreen(
                                    jwt: widget.jwt.toString(),
                                  ),
                            ),
                          );
                        }),
                      },
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme
                          .of(context)
                          .primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    width: 200,
                    height: 50,
                    alignment: Alignment.center,
                    child: const Text(
                      "إضافة السائق",
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
      );
    }
    ),
    );
  }
}
