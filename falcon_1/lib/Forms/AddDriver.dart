// ignore_for_file: file_names, depend_on_referenced_packages, unused_local_variable, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:falcon_1/DetailScreens/ImagePreview.dart';
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
  _transporterList.clear();
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
      });
    } catch (e) {
      return "Error";
    }
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
var request =
    http.MultipartRequest("POST", Uri.parse("$SERVER_IP/api/RegisterUser"));
late BuildContext dialogContext;
late PlatformFile driverLicenseFile;
late File driverLicenseImgFile;
late Uint8List driverLicenseImgBytes;
late PlatformFile driverLicenseFileBack;
late File driverLicenseImgFileBack;
late Uint8List driverLicenseImgBytesBack;
late PlatformFile safetyLicenseFile;
late File safetyLicenseImgFile;
late Uint8List safetyLicenseImgBytes;
late PlatformFile safetyLicenseFileBack;
late File safetyLicenseImgFileBack;
late Uint8List safetyLicenseImgBytesBack;
late PlatformFile drugTestFile;
late File drugTestImgFile;
late Uint8List drugTestImgBytes;
late PlatformFile drugTestFileBack;
late File drugTestImgFileBack;
late Uint8List drugTestImgBytesBack;

class _AddDriverState extends State<AddDriver> {
  @override
  void initState() {
    // selectedTransporter = "أسم المقاول";
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
                                builder: (_) => AddDriver(
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
                    children: <Widget>[
                      int.parse(permission) > 1
                          ? Column(
                              children: [
                                DropdownSearch<String>(
                                  dropdownSearchDecoration:
                                      const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(),
                                    ),
                                    labelText: "Driver Name*",
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
                                if (pickDate != null) {
                                  final result =
                                      await FilePicker.platform.pickFiles();
                                  if (result == null) return;
                                  driverLicenseFile = result.files.first;
                                  driverLicenseImgFile =
                                      File(driverLicenseFile.path!);
                                  driverLicenseImgBytes =
                                      await CompressFile(driverLicenseImgFile)
                                          as Uint8List;
                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => ImagePreview(
                                                images: driverLicenseImgBytes,
                                                title: "صورة وجه رخصة القيادة",
                                              )));
                                  final resultBack =
                                      await FilePicker.platform.pickFiles();
                                  if (resultBack == null) return;
                                  driverLicenseFileBack =
                                      resultBack.files.first;
                                  driverLicenseImgFileBack =
                                      File(driverLicenseFileBack.path!);
                                  driverLicenseImgBytesBack =
                                      await CompressFile(
                                              driverLicenseImgFileBack)
                                          as Uint8List;
                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => ImagePreview(
                                                images:
                                                    driverLicenseImgBytesBack,
                                                title: "صورة خلف رخصة القيادة",
                                              )));
                                  setState(() {
                                    _licenseExpirationDateController.text =
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
                                      final result =
                                          await FilePicker.platform.pickFiles();
                                      if (result == null) return;
                                      driverLicenseFile = result.files.first;
                                      driverLicenseImgFile =
                                          File(driverLicenseFile.path!);
                                      driverLicenseImgBytes =
                                          await CompressFile(
                                                  driverLicenseImgFile)
                                              as Uint8List;
                                      await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => ImagePreview(
                                                    images:
                                                        driverLicenseImgBytes,
                                                    title:
                                                        "صورة وجه رخصة القيادة",
                                                  )));
                                      final resultBack =
                                          await FilePicker.platform.pickFiles();
                                      if (resultBack == null) return;
                                      driverLicenseFileBack =
                                          resultBack.files.first;
                                      driverLicenseImgFileBack =
                                          File(driverLicenseFileBack.path!);
                                      driverLicenseImgBytesBack =
                                          await CompressFile(
                                                  driverLicenseImgFileBack)
                                              as Uint8List;
                                      await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => ImagePreview(
                                                    images:
                                                        driverLicenseImgBytesBack,
                                                    title:
                                                        "صورة خلف رخصة القيادة",
                                                  )));
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
                                  final result =
                                      await FilePicker.platform.pickFiles();
                                  if (result == null) return;
                                  safetyLicenseFile = result.files.first;
                                  safetyLicenseImgFile =
                                      File(safetyLicenseFile.path!);
                                  safetyLicenseImgBytes =
                                      await CompressFile(safetyLicenseImgFile)
                                          as Uint8List;
                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => ImagePreview(
                                                images: safetyLicenseImgBytes,
                                                title:
                                                    "صورة وجه رخصة القيادة الأمنة",
                                              )));
                                  final resultBack =
                                      await FilePicker.platform.pickFiles();
                                  if (resultBack == null) return;
                                  safetyLicenseFileBack =
                                      resultBack.files.first;
                                  safetyLicenseImgFileBack =
                                      File(safetyLicenseFileBack.path!);
                                  safetyLicenseImgBytesBack =
                                      await CompressFile(
                                              safetyLicenseImgFileBack)
                                          as Uint8List;
                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => ImagePreview(
                                                images:
                                                    safetyLicenseImgBytesBack,
                                                title:
                                                    "صورة خلف رخصة القيادة الأمنة",
                                              )));
                                  setState(() {
                                    _safetyLicenseExpirationDateController
                                            .text =
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
                                      final result =
                                          await FilePicker.platform.pickFiles();
                                      if (result == null) return;
                                      safetyLicenseFile = result.files.first;
                                      safetyLicenseImgFile =
                                          File(safetyLicenseFile.path!);
                                      safetyLicenseImgBytes =
                                          await CompressFile(
                                                  safetyLicenseImgFile)
                                              as Uint8List;
                                      await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => ImagePreview(
                                                    images:
                                                        safetyLicenseImgBytes,
                                                    title:
                                                        "صورة وجه رخصة القيادة الأمنة",
                                                  )));
                                      final resultBack =
                                          await FilePicker.platform.pickFiles();
                                      if (resultBack == null) return;
                                      safetyLicenseFileBack =
                                          resultBack.files.first;
                                      safetyLicenseImgFileBack =
                                          File(safetyLicenseFileBack.path!);
                                      safetyLicenseImgBytesBack =
                                          await CompressFile(
                                                  safetyLicenseImgFileBack)
                                              as Uint8List;
                                      await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => ImagePreview(
                                                    images:
                                                        safetyLicenseImgBytesBack,
                                                    title:
                                                        "صورة خلف رخصة القيادة الأمنة",
                                                  )));
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
                                  final result =
                                      await FilePicker.platform.pickFiles();
                                  if (result == null) return;
                                  drugTestFile = result.files.first;
                                  drugTestImgFile = File(drugTestFile.path!);
                                  drugTestImgBytes =
                                      await CompressFile(drugTestImgFile)
                                          as Uint8List;
                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => ImagePreview(
                                                images: drugTestImgBytes,
                                                title:
                                                    "صورة وجه رخصة شهادة المخدرات",
                                              )));
                                  final resultBack =
                                      await FilePicker.platform.pickFiles();
                                  if (resultBack == null) return;
                                  drugTestFileBack = resultBack.files.first;
                                  drugTestImgFileBack =
                                      File(drugTestFileBack.path!);
                                  drugTestImgBytesBack =
                                      await CompressFile(drugTestImgFileBack)
                                          as Uint8List;
                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => ImagePreview(
                                                images: drugTestImgBytesBack,
                                                title:
                                                    "صورة خلف رخصة شهادة المخدرات",
                                              )));
                                  setState(() {
                                    _drugTestExpirationDate.text =
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
                                      final result =
                                          await FilePicker.platform.pickFiles();
                                      if (result == null) return;
                                      drugTestFile = result.files.first;
                                      drugTestImgFile =
                                          File(drugTestFile.path!);
                                      drugTestImgBytes =
                                          await CompressFile(drugTestImgFile)
                                              as Uint8List;
                                      await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => ImagePreview(
                                                    images: drugTestImgBytes,
                                                    title:
                                                        "صورة وجه رخصة شهادة المخدرات",
                                                  )));
                                      final resultBack =
                                          await FilePicker.platform.pickFiles();
                                      if (resultBack == null) return;
                                      drugTestFileBack = resultBack.files.first;
                                      drugTestImgFileBack =
                                          File(drugTestFileBack.path!);
                                      drugTestImgBytesBack = await CompressFile(
                                          drugTestImgFileBack) as Uint8List;
                                      await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => ImagePreview(
                                                    images:
                                                        drugTestImgBytesBack,
                                                    title:
                                                        "صورة خلف رخصة شهادة المخدرات",
                                                  )));
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
                        child: TextButton(
                          onPressed: () async {
                            if (_driverNameController.text.isEmpty ||
                                _mobileController.text.isEmpty ||
                                _emailController.text.isEmpty ||
                                _passwordController.text.isEmpty ||
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
                              // request.headers['Content-Type'] = "multipart/form",
                              request.headers['Cookie'] = "jwt=${widget.jwt}";
                              request.fields['request'] = jsonEncode(
                                {
                                  "name": _driverNameController.text,
                                  "email": _emailController.text,
                                  "password": _passwordController.text,
                                  "mobile_number": _mobileController.text,
                                  "permission": "0",
                                  "DriverLicenseExpirationDate":
                                      _licenseExpirationDateController.text,
                                  "SafetyLicenseExpirationDate":
                                      _safetyLicenseExpirationDateController
                                          .text,
                                  "DrugTestExpirationDate":
                                      _drugTestExpirationDate.text,
                                  "Transporter": selectedTransporter,
                                },
                              );
                              request.files.add(
                                http.MultipartFile.fromBytes(
                                  'DriverLicense',
                                  driverLicenseImgBytes,
                                  filename:
                                      "${_driverNameController.text} Driver_License.${driverLicenseFile.extension}",
                                  contentType: MediaType("image", "jpeg"),
                                ),
                              );
                              request.files.add(
                                http.MultipartFile.fromBytes(
                                  'SafetyLicense',
                                  safetyLicenseImgBytes,
                                  filename:
                                      "${_driverNameController.text} Safety_License.${safetyLicenseFile.extension}",
                                  contentType: MediaType("image", "jpeg"),
                                ),
                              );
                              request.files.add(
                                http.MultipartFile.fromBytes(
                                  'DrugTest',
                                  drugTestImgBytes,
                                  filename:
                                      "${_driverNameController.text} Drug_Test.${drugTestFile.extension}",
                                  contentType: MediaType("image", "jpeg"),
                                ),
                              );
                              request.files.add(
                                http.MultipartFile.fromBytes(
                                  'DriverLicenseBack',
                                  driverLicenseImgBytesBack,
                                  filename:
                                      "${_driverNameController.text} Driver_License.${driverLicenseFileBack.extension}",
                                  contentType: MediaType("image", "jpeg"),
                                ),
                              );
                              request.files.add(
                                http.MultipartFile.fromBytes(
                                  'SafetyLicenseBack',
                                  safetyLicenseImgBytesBack,
                                  filename:
                                      "${_driverNameController.text} Safety_License.${safetyLicenseFileBack.extension}",
                                  contentType: MediaType("image", "jpeg"),
                                ),
                              );
                              request.files.add(
                                http.MultipartFile.fromBytes(
                                  'DrugTestBack',
                                  drugTestImgBytesBack,
                                  filename:
                                      "${_driverNameController.text} Drug_Test.${drugTestFileBack.extension}",
                                  contentType: MediaType("image", "jpeg"),
                                ),
                              );
                              try {
                                await request.send().then((value) {
                                  if (value.statusCode == 200) {
                                    //Clear all the fields
                                    _driverNameController.clear();
                                    _mobileController.clear();
                                    _emailController.clear();
                                    _passwordController.clear();
                                    _licenseExpirationDateController.clear();
                                    _safetyLicenseExpirationDateController
                                        .clear();
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
                                                              CarProgressScreen(
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
                                                              CarProgressScreen(
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
                                }).timeout(
                                  const Duration(seconds: 4),
                                );
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
                                                  });
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          CarProgressScreen(
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
          }),
    );
  }
}
