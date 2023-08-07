// ignore_for_file: file_names, depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:falcon_1/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart' as intl;
import 'package:http/http.dart' as http;
import '../Screens/AllDrivers.dart';

class EditDriverScreen extends StatefulWidget {
  const EditDriverScreen({
    Key? key,
    @required this.jwt,
    @required this.driver,
  }) : super(key: key);
  final dynamic driver;

  final String? jwt;

  @override
  State<EditDriverScreen> createState() => _EditDriverScreenState();
}

final _driverNameController = TextEditingController();
final _mobileController = TextEditingController();
// final _emailController = TextEditingController();
// final _passwordController = TextEditingController();
final _licenseExpirationDateController = TextEditingController();
final _idExpirationDateController = TextEditingController();
final _safetyLicenseExpirationDateController = TextEditingController();
final _drugTestExpirationDate = TextEditingController();
var request = http.MultipartRequest(
    "POST", Uri.parse("$SERVER_IP/api/protected/UpdateDriver"));
late BuildContext dialogContext;

late Uint8List idLicenseImgBytes;

late Uint8List idLicenseImgBytesBack;

late Uint8List driverLicenseImgBytes;
// late PlatformFile driverLicenseFileBack;
// late File driverLicenseImgFileBack;
// late Uint8List driverLicenseImgBytesBack;

late Uint8List safetyLicenseImgBytes;
// late PlatformFile safetyLicenseFileBack;
// late File safetyLicenseImgFileBack;
// late Uint8List safetyLicenseImgBytesBack;

late Uint8List drugTestImgBytes;

late Uint8List criminalRecordImgBytes;
// late PlatformFile drugTestFileBack;
// late File drugTestImgFileBack;
// late Uint8List drugTestImgBytesBack;

class _EditDriverScreenState extends State<EditDriverScreen> {
  @override
  void initState() {
    request = http.MultipartRequest(
        "POST", Uri.parse("$SERVER_IP/api/protected/UpdateDriver"));
    _driverNameController.text = widget.driver["name"];
    _mobileController.text = widget.driver["mobile_number"];
    _idExpirationDateController.text =
        widget.driver["id_license_expiration_date"];
    _licenseExpirationDateController.text =
        widget.driver["driver_license_expiration_date"];
    _safetyLicenseExpirationDateController.text =
        widget.driver["safety_license_expiration_date"];
    _drugTestExpirationDate.text = widget.driver["drug_test_expiration_date"];
    // List<dynamic> imageBytesList = [];
    // imageBytesList = widget.imageBytes.entries.map((e) => e.value).toList();
    // if (imageBytesList[0] != null) {
    //   idLicenseImgBytes = imageBytesList[0];
    // }
    // if (imageBytesList[1] != null) {
    //   idLicenseImgBytesBack = imageBytesList[1];
    // }
    // if (imageBytesList[2] != null) {
    //   driverLicenseImgBytes = imageBytesList[2];
    // }
    // if (imageBytesList[3] != null) {
    //   safetyLicenseImgBytes = imageBytesList[3];
    // }
    // if (imageBytesList[4] != null) {
    //   drugTestImgBytes = imageBytesList[4];
    // }
    // if (imageBytesList[5] != null) {
    //   criminalRecordImgBytes = imageBytesList[5];
    // }
    super.initState();
  }

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'Update Driver: ${widget.driver["name"]}',
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
              CupertinoFormSection(
                header: const Text(
                  "Details",
                ),
                children: [
                  CupertinoFormRow(
                    prefix: const Text("Driver Name"),
                    child: CupertinoTextFormFieldRow(
                      controller: _driverNameController,
                      placeholder: "Driver Name*",
                    ),
                  ),
                  CupertinoFormRow(
                    prefix: const Text("Phone Number"),
                    child: CupertinoTextFormFieldRow(
                      controller: _mobileController,
                      placeholder: "Phone Number*",
                    ),
                  ),
                  // CupertinoFormRow(
                  //   prefix: const Text("البريد الألكتروني"),
                  //   child: CupertinoTextFormFieldRow(
                  //     controller: _emailController,
                  //     placeholder: "البريد الألكتروني*",
                  //   ),
                  // ),
                  // CupertinoFormRow(
                  //   prefix: const Text("كلمة المرور"),
                  //   child: CupertinoTextFormFieldRow(
                  //     obscureText: true,
                  //     controller: _passwordController,
                  //     placeholder: "كلمة المرور*",
                  //   ),
                  // ),
                  GestureDetector(
                    onTap: () async {
                      DateTime? pickDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2099));
                      if (pickDate != null) {
                        // final result =
                        //     await FilePicker.platform.pickFiles();
                        // if (result == null) return;
                        // driverLicenseFile = result.files.first;
                        // driverLicenseImgFile =
                        //     File(driverLicenseFile.path!);
                        // driverLicenseImgBytes =
                        //     await CompressFile(driverLicenseImgFile)
                        //         as Uint8List;
                        // await Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (_) => ImagePreview(
                        //               images: driverLicenseImgBytes,
                        //               title: "صورة وجه رخصة القيادة",
                        //             )));
                        // final resultBack =
                        //     await FilePicker.platform.pickFiles();
                        // if (resultBack == null) return;
                        // driverLicenseFileBack =
                        //     resultBack.files.first;
                        // driverLicenseImgFileBack =
                        //     File(driverLicenseFileBack.path!);
                        // driverLicenseImgBytesBack =
                        //     await CompressFile(
                        //             driverLicenseImgFileBack)
                        //         as Uint8List;
                        // await Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (_) => ImagePreview(
                        //               images:
                        //                   driverLicenseImgBytesBack,
                        //               title: "صورة خلف رخصة القيادة",
                        //             )));
                        setState(() {
                          _licenseExpirationDateController.text =
                              intl.DateFormat("yyyy-MM-dd").format(pickDate);
                        });
                      }
                    },
                    child: CupertinoFormRow(
                      prefix: const Row(
                        children: [
                          Icon(Icons.calendar_today),
                          SizedBox(
                            width: 10,
                          ),
                          Text("Driving License Expiration"),
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
                            // final result =
                            //     await FilePicker.platform.pickFiles();
                            // if (result == null) return;
                            // driverLicenseFile = result.files.first;
                            // driverLicenseImgFile =
                            //     File(driverLicenseFile.path!);
                            // driverLicenseImgBytes =
                            //     await CompressFile(
                            //             driverLicenseImgFile)
                            //         as Uint8List;
                            // await Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (_) => ImagePreview(
                            //               images:
                            //                   driverLicenseImgBytes,
                            //               title:
                            //                   "صورة وجه رخصة القيادة",
                            //             )));
                            // final resultBack =
                            //     await FilePicker.platform.pickFiles();
                            // if (resultBack == null) return;
                            // driverLicenseFileBack =
                            //     resultBack.files.first;
                            // driverLicenseImgFileBack =
                            //     File(driverLicenseFileBack.path!);
                            // driverLicenseImgBytesBack =
                            //     await CompressFile(
                            //             driverLicenseImgFileBack)
                            //         as Uint8List;
                            // await Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (_) => ImagePreview(
                            //               images:
                            //                   driverLicenseImgBytesBack,
                            //               title:
                            //                   "صورة خلف رخصة القيادة",
                            //             )));
                            setState(() {
                              _licenseExpirationDateController.text =
                                  intl.DateFormat("yyyy-MM-dd")
                                      .format(pickDate);
                            });
                          }
                        },
                        controller: _licenseExpirationDateController,
                        placeholder: "Driving License Expiration*",
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
                        // final result =
                        //     await FilePicker.platform.pickFiles();
                        // if (result == null) return;
                        // driverLicenseFile = result.files.first;
                        // driverLicenseImgFile =
                        //     File(driverLicenseFile.path!);
                        // driverLicenseImgBytes =
                        //     await CompressFile(driverLicenseImgFile)
                        //         as Uint8List;
                        // await Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (_) => ImagePreview(
                        //               images: driverLicenseImgBytes,
                        //               title: "صورة وجه رخصة القيادة",
                        //             )));
                        // final resultBack =
                        //     await FilePicker.platform.pickFiles();
                        // if (resultBack == null) return;
                        // driverLicenseFileBack =
                        //     resultBack.files.first;
                        // driverLicenseImgFileBack =
                        //     File(driverLicenseFileBack.path!);
                        // driverLicenseImgBytesBack =
                        //     await CompressFile(
                        //             driverLicenseImgFileBack)
                        //         as Uint8List;
                        // await Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (_) => ImagePreview(
                        //               images:
                        //                   driverLicenseImgBytesBack,
                        //               title: "صورة خلف رخصة القيادة",
                        //             )));
                        setState(() {
                          _idExpirationDateController.text =
                              intl.DateFormat("yyyy-MM-dd").format(pickDate);
                        });
                      }
                    },
                    child: CupertinoFormRow(
                      prefix: const Row(
                        children: [
                          Icon(Icons.calendar_today),
                          SizedBox(
                            width: 10,
                          ),
                          Text("Driver ID Expiration"),
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
                            // final result =
                            //     await FilePicker.platform.pickFiles();
                            // if (result == null) return;
                            // driverLicenseFile = result.files.first;
                            // driverLicenseImgFile =
                            //     File(driverLicenseFile.path!);
                            // driverLicenseImgBytes =
                            //     await CompressFile(
                            //             driverLicenseImgFile)
                            //         as Uint8List;
                            // await Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (_) => ImagePreview(
                            //               images:
                            //                   driverLicenseImgBytes,
                            //               title:
                            //                   "صورة وجه رخصة القيادة",
                            //             )));
                            // final resultBack =
                            //     await FilePicker.platform.pickFiles();
                            // if (resultBack == null) return;
                            // driverLicenseFileBack =
                            //     resultBack.files.first;
                            // driverLicenseImgFileBack =
                            //     File(driverLicenseFileBack.path!);
                            // driverLicenseImgBytesBack =
                            //     await CompressFile(
                            //             driverLicenseImgFileBack)
                            //         as Uint8List;
                            // await Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (_) => ImagePreview(
                            //               images:
                            //                   driverLicenseImgBytesBack,
                            //               title:
                            //                   "صورة خلف رخصة القيادة",
                            //             )));
                            setState(() {
                              _idExpirationDateController.text =
                                  intl.DateFormat("yyyy-MM-dd")
                                      .format(pickDate);
                            });
                          }
                        },
                        controller: _idExpirationDateController,
                        placeholder: "Driver ID Expiration*",
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
                        // final result =
                        //     await FilePicker.platform.pickFiles();
                        // if (result == null) return;
                        // safetyLicenseFile = result.files.first;
                        // safetyLicenseImgFile =
                        //     File(safetyLicenseFile.path!);
                        // safetyLicenseImgBytes =
                        //     await CompressFile(safetyLicenseImgFile)
                        //         as Uint8List;
                        // await Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (_) => ImagePreview(
                        //               images: safetyLicenseImgBytes,
                        //               title:
                        //                   "صورة وجه رخصة القيادة الأمنة",
                        //             )));
                        // final resultBack =
                        //     await FilePicker.platform.pickFiles();
                        // if (resultBack == null) return;
                        // safetyLicenseFileBack =
                        //     resultBack.files.first;
                        // safetyLicenseImgFileBack =
                        //     File(safetyLicenseFileBack.path!);
                        // safetyLicenseImgBytesBack =
                        //     await CompressFile(
                        //             safetyLicenseImgFileBack)
                        //         as Uint8List;
                        // await Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (_) => ImagePreview(
                        //               images:
                        //                   safetyLicenseImgBytesBack,
                        //               title:
                        //                   "صورة خلف رخصة القيادة الأمنة",
                        //             )));
                        setState(() {
                          _safetyLicenseExpirationDateController.text =
                              intl.DateFormat("yyyy-MM-dd").format(pickDate);
                        });
                      }
                    },
                    child: CupertinoFormRow(
                      prefix: const Row(
                        children: [
                          Icon(Icons.calendar_today),
                          SizedBox(
                            width: 10,
                          ),
                          Text("Safety Certificate Expiry"),
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
                            // final result =
                            //     await FilePicker.platform.pickFiles();
                            // if (result == null) return;
                            // safetyLicenseFile = result.files.first;
                            // safetyLicenseImgFile =
                            //     File(safetyLicenseFile.path!);
                            // safetyLicenseImgBytes =
                            //     await CompressFile(
                            //             safetyLicenseImgFile)
                            //         as Uint8List;
                            // await Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (_) => ImagePreview(
                            //               images:
                            //                   safetyLicenseImgBytes,
                            //               title:
                            //                   "صورة وجه رخصة القيادة الأمنة",
                            //             )));
                            // final resultBack =
                            //     await FilePicker.platform.pickFiles();
                            // if (resultBack == null) return;
                            // safetyLicenseFileBack =
                            //     resultBack.files.first;
                            // safetyLicenseImgFileBack =
                            //     File(safetyLicenseFileBack.path!);
                            // safetyLicenseImgBytesBack =
                            //     await CompressFile(
                            //             safetyLicenseImgFileBack)
                            //         as Uint8List;
                            // await Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (_) => ImagePreview(
                            //               images:
                            //                   safetyLicenseImgBytesBack,
                            //               title:
                            //                   "صورة خلف رخصة القيادة الأمنة",
                            //             )));
                            setState(() {
                              _safetyLicenseExpirationDateController.text =
                                  intl.DateFormat("yyyy-MM-dd")
                                      .format(pickDate);
                            });
                          }
                        },
                        controller: _safetyLicenseExpirationDateController,
                        placeholder: "Safety Certificate Expiry*",
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
                        // final result =
                        //     await FilePicker.platform.pickFiles();
                        // if (result == null) return;
                        // drugTestFile = result.files.first;
                        // drugTestImgFile = File(drugTestFile.path!);
                        // drugTestImgBytes =
                        //     await CompressFile(drugTestImgFile)
                        //         as Uint8List;
                        // await Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (_) => ImagePreview(
                        //               images: drugTestImgBytes,
                        //               title:
                        //                   "صورة وجه رخصة شهادة المخدرات",
                        //             )));
                        // final resultBack =
                        //     await FilePicker.platform.pickFiles();
                        // if (resultBack == null) return;
                        // drugTestFileBack = resultBack.files.first;
                        // drugTestImgFileBack =
                        //     File(drugTestFileBack.path!);
                        // drugTestImgBytesBack =
                        //     await CompressFile(drugTestImgFileBack)
                        //         as Uint8List;
                        // await Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (_) => ImagePreview(
                        //               images: drugTestImgBytesBack,
                        //               title:
                        //                   "صورة خلف رخصة شهادة المخدرات",
                        //             )));
                        setState(() {
                          _drugTestExpirationDate.text =
                              intl.DateFormat("yyyy-MM-dd").format(pickDate);
                        });
                      }
                    },
                    child: CupertinoFormRow(
                      prefix: const Row(
                        children: [
                          Icon(Icons.calendar_today),
                          SizedBox(
                            width: 10,
                          ),
                          Text("Drug Test Expiry"),
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
                            // final result =
                            //     await FilePicker.platform.pickFiles();
                            // if (result == null) return;
                            // drugTestFile = result.files.first;
                            // drugTestImgFile =
                            //     File(drugTestFile.path!);
                            // drugTestImgBytes =
                            //     await CompressFile(drugTestImgFile)
                            //         as Uint8List;
                            // await Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (_) => ImagePreview(
                            //               images: drugTestImgBytes,
                            //               title:
                            //                   "صورة وجه رخصة شهادة المخدرات",
                            //             )));
                            // final resultBack =
                            //     await FilePicker.platform.pickFiles();
                            // if (resultBack == null) return;
                            // drugTestFileBack = resultBack.files.first;
                            // drugTestImgFileBack =
                            //     File(drugTestFileBack.path!);
                            // drugTestImgBytesBack = await CompressFile(
                            //     drugTestImgFileBack) as Uint8List;
                            // await Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (_) => ImagePreview(
                            //               images:
                            //                   drugTestImgBytesBack,
                            //               title:
                            //                   "صورة خلف رخصة شهادة المخدرات",
                            //             )));
                            setState(() {
                              _drugTestExpirationDate.text =
                                  intl.DateFormat("yyyy-MM-dd")
                                      .format(pickDate);
                            });
                          }
                        },
                        controller: _drugTestExpirationDate,
                        placeholder: "Drug Test Expiry*",
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Center(
              //   child: TextButton(
              //     onPressed: () async {
              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //           builder: (_) => ImageViewUpdateDriver(
              //             images: widget.imageBytes,
              //             name: widget.driver["name"],
              //           ),
              //         ),
              //       );
              //     },
              //     child: const Text(
              //       "Show Photos",
              //     ),
              //   ),
              // ),
              Center(
                // ignore: deprecated_member_use
                child: TextButton(
                  onPressed: () async {
                    if (_driverNameController.text.isEmpty ||
                        _mobileController.text.isEmpty ||
                        _idExpirationDateController.text.isEmpty ||
                        _licenseExpirationDateController.text.isEmpty ||
                        _safetyLicenseExpirationDateController.text.isEmpty ||
                        _drugTestExpirationDate.text.isEmpty) {
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
                      );
                    } else {
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
                      request.headers['Cookie'] = "jwt=${widget.jwt}";
                      request.fields['request'] = jsonEncode(
                        {
                          "ID": widget.driver["ID"],
                          "name": _driverNameController.text,
                          "mobile_number": _mobileController.text,
                          // "permission": "0",
                          "id_license_expiration_date":
                              _idExpirationDateController.text,
                          "driver_license_expiration_date":
                              _licenseExpirationDateController.text,
                          "safety_license_expiration_date":
                              _safetyLicenseExpirationDateController.text,
                          "drug_test_expiration_date":
                              _drugTestExpirationDate.text,
                        },
                      );

                      // if (driverLicenseImgBytes.isNotEmpty) {
                      //   request.files.add(
                      //     http.MultipartFile.fromBytes(
                      //       'DriverLicense',
                      //       driverLicenseImgBytes,
                      //       filename: widget.driver["driver_license_image_name"],
                      //       contentType: MediaType("image", "jpeg"),
                      //     ),
                      //   );
                      // }
                      // if (safetyLicenseImgBytes.isNotEmpty) {
                      //   request.files.add(
                      //     http.MultipartFile.fromBytes(
                      //       'SafetyLicense',
                      //       safetyLicenseImgBytes,
                      //       filename: widget.driver["safety_license_image_name"],
                      //       contentType: MediaType("image", "jpeg"),
                      //     ),
                      //   );
                      // }
                      // if (drugTestImgBytes.isNotEmpty) {
                      //   request.files.add(
                      //     http.MultipartFile.fromBytes(
                      //       'DrugTest',
                      //       drugTestImgBytes,
                      //       filename: widget.driver["drug_test_image_name"],
                      //       contentType: MediaType("image", "jpeg"),
                      //     ),
                      //   );
                      // }
                      // if (idLicenseImgBytes.isNotEmpty) {
                      //   request.files.add(
                      //     http.MultipartFile.fromBytes(
                      //       'IDLicenseFront',
                      //       idLicenseImgBytes,
                      //       filename: widget.driver["id_license_image_name"],
                      //       contentType: MediaType("image", "jpeg"),
                      //     ),
                      //   );
                      // }
                      // if (idLicenseImgBytesBack != []) {
                      //   request.files.add(
                      //     http.MultipartFile.fromBytes(
                      //       'IDLicenseBack',
                      //       idLicenseImgBytesBack,
                      //       filename: widget.driver["id_license_image_name_back"],
                      //       contentType: MediaType("image", "jpeg"),
                      //     ),
                      //   );
                      // }
                      // if (criminalRecordImgBytes.isNotEmpty) {
                      //   request.files.add(
                      //     http.MultipartFile.fromBytes(
                      //       'CriminalRecord',
                      //       criminalRecordImgBytes,
                      //       filename: widget.driver["criminal_record_image_name"],
                      //       contentType: MediaType("image", "jpeg"),
                      //     ),
                      //   );
                      // }

                      // request.files.add(
                      //   http.MultipartFile.fromBytes(
                      //     'DriverLicenseBack',
                      //     driverLicenseImgBytesBack,
                      //     filename:
                      //         "${_driverNameController.text} Driver_License_Back.${driverLicenseFileBack.extension}",
                      //     contentType: MediaType("image", "jpeg"),
                      //   ),
                      // );
                      try {
                        await request.send().then((value) {
                          if (value.statusCode == 200) {
                            //Clear all the fields
                            _driverNameController.clear();
                            _mobileController.clear();
                            // _emailController.clear();
                            // _passwordController.clear();
                            _licenseExpirationDateController.clear();
                            _safetyLicenseExpirationDateController.clear();
                            _drugTestExpirationDate.clear();
                            setState(() {
                              Navigator.pop(dialogContext);
                            });
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: double.infinity,
                                            child: Center(
                                              // Display lottie animation
                                              child: Lottie.asset(
                                                "lottie/Success.json",
                                                height: 300,
                                                width: 300,
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                Navigator.pop(dialogContext);
                                              });
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => AllDrivers(
                                                    jwt: widget.jwt.toString(),
                                                  ),
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
                          } else {
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                              Navigator.pop(dialogContext);
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
                        }).timeout(
                          const Duration(seconds: 10),
                        );
                      } catch (e) {
                        print(e);
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
                                          setState(() {
                                            Navigator.pop(dialogContext);
                                            Navigator.pop(dialogContext);
                                          });
                                          // Navigator.pushReplacement(
                                          //   context,
                                          //   MaterialPageRoute(
                                          //     builder: (_) =>
                                          //         CarProgressScreen(
                                          //       jwt:
                                          //           widget.jwt.toString(),
                                          //     ),
                                          //   ),
                                          // );
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
                    }
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
                      "Update Driver",
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
