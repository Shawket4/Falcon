// ignore_for_file: use_key_in_widget_constructors, file_names, unused_element, use_build_context_synchronously, non_constant_identifier_names, unused_field

import 'dart:convert';
import 'package:falcon_1/Screens/Login.dart';
import 'package:falcon_1/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:lottie/lottie.dart';

class NewCarTripScreen extends StatefulWidget {
  NewCarTripScreen(this.jwt);
  final String jwt;
  // Current Date in the format of YYYY-MM-DD
  final String currentDate = DateTime.now().toString().substring(0, 10);
  @override
  State<NewCarTripScreen> createState() => _NewCarTripScreenState();
}

// Text Controllers

class _NewCarTripScreenState extends State<NewCarTripScreen> {
  final _carNumberController = TextEditingController();
  final _pickUpPointController = TextEditingController();
  int index = 0;
  final List<TextEditingController> _dropOffPointControllers = [];
  var noOfDropOfPoints = 0;
  var DropOffPoints = [];
  var CarNoPlates = [];
  var Compartments = [];
  var Drivers = [];
  String? selectedCarNoPlate;
  int selectedCompartmentIndex = 0;
  String? selectedDriver;
  late BuildContext dialogContext;
  Dio dio = Dio();

  Future<Object> get loadData async {
    // var jwtString = jsonDecode(widget.jwt)["jwt"];
    // selectedCarNoPlate = null;
    // selectedDriver = null;
    // CarNoPlates = [];
    // Drivers = [];
    if (selectedCarNoPlate == null && selectedDriver == null) {
      var CarReq = await dio.post("$SERVER_IP/api/GetCars").then((response) {
        var str = response.data;
        var cars = str["CarNoPlates"];
        var carCompartments = str["Compartments"];
        for (var car in cars) {
          CarNoPlates.add(car);
        }
        for (var compartment in carCompartments) {
          Compartments.add(compartment);
        }
        // Loop 6 times
        for (var i = 0; i < 6; i++) {
          _dropOffPointControllers.add(TextEditingController());
        }
        selectedCarNoPlate = CarNoPlates[0];
        selectedCompartmentIndex = 0;
      });
      var DriverReq = await dio.post("$SERVER_IP/api/GetDrivers").then((
          response) {
        var str = response.data;
        for (var driver in str) {
          Drivers.add(driver);
        }
        selectedDriver = Drivers[0];
      });
    }
      return {
        "CarNoPlates": CarNoPlates,
        "Drivers": Drivers,
      };
  }

  @override
  void initState() {
    dio.options.headers["Cookie"] = "jwt=${widget.jwt}";
    dio.options.headers["Content-Type"] = "application/json";
    selectedCarNoPlate = null;
    selectedDriver = null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // var jwtString = jsonDecode(widget.jwt)["jwt"];
    return FutureBuilder(
        future: loadData,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
              body: Center(
                // Display lottie animation
                child: Lottie.asset(
                  "lottie/SplashScreen.json",
                  height: 200,
                  width: 200,
                ),
              ),
            );
          }
          // if (snapshot.hasError) {
          //   return const Scaffold(
          //     body: Center(
          //       child: Text("An Error Has Occured."),
          //     ),
          //   );
          // }
          if (snapshot.data != "") {}
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: Theme.of(context).primaryColor,
              title: const Text("انشاء رحلة جديدة"),
            ),
            body: Center(
              child: SafeArea(
                        child: Container(
                          padding: const EdgeInsets.all(30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  DropdownButton<String>(
                                    style: const TextStyle(
                                      fontSize: 15,
                                      letterSpacing: 2,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    items: CarNoPlates.map((item) =>
                                        DropdownMenuItem<String>(
                                            value: item,
                                            child: Text(item))).toList(),
                                    value: selectedCarNoPlate,
                                    onChanged: (item) => setState(() {
                                      _pickUpPointController.clear();
                                      for (var i = 0;
                                          i <
                                              Compartments[
                                                      selectedCompartmentIndex]
                                                  .length;
                                          i++) {
                                        _dropOffPointControllers[i].clear();
                                      }
                                      selectedCarNoPlate = item;
                                      // Set the selected compartment index to item index
                                      selectedCompartmentIndex =
                                          CarNoPlates.indexOf(item);
                                    }),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  DropdownButton<String>(
                                    style: const TextStyle(
                                      fontSize: 15,
                                      letterSpacing: 2,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    items: Drivers.map((item) =>
                                        DropdownMenuItem<String>(
                                            value: item,
                                            child: Text(item))).toList(),
                                    value: selectedDriver,
                                    onChanged: (item) => setState(() {
                                      selectedDriver = item;
                                    }),
                                  ),
                                ],
                              ),
                              Directionality(
                                textDirection: TextDirection.rtl,
                                child: CupertinoFormSection(
                                  header: const Text(
                                    "تفاصيل الرحلة",
                                  ),
                                  children: [
                                    // CupertinoFormRow(
                                    //   prefix: const Text("Car No Plate"),
                                    //   child: CupertinoTextFormFieldRow(
                                    //     controller: _carNumberController,
                                    //     placeholder: "Car No Plate*",
                                    //   ),
                                    // )
                                    CupertinoFormRow(
                                      prefix: const Text("المستودع"),
                                      child: CupertinoTextFormFieldRow(
                                        controller: _pickUpPointController,
                                        placeholder: "المستودع*",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Directionality(
                                textDirection: TextDirection.rtl,
                                child: CupertinoFormSection(
                                  header: const Text(
                                    "اماكن التفريغ",
                                  ),
                                  children: [
                                    //Loop Over CarNoPlates["Compartments"] and add an i for each compartment
                                    for (var i = 0;
                                        i <
                                            Compartments[
                                                    selectedCompartmentIndex]
                                                .length;
                                        i++)
                                      CupertinoFormRow(
                                        prefix: Text("العين ${i + 1}"),
                                        child: CupertinoTextFormFieldRow(
                                          controller:
                                              _dropOffPointControllers[i],
                                          placeholder:
                                              "${Compartments[selectedCompartmentIndex][i]}*",
                                        ),
                                      ),
                                    // for (var compartment in Compartments)
                                    //   CupertinoFormRow(
                                    //     prefix: Text("العين ${}"),
                                    //     child: CupertinoTextFormFieldRow(
                                    //       controller: _pickUpPointController,
                                    //       placeholder: "المستودع*",
                                    //     ),
                                    //   ),
                                    // CupertinoFormRow(
                                    //   prefix: const Text("تفريغ 1"),
                                    //   child: CupertinoTextFormFieldRow(
                                    //     controller: _dropOffPoint1Controller,
                                    //     placeholder: "تفريغ 1*",
                                    //   ),
                                    // ),
                                    // CupertinoFormRow(
                                    //   prefix: const Text("تفريغ 2"),
                                    //   child: CupertinoTextFormFieldRow(
                                    //     controller: _dropOffPoint2Controller,
                                    //     placeholder: "تفريغ 2*",
                                    //   ),
                                    // ),
                                    // CupertinoFormRow(
                                    //   prefix: const Text("تفريغ 3"),
                                    //   child: CupertinoTextFormFieldRow(
                                    //     controller: _dropOffPoint3Controller,
                                    //     placeholder: "تفريغ 3*",
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              Center(
                                // ignore: deprecated_member_use
                                child: FlatButton(
                                  onPressed: () async => {
                                    for (var i = 0;
                                        i <
                                            Compartments[
                                                    selectedCompartmentIndex]
                                                .length;
                                        i++)
                                      {
                                        index++,
                                      },
                                    if (_pickUpPointController.text.isEmpty ||
                                        _dropOffPointControllers[0]
                                            .text
                                            .isEmpty)
                                      {
                                        // Check if each text field is empty
                                        showCupertinoDialog(
                                          context: context,
                                          builder: (context) =>
                                              CupertinoAlertDialog(
                                            title: const Text("خطأ"),
                                            content: const Text(
                                                "يرجى ملء جميع الحقول"),
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
                                    // print(_carNumberController.text),
                                    // print(_pickUpPointController.text),
                                    // _dropOffPoint1Controller.text != ""
                                    //     ? {
                                    //         print(_dropOffPoint1Controller.text),
                                    //         noOffDropOfPoints++
                                    //       }
                                    //     : {},
                                    // _dropOffPoint2Controller.text != ""
                                    //     ? {
                                    //         print(_dropOffPoint2Controller.text),
                                    //         noOffDropOfPoints++
                                    //       }
                                    //     : {},
                                    // _dropOffPoint3Controller.text != ""
                                    //     ? {
                                    //         print(_dropOffPoint3Controller.text),
                                    //         noOffDropOfPoints++
                                    //       }
                                    //     : {},
                                    // print(widget.currentDate),
                                    // print(noOffDropOfPoints),
                                    // noOffDropOfPoints = 0,
                                    // print(
                                    //     jsonDecode(snapshot.data.toString())["name"])
                                    // Make Post Request To Api using jwt token
                                    // _dropOffPoint1Controller.text != ""
                                    //     ? {
                                    //         DropOffPoints.add(
                                    //             _dropOffPoint1Controller.text),
                                    //         noOfDropOfPoints++
                                    //       }
                                    //     : {},
                                    // _dropOffPoint2Controller.text != ""
                                    //     ? {
                                    //         DropOffPoints.add(
                                    //             _dropOffPoint2Controller.text),
                                    //         noOfDropOfPoints++
                                    //       }
                                    //     : {},
                                    // _dropOffPoint3Controller.text != ""
                                    //     ? {
                                    //         DropOffPoints.add(
                                    //             _dropOffPoint3Controller.text),
                                    //         noOfDropOfPoints++
                                    //       }
                                    //     : {},
                                    else
                                      {
                                        for (var i = 0;
                                            i <
                                                Compartments[
                                                        selectedCompartmentIndex]
                                                    .length;
                                            i++)
                                          _dropOffPointControllers[i].text != ""
                                              ? {
                                                  DropOffPoints.add(
                                                      _dropOffPointControllers[
                                                              i]
                                                          .text),
                                                  noOfDropOfPoints++
                                                }
                                              : {},
                                        showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (context) {
                                              dialogContext = context;
                                              return Dialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
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
                                          Uri.parse(
                                              '$SERVER_IP/api/CreateCarTrip'),
                                          headers: {
                                            "Cookie": "jwt=${widget.jwt}",
                                            "Content-Type": "application/json",
                                          },
                                          body: jsonEncode(
                                            {
                                              "Date": widget.currentDate,
                                              "CarNoPlate": selectedCarNoPlate,
                                              "DriverName": selectedDriver,
                                              "PickUpPoint":
                                                  _pickUpPointController.text,
                                              "NoOfDropOffPoints":
                                                  noOfDropOfPoints,
                                              "DropOffPoints": DropOffPoints,
                                            },
                                          ),
                                        )
                                            .then((response) {
                                          noOfDropOfPoints = 0;
                                          DropOffPoints = [];
                                          //Clear all the fields
                                          for (var i = 0;
                                              i <
                                                  Compartments[
                                                          selectedCompartmentIndex]
                                                      .length;
                                              i++) {
                                            _dropOffPointControllers[i].clear();
                                          }
                                          _pickUpPointController.clear();
                                          Navigator.pop(dialogContext);
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const MainWidget(),
                                            ),
                                          );
                                          setState(() {
                                            Navigator.pop(dialogContext);
                                            // Rebuild Whole Page
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    const MainWidget(),
                                              ),
                                            );
                                          });
                                        }),
                                      },
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    width: 200,
                                    height: 50,
                                    alignment: Alignment.center,
                                    child: const Text(
                                      "انشاء رحلة",
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
            ),
          );
        });
  }
}
