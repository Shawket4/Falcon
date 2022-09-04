// ignore_for_file: file_names, depend_on_referenced_packages, unused_local_variable

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:falcon_1/DetailScreens/ImagePreview.dart';
import 'package:falcon_1/Screens/CarProgressScreen.dart';
import 'package:falcon_1/main.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;
import 'package:lottie/lottie.dart';
import 'package:http_parser/http_parser.dart';
import 'package:typed_data/typed_data.dart';

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
var request =
    http.MultipartRequest("POST", Uri.parse("$SERVER_IP/api/RegisterCar"));
Dio dio = Dio();
late BuildContext dialogContext;
List<String> _transporterList = [];
String? selectedTransporter;
late PlatformFile carLicenseFile;
late File carLicenseImgFile;
late Uint8List carLicenseImgBytes;
late PlatformFile carLicenseFileBack;
late File carLicenseImgFileBack;
late Uint8List carLicenseImgBytesBack;
late PlatformFile calibrationLicenseFile;
late File calibrationLicenseImgFile;
late Uint8List calibrationLicenseImgBytes;
late PlatformFile calibrationLicenseFileBack;
late File calibrationLicenseImgFileBack;
late Uint8List calibrationLicenseImgBytesBack;

Future<Object> get loadData async {
  if (selectedTransporter == null) {
    var res = await dio.post("$SERVER_IP/api/GetTransporters").then((response) {
      var str = response.data;
      for (var transporter in str) {
        _transporterList.add(transporter);
      }
      _transporterList.add("أسم المقاول");
      selectedTransporter = "أسم المقاول";
    });

    return {
      "Transporters": _transporterList,
    };
  }
  return {
    "Transporters": _transporterList,
  };
}

class _AddCarState extends State<AddCar> {
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
          'إضافة سيارة',
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
            }
            return SafeArea(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: <Widget>[
                    int.parse(permission) > 1
                        ? Center(
                            child: DropdownButton(
                              style: const TextStyle(
                                fontSize: 18,
                                letterSpacing: 2,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              items: _transporterList
                                  .map((item) => DropdownMenuItem<String>(
                                      value: item, child: Text(item)))
                                  .toList(),
                              value: selectedTransporter,
                              onChanged: (item) => setState(() {
                                selectedTransporter = item as String?;
                              }),
                              // isExpanded: false,
                              underline: Container(),
                              iconEnabledColor: Colors.black,
                            ),
                          )
                        : Container(),
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
                                final result =
                                    await FilePicker.platform.pickFiles();
                                if (result == null) return;
                                carLicenseFile = result.files.first;
                                carLicenseImgFile = File(carLicenseFile.path!);
                                carLicenseImgBytes =
                                    await CompressFile(carLicenseImgFile)
                                        as Uint8List;
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => ImagePreview(
                                              images: carLicenseImgBytes,
                                              title: "صوره وجه رخصة السيارة",
                                            )));
                                final resultBack =
                                    await FilePicker.platform.pickFiles();
                                if (resultBack == null) return;
                                carLicenseFileBack = resultBack.files.first;
                                carLicenseImgFileBack =
                                    File(carLicenseFileBack.path!);
                                carLicenseImgBytesBack =
                                    await CompressFile(carLicenseImgFileBack)
                                        as Uint8List;
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => ImagePreview(
                                              images: carLicenseImgBytesBack,
                                              title: "صوره ضهر رخصة السيارة",
                                            )));
                                setState(() {
                                  _licenseExpiryDateController.text =
                                      intl.DateFormat("yyyy-MM-dd")
                                          .format(pickDate);
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
                                    final result =
                                        await FilePicker.platform.pickFiles();
                                    if (result == null) return;
                                    carLicenseFile = result.files.first;
                                    carLicenseImgFile =
                                        File(carLicenseFile.path!);
                                    carLicenseImgBytes =
                                        await CompressFile(carLicenseImgFile)
                                            as Uint8List;
                                    await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => ImagePreview(
                                                  images: carLicenseImgBytes,
                                                  title:
                                                      "صوره وجه رخصة السيارة",
                                                )));
                                    final resultBack =
                                        await FilePicker.platform.pickFiles();
                                    if (resultBack == null) return;
                                    carLicenseFileBack = resultBack.files.first;
                                    carLicenseImgFileBack =
                                        File(carLicenseFileBack.path!);
                                    carLicenseImgBytesBack = await CompressFile(
                                        carLicenseImgFileBack) as Uint8List;
                                    await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => ImagePreview(
                                                  images:
                                                      carLicenseImgBytesBack,
                                                  title:
                                                      "صورة خلف رخصة السيارة",
                                                )));
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
                                final result =
                                    await FilePicker.platform.pickFiles();
                                if (result == null) return;
                                calibrationLicenseFile = result.files.first;
                                calibrationLicenseImgFile =
                                    File(calibrationLicenseFile.path!);
                                calibrationLicenseImgBytes = await CompressFile(
                                    calibrationLicenseImgFile) as Uint8List;
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => ImagePreview(
                                              images:
                                                  calibrationLicenseImgBytes,
                                              title: "صورة وجه شهادة العيار",
                                            )));
                                final resultBack =
                                    await FilePicker.platform.pickFiles();
                                if (resultBack == null) return;
                                calibrationLicenseFileBack =
                                    resultBack.files.first;
                                calibrationLicenseImgFileBack =
                                    File(calibrationLicenseFileBack.path!);
                                calibrationLicenseImgBytesBack =
                                    await CompressFile(
                                            calibrationLicenseImgFileBack)
                                        as Uint8List;
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => ImagePreview(
                                              images:
                                                  calibrationLicenseImgBytesBack,
                                              title: "صورة خلف شهادة العيار",
                                            )));
                                setState(() {
                                  _calibrationExpiryDateController.text =
                                      intl.DateFormat("yyyy-MM-dd")
                                          .format(pickDate);
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
                                  final result =
                                      await FilePicker.platform.pickFiles();
                                  if (result == null) return;
                                  calibrationLicenseFile = result.files.first;
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
                              if (int.parse(permission) > 1 &&
                                  selectedTransporter == "أسم المقاول")
                                {
                                  showCupertinoDialog(
                                    context: context,
                                    builder: (context) => CupertinoAlertDialog(
                                      title: const Text("خطأ"),
                                      content:
                                          const Text("يرجى ملء جميع الحقول"),
                                      actions: <Widget>[
                                        CupertinoDialogAction(
                                          child: const Text("حسنا"),
                                          onPressed: () =>
                                              Navigator.pop(context),
                                        ),
                                      ],
                                    ),
                                  ),
                                }
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
                                        borderRadius:
                                            BorderRadius.circular(12.0),
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
                              // await http
                              //     .post(
                              //   Uri.parse("$SERVER_IP/api/RegisterCar"),
                              //   headers: {
                              //     "Content-Type": "application/json",
                              //     "Cookie": "jwt=${widget.jwt}"
                              //   },
                              //   body: jsonEncode(
                              //     {
                              //       "CarNoPlate": _carPlateNoController.text,
                              //       //Tank Capacity to int
                              //       "TankCapacity": tankCapacity,
                              //       "Transporter": selectedTransporter,
                              //       "Compartments": <int>[
                              //         if (_compartment1Controller.text != "")
                              //           int.parse(_compartment1Controller.text),
                              //         if (_compartment2Controller.text != "")
                              //           int.parse(_compartment2Controller.text),
                              //         if (_compartment3Controller.text != "")
                              //           int.parse(_compartment3Controller.text),
                              //         if (_compartment4Controller.text != "")
                              //           int.parse(_compartment4Controller.text),
                              //       ],
                              //       "LicenseExpirationDate":
                              //       _licenseExpiryDateController.text,
                              //       "CalibrationExpirationDate":
                              //       _calibrationExpiryDateController.text,
                              //     },
                              //   ),
                              // )
                              request.headers['Cookie'] = "jwt=${widget.jwt}",
                              request.fields['request'] = jsonEncode({
                                "CarNoPlate": _carPlateNoController.text,
                                //Tank Capacity to int
                                "TankCapacity": tankCapacity,
                                "Transporter": selectedTransporter,
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
                              }),
                              request.files.add(
                                http.MultipartFile.fromBytes(
                                  'CarLicense',
                                  carLicenseImgBytes,
                                  filename:
                                      "${_carPlateNoController.text} Car_License.${carLicenseFile.extension}",
                                  contentType: MediaType("image", "jpeg"),
                                ),
                              ),
                              request.files.add(
                                http.MultipartFile.fromBytes(
                                  'CarLicenseBack',
                                  carLicenseImgBytesBack,
                                  filename:
                                      "${_carPlateNoController.text} Car_License_Back.${carLicenseFileBack.extension}",
                                  contentType: MediaType("image", "jpeg"),
                                ),
                              ),
                              request.files.add(
                                http.MultipartFile.fromBytes(
                                  'CalibrationLicense',
                                  calibrationLicenseImgBytes,
                                  filename:
                                      "${_carPlateNoController.text} Calibration_License.${calibrationLicenseFile.extension}",
                                  contentType: MediaType("image", "jpeg"),
                                ),
                              ),
                              request.files.add(
                                http.MultipartFile.fromBytes(
                                  'CalibrationLicenseBack',
                                  calibrationLicenseImgBytesBack,
                                  filename:
                                      "${_carPlateNoController.text} Calibration_License_Back.${calibrationLicenseFileBack.extension}",
                                  contentType: MediaType("image", "jpeg"),
                                ),
                              ),
                              request.send().then((value) {
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
            );
          }),
    );
  }
}
