// ignore_for_file: file_names, depend_on_referenced_packages, unused_local_variable, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:falcon_1/DetailScreens/ImagePreview.dart';
import 'package:falcon_1/main.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

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
  if (_transporterList.isEmpty) {
    selectedTransporter = null;
    if (selectedTransporter == null) {
      try {
        var res =
            await dio.post("$SERVER_IP/api/GetTransporters").then((response) {
          var str = response.data;
          for (var transporter in str) {
            _transporterList.add(transporter);
          }
          selectedTransporter = _transporterList[0];
        }).timeout(
          const Duration(seconds: 4),
        );
      } catch (e) {
        return "Error";
      }
    }
  }
  return {
    "Transporters": _transporterList,
  };
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
    "POST", Uri.parse("$SERVER_IP/api/protected/RegisterDriver"));
late BuildContext dialogContext;
late PlatformFile idLicenseFile;
late File idLicenseImgFile;
late Uint8List idLicenseImgBytes;
late PlatformFile idLicenseFileBack;
late File idLicenseImgFileBack;
late Uint8List idLicenseImgBytesBack;
late PlatformFile driverLicenseFile;
late File driverLicenseImgFile;
late Uint8List driverLicenseImgBytes;
// late PlatformFile driverLicenseFileBack;
// late File driverLicenseImgFileBack;
// late Uint8List driverLicenseImgBytesBack;
late PlatformFile safetyLicenseFile;
late File safetyLicenseImgFile;
late Uint8List safetyLicenseImgBytes;
// late PlatformFile safetyLicenseFileBack;
// late File safetyLicenseImgFileBack;
// late Uint8List safetyLicenseImgBytesBack;
late PlatformFile drugTestFile;
late File drugTestImgFile;
late Uint8List drugTestImgBytes;
late PlatformFile criminalRecordFile;
late File criminalRecordImgFile;
late Uint8List criminalRecordImgBytes;
// late PlatformFile drugTestFileBack;
// late File drugTestImgFileBack;
// late Uint8List drugTestImgBytesBack;

class _AddDriverState extends State<AddDriver> {
  int currentStep = 0;
  bool isImagesLoaded = false;
  @override
  void initState() {
    // selectedTransporter = "أسم المقاول";
    _driverNameController.clear();
    _mobileController.clear();
    _licenseExpirationDateController.clear();
    _idExpirationDateController.clear();
    _safetyLicenseExpirationDateController.clear();
    _drugTestExpirationDate.clear();
    currentStep = 0;
    isImagesLoaded = false;
    request = http.MultipartRequest(
        "POST", Uri.parse("$SERVER_IP/api/protected/RegisterDriver"));
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
          'Add Driver',
          style: GoogleFonts.josefinSans(
            textStyle: const TextStyle(
              fontSize: 22,
            ),
          ),
        ),
      ),
      body: FutureBuilder(
          future: loadData,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                // Display lottie animation
                child: Lottie.asset(
                  "lottie/SplashScreen.json",
                  height: 200,
                  width: 200,
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
                            Navigator.pop(dialogContext);
                            Navigator.pop(dialogContext);
                            // Navigator.pushReplacement(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (_) => AddDriver(
                            //       jwt: widget.jwt,
                            //     ),
                            //   ),
                            // );
                          },
                          icon: const Icon(Icons.refresh),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return Container(
                padding: const EdgeInsets.all(20),
                child: ListView(
                  children: <Widget>[
                    int.parse(permission) > 1
                        ? Column(
                            children: [
                              int.parse(permission) == 2
                                  ? Container()
                                  : DropdownSearch<String>(
                                      dropdownSearchDecoration:
                                          const InputDecoration(
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(),
                                        ),
                                        labelText: "Transporter Name*",
                                      ),
                                      mode: Mode.MENU,
                                      showSelectedItems: true,
                                      showSearchBox: true,
                                      enabled: true,
                                      items: _transporterList,
                                      selectedItem: selectedTransporter,
                                      onChanged: (item) => setState(() {
                                        selectedTransporter = item as String;
                                      }),
                                    ),
                              const SizedBox(
                                height: 15,
                              )
                            ],
                          )
                        : Container(),
                    CupertinoFormSection(
                      header: const Text(
                        "Driver Details",
                      ),
                      children: [
                        CupertinoFormRow(
                          prefix: const Text("Name"),
                          child: CupertinoTextFormFieldRow(
                            controller: _driverNameController,
                            placeholder: "Driver Name*",
                          ),
                        ),
                        CupertinoFormRow(
                          prefix: const Text("Phone"),
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
                                    intl.DateFormat("yyyy-MM-dd")
                                        .format(pickDate);
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
                                Text("Driving License Expiry"),
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
                              // placeholder: "انتهاء رخصة السائق*",
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
                                    intl.DateFormat("yyyy-MM-dd")
                                        .format(pickDate);
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
                              // placeholder: "انتهاء بطاقة السائق*",
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
                                    intl.DateFormat("yyyy-MM-dd")
                                        .format(pickDate);
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
                                    _safetyLicenseExpirationDateController
                                            .text =
                                        intl.DateFormat("yyyy-MM-dd")
                                            .format(pickDate);
                                  });
                                }
                              },
                              controller:
                                  _safetyLicenseExpirationDateController,
                              // placeholder: "انتهاء رخصة القيادة الأمنة*",
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
                                    intl.DateFormat("yyyy-MM-dd")
                                        .format(pickDate);
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
                              // placeholder: "انتهاء شهادة المخدرات*",
                            ),
                          ),
                        ),
                      ],
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
                    // Stepper(
                    //   currentStep: currentStep,
                    //   controlsBuilder:
                    //       (BuildContext context, ControlsDetails details) {
                    //     return Row(
                    //       children: <Widget>[
                    //         !isImagesLoaded
                    //             ? TextButton(
                    //                 onPressed: details.onStepContinue,
                    //                 child: Container(
                    //                   decoration: BoxDecoration(
                    //                     color: Theme.of(context).primaryColor,
                    //                     borderRadius: BorderRadius.circular(4),
                    //                   ),
                    //                   child: const Padding(
                    //                     padding: EdgeInsets.all(12.0),
                    //                     child: Center(
                    //                       child: Text(
                    //                         'CONTINUE',
                    //                         style: TextStyle(
                    //                           color: Colors.white,
                    //                           fontWeight: FontWeight.bold,
                    //                         ),
                    //                       ),
                    //                     ),
                    //                   ),
                    //                 ),
                    //               )
                    //             : const Text(""),
                    //       ],
                    //     );
                    //   },
                    //   steps: getSteps(),
                    //   physics: const ClampingScrollPhysics(),
                    //   onStepContinue: () async {
                    //     late bool isFinished;
                    //     if (currentStep == 0) {
                    //       isFinished = await idPick();
                    //     } else if (currentStep == 1) {
                    //       isFinished = await driverLicensePick();
                    //     } else if (currentStep == 2) {
                    //       isFinished = await safetyLicensePick();
                    //     } else if (currentStep == 3) {
                    //       isFinished = await drugTestPick();
                    //     } else if (currentStep == 4) {
                    //       isFinished = await criminalRecordPick();
                    //       isImagesLoaded = true;
                    //       setState(() {});
                    //       return;
                    //     }
                    //     if (isFinished) {
                    //       setState(() {
                    //         currentStep++;
                    //       });
                    //     }
                    //   },
                    // ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () async {
                        if (_driverNameController.text.isEmpty ||
                            _mobileController.text.isEmpty ||
                            _licenseExpirationDateController.text.isEmpty ||
                            _safetyLicenseExpirationDateController
                                .text.isEmpty ||
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
                          // request.headers['Content-Type'] = "multipart/form",
                          request.headers['Cookie'] = "jwt=${widget.jwt}";
                          request.fields['request'] = jsonEncode(
                            {
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
                              "transporter": int.parse(permission) == 2
                                  ? ""
                                  : selectedTransporter,
                            },
                          );
                          // request.files.add(
                          //   http.MultipartFile.fromBytes(
                          //     'DriverLicense',
                          //     driverLicenseImgBytes,
                          //     filename:
                          //         "${_driverNameController.text} Driver_License.${driverLicenseFile.extension}",
                          //     contentType: MediaType("image", "jpeg"),
                          //   ),
                          // );
                          // request.files.add(
                          //   http.MultipartFile.fromBytes(
                          //     'SafetyLicense',
                          //     safetyLicenseImgBytes,
                          //     filename:
                          //         "${_driverNameController.text} Safety_License.${safetyLicenseFile.extension}",
                          //     contentType: MediaType("image", "jpeg"),
                          //   ),
                          // );
                          // request.files.add(
                          //   http.MultipartFile.fromBytes(
                          //     'DrugTest',
                          //     drugTestImgBytes,
                          //     filename:
                          //         "${_driverNameController.text} Drug_Test.${drugTestFile.extension}",
                          //     contentType: MediaType("image", "jpeg"),
                          //   ),
                          // );
                          // // request.files.add(
                          // //   http.MultipartFile.fromBytes(
                          // //     'DriverLicenseBack',
                          // //     driverLicenseImgBytesBack,
                          // //     filename:
                          // //         "${_driverNameController.text} Driver_License_Back.${driverLicenseFileBack.extension}",
                          // //     contentType: MediaType("image", "jpeg"),
                          // //   ),
                          // // );

                          // request.files.add(
                          //   http.MultipartFile.fromBytes(
                          //     'IDLicenseFront',
                          //     idLicenseImgBytes,
                          //     filename:
                          //         "${_driverNameController.text} ID_License.${idLicenseFile.extension}",
                          //     contentType: MediaType("image", "jpeg"),
                          //   ),
                          // );

                          // request.files.add(
                          //   http.MultipartFile.fromBytes(
                          //     'IDLicenseBack',
                          //     idLicenseImgBytesBack,
                          //     filename:
                          //         "${_driverNameController.text} ID_License_Back.${idLicenseFileBack.extension}",
                          //     contentType: MediaType("image", "jpeg"),
                          //   ),
                          // );

                          // request.files.add(
                          //   http.MultipartFile.fromBytes(
                          //     'CriminalRecord',
                          //     criminalRecordImgBytes,
                          //     filename:
                          //         "${_driverNameController.text} Criminal_Records.${criminalRecordFile.extension}",
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
                                          borderRadius:
                                              BorderRadius.circular(12.0),
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
                                                    Navigator.pop(
                                                        dialogContext);
                                                  });
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          HomeScreen(
                                                        jwt: widget.jwt
                                                            .toString(),
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
                                          borderRadius:
                                              BorderRadius.circular(12.0),
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
                              const Duration(seconds: 30),
                            );
                          } catch (e) {
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
                          "Register Driver",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                  // Get Current Date in the format of YYYY-MM-DD
                ),
              );
            }
          }),
    );
  }

  Future<bool> idPick() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return false;
    idLicenseFile = result.files.single;
    idLicenseImgFile = File(idLicenseFile.path!);
    idLicenseImgBytes = await CompressFile(idLicenseImgFile) as Uint8List;
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ImagePreview(
                  images: idLicenseImgBytes,
                  title: "صورة وجه بطاقة السائق",
                )));
    final resultBack = await FilePicker.platform.pickFiles();
    if (resultBack == null) return false;
    idLicenseFileBack = resultBack.files.single;
    idLicenseImgFileBack = File(idLicenseFileBack.path!);
    idLicenseImgBytesBack =
        await CompressFile(idLicenseImgFileBack) as Uint8List;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImagePreview(
          images: idLicenseImgBytesBack,
          title: "صورة خلف بطاقة السائق",
        ),
      ),
    );
    return true;
  }

  Future<bool> driverLicensePick() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return false;
    driverLicenseFile = result.files.single;
    driverLicenseImgFile = File(driverLicenseFile.path!);
    driverLicenseImgBytes =
        await CompressFile(driverLicenseImgFile) as Uint8List;
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ImagePreview(
                  images: driverLicenseImgBytes,
                  title: "صورة رخصة القيادة",
                )));
    // final resultBack = await FilePicker.platform.pickFiles();
    // if (resultBack == null) return false;
    // driverLicenseFileBack = resultBack.files.single;
    // driverLicenseImgFileBack = File(driverLicenseFileBack.path!);
    // driverLicenseImgBytesBack =
    //     await CompressFile(driverLicenseImgFileBack) as Uint8List;
    // await Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (_) => ImagePreview(
    //               images: driverLicenseImgBytesBack,
    //               title: "صورة خلف رخصة القيادة",
    //             )));
    return true;
  }

  Future<bool> safetyLicensePick() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return false;
    safetyLicenseFile = result.files.single;
    safetyLicenseImgFile = File(safetyLicenseFile.path!);
    safetyLicenseImgBytes =
        await CompressFile(safetyLicenseImgFile) as Uint8List;
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ImagePreview(
                  images: safetyLicenseImgBytes,
                  title: "صورة وجه رخصة القيادة الأمنة",
                )));
    return true;
  }

  Future<bool> drugTestPick() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return false;
    drugTestFile = result.files.single;
    drugTestImgFile = File(drugTestFile.path!);
    drugTestImgBytes = await CompressFile(drugTestImgFile) as Uint8List;
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ImagePreview(
                  images: drugTestImgBytes,
                  title: "صورة وجه رخصة شهادة المخدرات",
                )));
    return true;
  }

  Future<bool> criminalRecordPick() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return false;
    criminalRecordFile = result.files.single;
    criminalRecordImgFile = File(criminalRecordFile.path!);
    criminalRecordImgBytes =
        await CompressFile(criminalRecordImgFile) as Uint8List;
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ImagePreview(
                  images: criminalRecordImgBytes,
                  title: "صورة وجه فيش",
                )));
    return true;
  }

  List<Step> getSteps() => [
        Step(title: const Text("ID"), content: Container()),
        Step(title: const Text("Driver License"), content: Container()),
        Step(title: const Text("Safety Certificate"), content: Container()),
        Step(title: const Text("Drug Test"), content: Container()),
        Step(title: const Text("Criminal Record"), content: Container())
      ];
}
