// ignore_for_file: file_names, depend_on_referenced_packages, unused_local_variable

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:falcon_1/Screens/AllCars.dart';
import 'package:falcon_1/main.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import '../DetailScreens/ImageViewUpdateCar.dart';
import 'package:http_parser/http_parser.dart';

class EditCarScreen extends StatefulWidget {
  const EditCarScreen({
    Key? key,
    @required this.car,
    @required this.jwt,
  }) : super(key: key);
  final dynamic car;
  final String? jwt;
  // final Map<String, Uint8List> imageBytes;
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
final _tankLicenseExpiryDateController = TextEditingController();

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

Future<Object> get loadData async {
  if (_transporterList.isEmpty) {
    try {
      var res =
          await dio.post("$SERVER_IP/api/GetTransporters").then((response) {
        var str = response.data;
        for (var transporter in str) {
          _transporterList.add(transporter);
        }
        selectedTransporter ??= _transporterList[0];
      }).timeout(
        const Duration(seconds: 4),
      );
    } catch (e) {
      return "Error";
    }
  }
  return {
    "Transporters": _transporterList,
  };
}

class _EditCarScreenState extends State<EditCarScreen> {
  @override
  void initState() {
    _carPlateNoController.text = widget.car["car_no_plate"];
    // Loop over car["Compartments"] and set the text controllers to the values
    List compartments = widget.car["json_compartments"];
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

    selectedCarType = widget.car["car_type"];
    selectedTransporter = widget.car["transporter"];
    _licenseExpiryDateController.text =
        widget.car["license_expiration_date"].toString();
    _calibrationExpiryDateController.text =
        widget.car["calibration_expiration_date"].toString();
    _tankLicenseExpiryDateController.text =
        widget.car["tank_license_expiration_date"].toString();
    // if (imageBytesList[0] != null) {
    //   carLicenseImgBytes = imageBytesList[0];
    // }
    // if (imageBytesList[1] != null) {
    //   carLicenseImgBytesBack = imageBytesList[1];
    // }
    // if (widget.car["car_type"] == "تريلا") {
    //   if (imageBytesList[2] != null) {
    //     tankLicenseImgBytes = imageBytesList[2];
    //   }
    //   if (imageBytesList[3] != null) {
    //     tankLicenseImgBytesBack = imageBytesList[3];
    //   }
    //   if (imageBytesList[4] != null) {
    //     calibrationLicenseImgBytes = imageBytesList[4];
    //   }
    //   if (imageBytesList[5] != null) {
    //     calibrationLicenseImgBytesBack = imageBytesList[5];
    //   }
    // } else {
    //   if (imageBytesList[2] != null) {
    //     calibrationLicenseImgBytes = imageBytesList[2];
    //   }
    //   if (imageBytesList[3] != null) {
    //     calibrationLicenseImgBytesBack = imageBytesList[3];
    //   }
    // }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).primaryColor,
          title: Text(
            'تعديل بيانات السيارة ${widget.car["car_no_plate"]}',
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
                              Navigator.pop(context);
                              // Navigator.pushReplacement(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (_) => AddCar(
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
                return SafeArea(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: ListView(
                      children: <Widget>[
                        DropdownSearch<String>(
                          dropdownSearchDecoration: const InputDecoration(
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
                          dropdownSearchDecoration: const InputDecoration(
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
                                      Text("أنتهاء رخصة السيارة"),
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
                                    placeholder: "أنتهاء رخصة السيارة*",
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
                                          _calibrationExpiryDateController
                                                  .text =
                                              intl.DateFormat("yyyy-MM-dd")
                                                  .format(pickDate);
                                        });
                                      }
                                    },
                                    controller:
                                        _calibrationExpiryDateController,
                                    placeholder: "أنتهاء شهادة العيار*",
                                  ),
                                ),
                              ),
                              selectedCarType == _carTypes[1]
                                  ? GestureDetector(
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
                                      child: CupertinoFormRow(
                                        prefix: Row(
                                          children: const [
                                            Icon(Icons.calendar_today),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text("أنتهاء رخصة الديل"),
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
                                          placeholder: "أنتهاء رخصة الديل*",
                                        ),
                                      ),
                                    )
                                  : Container(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Center(
                        //   child: TextButton(
                        //     onPressed: () async {
                        //       Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //           builder: (_) => ImageViewUpdateCar(
                        //             images: widget.imageBytes,
                        //             name: widget.car["car_no_plate"],
                        //             carType: widget.car["car_type"],
                        //           ),
                        //         ),
                        //       );
                        //     },
                        //     child: const Text(
                        //       "Show Photos",
                        //     ),
                        //   ),
                        // ),
                        const SizedBox(height: 20),
                        Center(
                          // ignore: deprecated_member_use
                          child: TextButton(
                            onPressed: () async {
                              if (_carPlateNoController.text.isEmpty ||
                                  _compartment1Controller.text.isEmpty ||
                                  _licenseExpiryDateController.text.isEmpty ||
                                  _calibrationExpiryDateController
                                      .text.isEmpty) {
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
                                // request.headers['Cookie'] = "jwt=${widget.jwt}";
                                // request.fields['request'] = jsonEncode({
                                //   "ID": widget.car["ID"],
                                //   "car_no_plate": _carPlateNoController.text,
                                //   //Tank Capacity to int
                                //   "tank_capacity": tankCapacity,
                                //   "car_type": selectedCarType.toString(),
                                //   "transporter": selectedTransporter,
                                //   "compartments": <int>[
                                //     if (_compartment1Controller.text != "")
                                //       int.parse(_compartment1Controller.text),
                                //     if (_compartment2Controller.text != "")
                                //       int.parse(_compartment2Controller.text),
                                //     if (_compartment3Controller.text != "")
                                //       int.parse(_compartment3Controller.text),
                                //     if (_compartment4Controller.text != "")
                                //       int.parse(_compartment4Controller.text),
                                //   ],
                                //   "license_expiration_date":
                                //       _licenseExpiryDateController.text,
                                //   "calibration_expiration_date":
                                //       _calibrationExpiryDateController.text,
                                //   "tank_license_expiration_date":
                                //       selectedCarType == _carTypes[0]
                                //           ? ""
                                //           : _tankLicenseExpiryDateController
                                //               .text,
                                // });
                                // if (carLicenseImgBytes.isNotEmpty) {
                                //   request.files.add(
                                //     http.MultipartFile.fromBytes(
                                //       'CarLicense',
                                //       carLicenseImgBytes,
                                //       filename:
                                //           widget.car["car_license_image_name"],
                                //       contentType: MediaType("image", "jpeg"),
                                //     ),
                                //   );
                                // }

                                // request.files.add(
                                //   http.MultipartFile.fromBytes(
                                //     'CarLicenseBack',
                                //     carLicenseImgBytesBack,
                                //     filename: widget
                                //         .car["car_license_image_name_back"],
                                //     contentType: MediaType("image", "jpeg"),
                                //   ),
                                // );

                                // request.files.add(
                                //   http.MultipartFile.fromBytes(
                                //     'CalibrationLicense',
                                //     calibrationLicenseImgBytes,
                                //     filename: widget
                                //         .car["calibration_license_image_name"],
                                //     contentType: MediaType("image", "jpeg"),
                                //   ),
                                // );
                                // request.files.add(
                                //   http.MultipartFile.fromBytes(
                                //     'CalibrationLicenseBack',
                                //     calibrationLicenseImgBytesBack,
                                //     filename: widget.car[
                                //         "calibration_license_image_name_back"],
                                //     contentType: MediaType("image", "jpeg"),
                                //   ),
                                // );
                                // if (selectedCarType == _carTypes[1]) {
                                //   request.files.add(
                                //     http.MultipartFile.fromBytes(
                                //       'TankLicense',
                                //       tankLicenseImgBytes,
                                //       filename:
                                //           widget.car["tank_license_image_name"],
                                //       contentType: MediaType("image", "jpeg"),
                                //     ),
                                //   );
                                //   request.files.add(
                                //     http.MultipartFile.fromBytes(
                                //       'TankLicenseBack',
                                //       tankLicenseImgBytesBack,
                                //       filename: widget
                                //           .car["tank_license_image_name_back"],
                                //       contentType: MediaType("image", "jpeg"),
                                //     ),
                                //   );
                                // }

                                try {
                                  var response = http
                                      .post(
                                          Uri.parse("$SERVER_IP/api/UpdateCar"),
                                          headers: {
                                            "Content-Type": "application/json",
                                            "Cookie": "jwt=${widget.jwt}",
                                          },
                                          body: jsonEncode({
                                            "ID": widget.car["ID"],
                                            "car_no_plate":
                                                _carPlateNoController.text,
                                            //Tank Capacity to int
                                            "tank_capacity": tankCapacity,
                                            "car_type":
                                                selectedCarType.toString(),
                                            "transporter": selectedTransporter,
                                            "compartments": <int>[
                                              if (_compartment1Controller
                                                      .text !=
                                                  "")
                                                int.parse(
                                                    _compartment1Controller
                                                        .text),
                                              if (_compartment2Controller
                                                      .text !=
                                                  "")
                                                int.parse(
                                                    _compartment2Controller
                                                        .text),
                                              if (_compartment3Controller
                                                      .text !=
                                                  "")
                                                int.parse(
                                                    _compartment3Controller
                                                        .text),
                                              if (_compartment4Controller
                                                      .text !=
                                                  "")
                                                int.parse(
                                                    _compartment4Controller
                                                        .text),
                                            ],
                                            "license_expiration_date":
                                                _licenseExpiryDateController
                                                    .text,
                                            "calibration_expiration_date":
                                                _calibrationExpiryDateController
                                                    .text,
                                            "tank_license_expiration_date":
                                                selectedCarType == _carTypes[0]
                                                    ? ""
                                                    : _tankLicenseExpiryDateController
                                                        .text,
                                          }))
                                      .then((value) {
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
                                                        Navigator
                                                            .pushReplacement(
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
                                  }).timeout(const Duration(seconds: 4));
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
                                "تعديل السيارة",
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
            }));
  }
}
