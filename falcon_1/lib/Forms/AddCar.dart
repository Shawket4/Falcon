// ignore_for_file: file_names, depend_on_referenced_packages, unused_local_variable, use_build_context_synchronously
import 'package:falcon_1/Screens/AllCars.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;
import 'dart:convert';
import 'dart:io';
import 'package:dropdown_search/dropdown_search.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:falcon_1/DetailScreens/ImagePreview.dart';
import 'package:falcon_1/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';
import 'package:http_parser/http_parser.dart';
import 'package:google_fonts/google_fonts.dart';

class AddCar extends StatefulWidget {
  const AddCar({Key? key, required this.jwt}) : super(key: key);
  final String jwt;
  @override
  State<AddCar> createState() => _AddCarState();
}

int tankCapacity = 0;
int currentStep = 0;
bool isImagesLoaded = false;
final _carPlateNoController = TextEditingController();
final _compartment1Controller = TextEditingController();
final _compartment2Controller = TextEditingController();
final _compartment3Controller = TextEditingController();
final _compartment4Controller = TextEditingController();
final _licenseExpiryDateController = TextEditingController();
final _calibrationExpiryDateController = TextEditingController();
final _tankLicenseExpiryDateController = TextEditingController();

var request =
    http.MultipartRequest("POST", Uri.parse("$SERVER_IP/api/RegisterCar"));
Dio dio = Dio();
late BuildContext dialogContext;

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

late PlatformFile tankLicenseFile;
late File tankLicenseImgFile;
late Uint8List tankLicenseImgBytes;
late PlatformFile tankLicenseFileBack;
late File tankLicenseImgFileBack;
late Uint8List tankLicenseImgBytesBack;

List<String> _transporterList = [];
List<String> _carTypes = ["No Trailer", "Trailer"];
String? selectedTransporter;
String? selectedCarType = _carTypes[0];
// late PlatformFile carLicenseFile;
// late File carLicenseImgFile;
// late Uint8List carLicenseImgBytes;
// late PlatformFile carLicenseFileBack;
// late File carLicenseImgFileBack;
// late Uint8List carLicenseImgBytesBack;

// late PlatformFile calibrationLicenseFile;
// late File calibrationLicenseImgFile;
// late Uint8List calibrationLicenseImgBytes;
// late PlatformFile calibrationLicenseFileBack;
// late File calibrationLicenseImgFileBack;
// late Uint8List calibrationLicenseImgBytesBack;

// late PlatformFile tankLicenseFile;
// late File tankLicenseImgFile;
// late Uint8List tankLicenseImgBytes;
// late PlatformFile tankLicenseFileBack;
// late File tankLicenseImgFileBack;
// late Uint8List tankLicenseImgBytesBack;

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

List<Step> getSteps = [
  Step(title: const Text("Car License"), content: Container()),
  Step(title: const Text("Calibration License"), content: Container()),
  Step(title: const Text("Trailer License"), content: Container()),
];

class _AddCarState extends State<AddCar> {
  @override
  void initState() {
    _carPlateNoController.clear();
    _compartment1Controller.clear();
    _compartment2Controller.clear();
    _compartment3Controller.clear();
    _compartment4Controller.clear();
    _licenseExpiryDateController.clear();
    _calibrationExpiryDateController.clear();
    _tankLicenseExpiryDateController.clear();
    currentStep = 0;
    isImagesLoaded = false;
    request =
        http.MultipartRequest("POST", Uri.parse("$SERVER_IP/api/RegisterCar"));
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
          'Add Car',
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
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddCar(
                                  jwt: widget.jwt,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.refresh),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
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
                                ),
                                DropdownSearch<String>(
                                  dropdownSearchDecoration:
                                      const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(),
                                    ),
                                    labelText: "Car Type*",
                                  ),
                                  mode: Mode.MENU,
                                  showSelectedItems: true,
                                  showSearchBox: true,
                                  enabled: true,
                                  items: _carTypes,
                                  selectedItem: selectedCarType,
                                  onChanged: (item) => setState(() {
                                    selectedCarType = item as String;
                                  }),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                // child: DropdownButton(
                                //   style: const TextStyle(
                                //     fontSize: 18,
                                //     letterSpacing: 2,
                                //     fontWeight: FontWeight.bold,
                                //     color: Colors.black,
                                //   ),
                                //   items: _transporterList
                                //       .map((item) => DropdownMenuItem<String>(
                                //           value: item, child: Text(item)))
                                //       .toList(),
                                //   value: selectedTransporter,
                                //   onChanged: (item) => setState(() {
                                //     selectedTransporter = item as String?;
                                //   }),
                                //   // isExpanded: false,
                                //   underline: Container(),
                                //   iconEnabledColor: Colors.black,
                                // ),
                              ],
                            )
                          : Container(),
                      CupertinoFormSection(
                        header: const Text(
                          "Car Details",
                        ),
                        children: [
                          CupertinoFormRow(
                            prefix: const Text("Car No Plate"),
                            child: CupertinoTextFormFieldRow(
                              controller: _carPlateNoController,
                              placeholder: "Car No Plate*",
                            ),
                          ),
                          CupertinoFormRow(
                            prefix: const Text("Compartment 1"),
                            child: CupertinoTextFormFieldRow(
                              controller: _compartment1Controller,
                              placeholder: "Size*",
                            ),
                          ),
                          CupertinoFormRow(
                            prefix: const Text("Compartment 2"),
                            child: CupertinoTextFormFieldRow(
                              controller: _compartment2Controller,
                              placeholder: "Size*",
                            ),
                          ),
                          CupertinoFormRow(
                            prefix: const Text("Compartment 3"),
                            child: CupertinoTextFormFieldRow(
                              controller: _compartment3Controller,
                              placeholder: "Size*",
                            ),
                          ),
                          CupertinoFormRow(
                            prefix: const Text("Compartment 4"),
                            child: CupertinoTextFormFieldRow(
                              controller: _compartment4Controller,
                              placeholder: "Size*",
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
                                  Text("Car License Expiry"),
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
                                  Text("Calibration License Expiry"),
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
                              ),
                            ),
                          ),
                          selectedCarType == _carTypes[1]
                              ? GestureDetector(
                                  onTap: () async {
                                    DateTime? pickDate = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2099));
                                    if (pickDate != null) {
                                      _tankLicenseExpiryDateController.text =
                                          intl.DateFormat("yyyy-MM-dd")
                                              .format(pickDate);
                                      setState(() {});
                                    }
                                  },
                                  child: CupertinoFormRow(
                                    prefix: const Row(
                                      children: [
                                        Icon(Icons.calendar_today),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text("Trailer License Expiry"),
                                      ],
                                    ),
                                    child: CupertinoTextFormFieldRow(
                                      onTap: () async {
                                        DateTime? pickDate =
                                            await showDatePicker(
                                                context: context,
                                                initialDate: DateTime.now(),
                                                firstDate: DateTime(2000),
                                                lastDate: DateTime(2099));
                                        if (pickDate != null) {
                                          _tankLicenseExpiryDateController
                                                  .text =
                                              intl.DateFormat("yyyy-MM-dd")
                                                  .format(pickDate);
                                          setState(() {});
                                        }
                                      },
                                      controller:
                                          _tankLicenseExpiryDateController,
                                    ),
                                  ),
                                )
                              : Container(),
                        ],
                      ),
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
                      //                     borderRadius:
                      //                         BorderRadius.circular(4),
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
                      //   steps: getSteps,
                      //   physics: const ClampingScrollPhysics(),
                      //   onStepContinue: () async {
                      //     late bool isFinished;
                      //     if (currentStep == 0) {
                      //       isFinished = await carLicensePick();
                      //     } else if (currentStep == 1) {
                      //       isFinished = await calibrationLicensePick();
                      //     } else if (currentStep == 2) {
                      //       isFinished = await tankLicensePick();
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
                      const SizedBox(
                        height: 20,
                      ),
                      Center(
                        // ignore: deprecated_member_use
                        child: TextButton(
                          onPressed: () async {
                            if (_carPlateNoController.text.isEmpty ||
                                _compartment1Controller.text.isEmpty ||
                                _licenseExpiryDateController.text.isEmpty ||
                                _calibrationExpiryDateController.text.isEmpty) {
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
                            } else if (int.parse(permission) > 1 &&
                                selectedTransporter == "أسم المقاول") {
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
                                  });
                              if (_compartment1Controller.text != "") {
                                tankCapacity +=
                                    int.parse(_compartment1Controller.text);
                              }
                              if (_compartment2Controller.text != "") {
                                tankCapacity +=
                                    int.parse(_compartment2Controller.text);
                              }
                              if (_compartment3Controller.text != "") {
                                tankCapacity +=
                                    int.parse(_compartment3Controller.text);
                              }
                              if (_compartment4Controller.text != "") {
                                tankCapacity +=
                                    int.parse(_compartment4Controller.text);
                              }
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
                              //       "Transporter":
                              // nsporter,
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
                              request.headers['Cookie'] = "jwt=${widget.jwt}";
                              request.fields['request'] = jsonEncode({
                                "car_no_plate": _carPlateNoController.text,
                                //Tank Capacity to int
                                "tank_capacity": tankCapacity,
                                "car_type": selectedCarType.toString(),
                                "transporter": int.parse(permission) == 2
                                    ? ""
                                    : selectedTransporter,
                                "compartments": <int>[
                                  if (_compartment1Controller.text != "")
                                    int.parse(_compartment1Controller.text),
                                  if (_compartment2Controller.text != "")
                                    int.parse(_compartment2Controller.text),
                                  if (_compartment3Controller.text != "")
                                    int.parse(_compartment3Controller.text),
                                  if (_compartment4Controller.text != "")
                                    int.parse(_compartment4Controller.text),
                                ],
                                "license_expiration_date":
                                    _licenseExpiryDateController.text,
                                "calibration_expiration_date":
                                    _calibrationExpiryDateController.text,
                                "tank_license_expiration_date":
                                    selectedCarType == _carTypes[0]
                                        ? ""
                                        : _tankLicenseExpiryDateController.text,
                              });
                              // request.files.add(
                              //   http.MultipartFile.fromBytes(
                              //     'CarLicense',
                              //     carLicenseImgBytes,
                              //     filename:
                              //         "${_carPlateNoController.text} Car_License.${carLicenseFile.extension}",
                              //     contentType: MediaType("image", "jpeg"),
                              //   ),
                              // );
                              // request.files.add(
                              //   http.MultipartFile.fromBytes(
                              //     'CarLicenseBack',
                              //     carLicenseImgBytesBack,
                              //     filename:
                              //         "${_carPlateNoController.text} Car_License_Back.${carLicenseFileBack.extension}",
                              //     contentType: MediaType("image", "jpeg"),
                              //   ),
                              // );

                              // request.files.add(
                              //   http.MultipartFile.fromBytes(
                              //     'CalibrationLicense',
                              //     calibrationLicenseImgBytes,
                              //     filename:
                              //         "${_carPlateNoController.text} Calibration_License.${calibrationLicenseFile.extension}",
                              //     contentType: MediaType("image", "jpeg"),
                              //   ),
                              // );
                              // request.files.add(
                              //   http.MultipartFile.fromBytes(
                              //     'CalibrationLicenseBack',
                              //     calibrationLicenseImgBytesBack,
                              //     filename:
                              //         "${_carPlateNoController.text} Calibration_License_Back.${calibrationLicenseFileBack.extension}",
                              //     contentType: MediaType("image", "jpeg"),
                              //   ),
                              // );
                              // if (selectedCarType == _carTypes[1]) {
                              //   request.files.add(
                              //     http.MultipartFile.fromBytes(
                              //       'TankLicense',
                              //       tankLicenseImgBytes,
                              //       filename:
                              //           "${_carPlateNoController.text} Tank_License.${tankLicenseFile.extension}",
                              //       contentType: MediaType("image", "jpeg"),
                              //     ),
                              //   );
                              //   request.files.add(
                              //     http.MultipartFile.fromBytes(
                              //       'TankLicenseBack',
                              //       tankLicenseImgBytesBack,
                              //       filename:
                              //           "${_carPlateNoController.text} Tank_License_Back.${tankLicenseFileBack.extension}",
                              //       contentType: MediaType("image", "jpeg"),
                              //     ),
                              //   );
                              // }

                              try {
                                var response = request.send().then((value) {
                                  if (value.statusCode == 200) {
                                    //Clear all the fields
                                    tankCapacity = 0;
                                    _carPlateNoController.clear();
                                    _compartment1Controller.clear();
                                    _compartment2Controller.clear();
                                    _compartment3Controller.clear();
                                    _compartment4Controller.clear();
                                    _licenseExpiryDateController.clear();
                                    _calibrationExpiryDateController.clear();
                                    _tankLicenseExpiryDateController.clear();

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
                                                        Navigator.pop(
                                                            dialogContext);
                                                      });
                                                    },
                                                    child: const Text(
                                                      "Close",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                                      setState(() {
                                                        Navigator.pop(
                                                            dialogContext);
                                                      });
                                                      Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (_) =>
                                                              AllCars(
                                                            jwt: widget.jwt
                                                                .toString(),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: const Text(
                                                      "Close",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                }).timeout(const Duration(seconds: 30));
                              } catch (_) {
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
                                                  setState(() {
                                                    Navigator.pop(
                                                        dialogContext);
                                                    Navigator.pop(
                                                        dialogContext);
                                                  });
                                                  // Navigator.pushReplacement(
                                                  //   context,
                                                  //   MaterialPageRoute(
                                                  //     builder: (_) =>
                                                  //         const MainWidget(),
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
                              "Register Car",
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
          }),
    );
  }

  Future<bool> carLicensePick() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return false;
    carLicenseFile = result.files.first;
    carLicenseImgFile = File(carLicenseFile.path!);
    carLicenseImgBytes = await CompressFile(carLicenseImgFile) as Uint8List;
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ImagePreview(
                  images: carLicenseImgBytes,
                  title: "صوره وجه رخصة السيارة",
                )));
    final resultBack = await FilePicker.platform.pickFiles();
    if (resultBack == null) return false;
    carLicenseFileBack = resultBack.files.first;
    carLicenseImgFileBack = File(carLicenseFileBack.path!);
    carLicenseImgBytesBack =
        await CompressFile(carLicenseImgFileBack) as Uint8List;
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ImagePreview(
                  images: carLicenseImgBytesBack,
                  title: "صوره ضهر رخصة السيارة",
                )));
    return true;
  }

  Future<bool> calibrationLicensePick() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return false;
    calibrationLicenseFile = result.files.first;
    calibrationLicenseImgFile = File(calibrationLicenseFile.path!);
    calibrationLicenseImgBytes =
        await CompressFile(calibrationLicenseImgFile) as Uint8List;
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ImagePreview(
                  images: calibrationLicenseImgBytes,
                  title: "صورة وجه شهادة العيار",
                )));
    final resultBack = await FilePicker.platform.pickFiles();
    if (resultBack == null) return false;
    calibrationLicenseFileBack = resultBack.files.first;
    calibrationLicenseImgFileBack = File(calibrationLicenseFileBack.path!);
    calibrationLicenseImgBytesBack =
        await CompressFile(calibrationLicenseImgFileBack) as Uint8List;
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ImagePreview(
                  images: calibrationLicenseImgBytesBack,
                  title: "صورة خلف شهادة العيار",
                )));
    return true;
  }

  Future<bool> tankLicensePick() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return false;
    tankLicenseFile = result.files.first;
    tankLicenseImgFile = File(tankLicenseFile.path!);
    tankLicenseImgBytes = await CompressFile(tankLicenseImgFile) as Uint8List;
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ImagePreview(
                  images: tankLicenseImgBytes,
                  title: "صوره وجه رخصة الديل",
                )));
    final resultBack = await FilePicker.platform.pickFiles();
    if (resultBack == null) return false;
    tankLicenseFileBack = resultBack.files.first;
    tankLicenseImgFileBack = File(tankLicenseFileBack.path!);
    tankLicenseImgBytesBack =
        await CompressFile(tankLicenseImgFileBack) as Uint8List;
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ImagePreview(
                  images: tankLicenseImgBytesBack,
                  title: "صوره ضهر رخصة الديل",
                )));
    return true;
  }
}
