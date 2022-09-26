// ignore_for_file: use_key_in_widget_constructors, file_names, unused_element, use_build_context_synchronously, non_constant_identifier_names, unused_field, unused_local_variable

import 'dart:async';
import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:falcon_1/Screens/CarProgressScreen.dart';
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
  final _pickUpPointController = TextEditingController();
  final _feeRateController = TextEditingController();
  int index = 0;
  final List<TextEditingController> _dropOffPointControllers = [];
  final List<TextEditingController> _gasTypeControllers = [];
  var noOfDropOfPoints = 0;
  var DropOffPoints = [];
  List<String> CarNoPlates = [];
  var Compartments = [];
  List<String> Drivers = [];
  List<String> Terminals = [];
  List<String> Customers = [];
  List<Widget> CustomerWidgets = [];
  String? selectedCarNoPlate;
  int selectedCompartmentIndex = 0;
  String? selectedDriver;
  String? selectedTerminal;
  String? selectedCustomer;
  String? selectedGasType;
  late BuildContext dialogContext;
  Dio dio = Dio();
  List<List> formattedCompartments = [];
  List<String> gasTypes = [
    "Gas 80",
    "Gas 92",
    "Gas 95",
    "Diesel",
    "Mazoot",
  ];

  Future<Object> get loadData async {
    try {
      if (selectedCarNoPlate == null ||
          selectedDriver == null ||
          selectedTerminal == null) {
        var CarReq = await dio
            .post("$SERVER_IP/api/GetCars",
                data: jsonEncode({
                  "Include": "",
                }))
            .then((response) {
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
            _gasTypeControllers.add(TextEditingController());
          }
          selectedCarNoPlate = CarNoPlates[0];
          selectedCompartmentIndex = 0;
        });
        var DriverReq =
            await dio.post("$SERVER_IP/api/GetDrivers").then((response) {
          var str = response.data;
          for (var driver in str) {
            Drivers.add(driver);
          }
          selectedDriver = Drivers[0];
        });
        var LocationsReq =
            await dio.get("$SERVER_IP/api/GetLocations").then((response) {
          var str = response.data;
          for (var terminal in str["Terminals"]) {
            Terminals.add(terminal);
          }
          selectedTerminal = Terminals[0];
          for (var customer in str["Customers"]) {
            Customers.add(customer);
          }
          selectedCustomer = Customers[0];
          for (var i = 0; i < 6; i++) {
            _dropOffPointControllers[i].text = selectedCustomer!;
            _gasTypeControllers[i].text = selectedGasType!;
          }
        });
      }
    } catch (e) {
      return "Error";
    }
    return {
      "CarNoPlates": CarNoPlates,
      "Drivers": Drivers,
      "Terminals": Terminals,
      "Customers": Customers,
    };
  }

  @override
  void initState() {
    selectedGasType = gasTypes[0];
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
                              builder: (_) => NewCarTripScreen(widget.jwt),
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
                    child: ListView(
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: [
                        //     DropdownButton<String>(
                        //       style: const TextStyle(
                        //         fontSize: 15,
                        //         letterSpacing: 2,
                        //         fontWeight: FontWeight.bold,
                        //         color: Colors.black,
                        //       ),
                        //       items: CarNoPlates.map((item) =>
                        //           DropdownMenuItem<String>(
                        //               value: item, child: Text(item))).toList(),
                        //       value: selectedCarNoPlate,
                        //       onChanged: (item) => setState(() {
                        //         _pickUpPointController.clear();
                        //         for (var i = 0;
                        //             i <
                        //                 Compartments[selectedCompartmentIndex]
                        //                     .length;
                        //             i++) {
                        //           _dropOffPointControllers[i].clear();
                        //         }
                        //         selectedCarNoPlate = item;
                        //         // Set the selected compartment index to item index
                        //         selectedCompartmentIndex =
                        //             CarNoPlates.indexOf(item);
                        //       }),
                        //     ),
                        //     const SizedBox(
                        //       width: 10,
                        //     ),
                        //     // DropdownButton<String>(
                        //     //   icon: Icon(
                        //     //     Icons.arrow_drop_down_circle_rounded,
                        //     //     color: Theme.of(context).primaryColor,
                        //     //   ),
                        //     //   style: const TextStyle(
                        //     //     fontSize: 15,
                        //     //     letterSpacing: 2,
                        //     //     fontWeight: FontWeight.bold,
                        //     //     color: Colors.black,
                        //     //   ),
                        //     //   items: Drivers.map((item) =>
                        //     //       DropdownMenuItem<String>(
                        //     //           value: item, child: Text(item))).toList(),
                        //     //   value: selectedDriver,
                        //     //   onChanged: (item) => setState(() {
                        //     //     selectedDriver = item;
                        //     //   }),
                        //     // ),
                        //   ],
                        // ),
                        DropdownSearch<String>(
                          dropdownSearchTextAlign: TextAlign.left,
                          searchFieldProps: TextFieldProps(
                            autocorrect: false,
                            cursorColor: Theme.of(context).primaryColor,
                          ),
                          dropdownSearchDecoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide(),
                            ),
                            labelText: "Car No Plate*",
                          ),
                          mode: Mode.MENU,
                          showSelectedItems: true,
                          showSearchBox: true,
                          enabled: true,
                          items: CarNoPlates,
                          selectedItem: selectedCarNoPlate,
                          onChanged: (item) => setState(() {
                            _pickUpPointController.clear();
                            // for (var i = 0;
                            //     i < Compartments[selectedCompartmentIndex].length;
                            //     i++) {
                            //   _dropOffPointControllers[i].clear();
                            // }
                            selectedCarNoPlate = item;
                            // Set the selected compartment index to item index
                            selectedCompartmentIndex =
                                CarNoPlates.indexOf(item as String);
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
                            labelText: "Driver Name*",
                          ),
                          mode: Mode.MENU,
                          showSelectedItems: true,
                          showSearchBox: true,
                          enabled: true,
                          items: Drivers,
                          selectedItem: selectedDriver,
                          onChanged: (item) => setState(() {
                            selectedDriver = item as String;
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
                            labelText: "Terminal*",
                          ),
                          mode: Mode.MENU,
                          showSelectedItems: true,
                          showSearchBox: true,
                          enabled: true,
                          items: Terminals,
                          selectedItem: selectedTerminal,
                          onChanged: (item) => setState(() {
                            selectedTerminal = item as String;
                          }),
                        ),

                        // for (var widget in CustomerWidgets) widget,
                        for (var i = 1;
                            i <
                                Compartments[selectedCompartmentIndex].length +
                                    1;
                            i++)
                          Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: DropdownSearch<String>(
                                      dropdownSearchDecoration: InputDecoration(
                                        border: const OutlineInputBorder(
                                          borderSide: BorderSide(),
                                        ),
                                        labelText:
                                            "Customer $i ${Compartments[selectedCompartmentIndex][i - 1]}*",
                                      ),
                                      mode: Mode.MENU,
                                      showSelectedItems: true,
                                      showSearchBox: true,
                                      enabled: true,
                                      items: Customers,
                                      dropdownBuilder:
                                          (context, selectedItem) => Text(
                                        selectedItem.toString(),
                                        style: const TextStyle(
                                          overflow: TextOverflow.ellipsis,
                                          fontSize: 16,
                                        ),
                                      ),
                                      selectedItem:
                                          _dropOffPointControllers[i - 1].text,
                                      onChanged: (item) => setState(() {
                                        _dropOffPointControllers[i - 1].text =
                                            item as String;
                                      }),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: DropdownSearch<String>(
                                    dropdownSearchDecoration: InputDecoration(
                                      border: const OutlineInputBorder(
                                        borderSide: BorderSide(),
                                      ),
                                      labelText: "Gas Type $i*",
                                    ),
                                    mode: Mode.MENU,
                                    dropdownBuilder: (context, selectedItem) =>
                                        Text(
                                      selectedItem.toString(),
                                      style: const TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        fontSize: 16,
                                      ),
                                    ),
                                    showSelectedItems: true,
                                    showSearchBox: true,
                                    enabled: true,
                                    items: gasTypes,
                                    selectedItem:
                                        _gasTypeControllers[i - 1].text,
                                    onChanged: (item) => setState(() {
                                      _gasTypeControllers[i - 1].text =
                                          item as String;
                                    }),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(
                          height: 15,
                        ),
                        // Directionality(
                        //   textDirection: TextDirection.rtl,
                        //   child: CupertinoFormSection(
                        //     header: const Text(
                        //       "تفاصيل الرحلة",
                        //     ),
                        //     children: [
                        //       // CupertinoFormRow(
                        //       //   prefix: const Text("Car No Plate"),
                        //       //   child: CupertinoTextFormFieldRow(
                        //       //     controller: _carNumberController,
                        //       //     placeholder: "Car No Plate*",
                        //       //   ),
                        //       // )
                        //       CupertinoFormRow(
                        //         prefix: const Text("المستودع"),
                        //         child: CupertinoTextFormFieldRow(
                        //           controller: _pickUpPointController,
                        //           placeholder: "المستودع*",
                        //         ),
                        //       ),
                        //       CupertinoFormRow(
                        //         prefix: const Text("الفئة"),
                        //         child: CupertinoTextFormFieldRow(
                        //           controller: _feeRateController,
                        //           placeholder: "الفئة*",
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // Directionality(
                        //   textDirection: TextDirection.rtl,
                        //   child: CupertinoFormSection(
                        //     header: const Text(
                        //       "اماكن التفريغ",
                        //     ),
                        //     children: [
                        //       //Loop Over CarNoPlates["Compartments"] and add an i for each compartment
                        //       for (var i = 0;
                        //           i <
                        //               Compartments[selectedCompartmentIndex]
                        //                   .length;
                        //           i++)
                        //         CupertinoFormRow(
                        //           prefix: Text("العين ${i + 1}"),
                        //           child: CupertinoTextFormFieldRow(
                        //             controller: _dropOffPointControllers[i],
                        //             placeholder:
                        //                 "${Compartments[selectedCompartmentIndex][i]}*",
                        //           ),
                        //         ),
                        //       // for (var compartment in Compartments)
                        //       //   CupertinoFormRow(
                        //       //     prefix: Text("العين ${}"),
                        //       //     child: CupertinoTextFormFieldRow(
                        //       //       controller: _pickUpPointController,
                        //       //       placeholder: "المستودع*",
                        //       //     ),
                        //       //   ),
                        //       // CupertinoFormRow(
                        //       //   prefix: const Text("تفريغ 1"),
                        //       //   child: CupertinoTextFormFieldRow(
                        //       //     controller: _dropOffPoint1Controller,
                        //       //     placeholder: "تفريغ 1*",
                        //       //   ),
                        //       // ),
                        //       // CupertinoFormRow(
                        //       //   prefix: const Text("تفريغ 2"),
                        //       //   child: CupertinoTextFormFieldRow(
                        //       //     controller: _dropOffPoint2Controller,
                        //       //     placeholder: "تفريغ 2*",
                        //       //   ),
                        //       // ),
                        //       // CupertinoFormRow(
                        //       //   prefix: const Text("تفريغ 3"),
                        //       //   child: CupertinoTextFormFieldRow(
                        //       //     controller: _dropOffPoint3Controller,
                        //       //     placeholder: "تفريغ 3*",
                        //       //   ),
                        //       // ),
                        //     ],
                        //   ),
                        // ),
                        // const SizedBox(height: 20),
                        Center(
                          // ignore: deprecated_member_use
                          child: TextButton(
                            onPressed: () async {
                              for (var i = 0;
                                  i <
                                      Compartments[selectedCompartmentIndex]
                                          .length;
                                  i++) {
                                index++;
                              }
                              if (selectedTerminal == null ||
                                  _dropOffPointControllers[0].text.isEmpty) {
                                // Check if each text field is empty
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
                              else {
                                for (var i = 0;
                                    i <
                                        Compartments[selectedCompartmentIndex]
                                            .length;
                                    i++)
                                  _dropOffPointControllers[i].text != ""
                                      ? {
                                          DropOffPoints.add(
                                              _dropOffPointControllers[i].text),
                                          noOfDropOfPoints++
                                        }
                                      : {};
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
                                for (var i = 0;
                                    i <
                                        Compartments[selectedCompartmentIndex]
                                            .length;
                                    i++) {
                                  if (_dropOffPointControllers[i].text != "") {
                                    formattedCompartments.add(
                                      <dynamic>[
                                        Compartments[selectedCompartmentIndex]
                                            [i],
                                        _dropOffPointControllers[i].text,
                                        _gasTypeControllers[i].text,
                                      ],
                                    );
                                  }
                                }
                                try {
                                  var request = await http
                                      .post(
                                    Uri.parse('$SERVER_IP/api/CreateCarTrip'),
                                    headers: {
                                      "Cookie": "jwt=${widget.jwt}",
                                      "Content-Type": "application/json",
                                    },
                                    body: jsonEncode(
                                      {
                                        "Date": widget.currentDate,
                                        "CarNoPlate": selectedCarNoPlate,
                                        "DriverName": selectedDriver,
                                        "PickUpPoint": selectedTerminal,
                                        "NoOfDropOffPoints": noOfDropOfPoints,
                                        "Compartments": formattedCompartments,
                                        "DropOffPoints": DropOffPoints,
                                        // "FeeRate":
                                        //     double.parse(_feeRateController.text),
                                      },
                                    ),
                                  )
                                      .then((response) {
                                    if (response.statusCode == 200) {
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
                                      // Navigator.pop(dialogContext);
                                      // Navigator.pushReplacement(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder: (context) =>
                                      //         const MainWidget(),
                                      //   ),
                                      // );
                                      setState(() {
                                        Navigator.pop(dialogContext);
                                        // Rebuild Whole Page
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
                                                        Navigator
                                                            .pushReplacement(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (_) =>
                                                                CarProgressScreen(
                                                              jwt: widget.jwt,
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
                                                        Navigator
                                                            .pushReplacement(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (_) =>
                                                                const MainWidget(),
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
                                                            const MainWidget(),
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
                        // Row(
                        //   children: [
                        //     DropdownSearch(
                        //       dropdownSearchTextAlign: TextAlign.left,
                        //       searchFieldProps: TextFieldProps(
                        //         autocorrect: false,
                        //         cursorColor: Theme.of(context).primaryColor,
                        //       ),
                        //       dropdownSearchDecoration: const InputDecoration(
                        //         border: OutlineInputBorder(
                        //           borderSide: BorderSide(),
                        //         ),
                        //         labelText: "Car No Plate*",
                        //       ),
                        //       mode: Mode.MENU,
                        //       showSelectedItems: true,
                        //       showSearchBox: true,
                        //       enabled: true,
                        //       selectedItem: selectedGasType,
                        //       items: gasTypes,
                        //       onChanged: ((value) =>
                        //           selectedGasType = value.toString()),
                        //     ),
                        //   ],
                        // )
                      ],
                      // Get Current Date in the format of YYYY-MM-DD
                    ),
                  ),
                ),
              ),
            );
          }
        });
  }
}
