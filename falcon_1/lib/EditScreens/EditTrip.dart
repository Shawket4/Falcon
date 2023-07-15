// ignore_for_file: use_key_in_widget_constructors, file_names, unused_element, use_build_context_synchronously, non_constant_identifier_names, unused_field, unused_local_variable, must_be_immutable, deprecated_member_use

import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:falcon_1/Screens/CarProgressScreen.dart';
import 'package:falcon_1/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;
import 'package:dio/dio.dart';
import 'package:lottie/lottie.dart';

class EditCarTripScreen extends StatefulWidget {
  EditCarTripScreen(this.jwt, this.trip);
  final String jwt;
  final dynamic trip;

  // Current Date in the format of YYYY-MM-DD
  late String currentDate;
  @override
  State<EditCarTripScreen> createState() => _EditCarTripScreenState();
}

// Text Controllers

class _EditCarTripScreenState extends State<EditCarTripScreen> {
  final _pickUpPointController = TextEditingController();
  final _feeRateController = TextEditingController();
  int index = 0;
  final List<TextEditingController> _dropOffPointControllers = [];
  final List<TextEditingController> _gasTypeControllers = [];
  final TextEditingController _driverNameController = TextEditingController();
  var noOfDropOfPoints = 0;
  var DropOffPoints = [];
  List<dynamic> Cars = [];
  List<String> CarNoList = [];
  List<dynamic> Drivers = [];
  List<String> DriverNameList = [];
  var Compartments = [];
  List<String> Terminals = [];
  List<String> Customers = [];
  List<Widget> CustomerWidgets = [];
  String? selectedCarNoPlate;
  int selectedCompartmentIndex = 0;
  dynamic selectedCar;
  dynamic selectedDriver;
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
    "Empty",
  ];

  bool isLoaded = false;

  Future<Object> get loadData async {
    try {
      if (selectedCar == null) {
        var CarReq = await dio
            .post("$SERVER_IP/api/GetCars",
                data: jsonEncode({
                  "Include": "",
                }))
            .then((response) {
          Cars = response.data;
          // print(Cars.toList().toString());
          for (var car in Cars) {
            CarNoList.add(car["car_no_plate"]);
          }
          // var carCompartments = str["Compartments"];
          selectedCar = Cars.firstWhere(
              (element) => element["car_no_plate"] == widget.trip.carNoPlate);
          // print(selectedCar.toString());
          // var isInTripList = str["IsInTripList"];
          // IsInTripList.clear();
          // for (var car in Cars) {
          //   CarNoPlates[car] = false;
          // }
          // for (var compartment in carCompartments) {
          //   Compartments.add(compartment);
          // }
          // for (var isInTrip in isInTripList) {
          //   CarNoPlates[CarNoPlates.keys.toList()[i]] = isInTrip;
          //   i++;
          // }
          // Loop 6 times
          for (var i = 0; i < 6; i++) {
            _dropOffPointControllers.add(TextEditingController());
            _gasTypeControllers.add(TextEditingController());
          }
        });
        Drivers.add("غير محدد");
        var DriverReq =
            await dio.post("$SERVER_IP/api/GetDrivers").then((response) {
          Drivers = response.data;
          for (var driver in Drivers) {
            DriverNameList.add(driver["name"]);
          }
          selectedDriver = Drivers.firstWhere(
              (element) => element["name"] == widget.trip.driverName);
        });
        var LocationsReq =
            await dio.get("$SERVER_IP/api/GetLocations").then((response) {
          var str = response.data;
          for (var terminal in str["Terminals"]) {
            Terminals.add(terminal);
          }

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
      "Cars": Cars,
      "Drivers": Drivers,
      "Terminals": Terminals,
      "Customers": Customers,
    };
  }

  @override
  void initState() {
    dio.options.headers["Cookie"] = "jwt=${widget.jwt}";
    dio.options.headers["Content-Type"] = "application/json";
    selectedGasType = gasTypes[0];
    selectedCar = null;
    selectedDriver = null;
    widget.currentDate = widget.trip.date;
    for (var i = 0; i < 6; i++) {
      _dropOffPointControllers.add(TextEditingController());
      _gasTypeControllers.add(TextEditingController());
    }

    // for (var i = 0; i < selectedCar["json_compartments"].length; i++) {
    //   _dropOffPointControllers[i].text =
    //       widget.carTripDetails["Compartments"][i][1];
    //   _gasTypeControllers[i].text = widget.carTripDetails["Compartments"][i][2];
    // }
    // _pickUpPointController.text =
    //     jsonDecode(widget.carTripDetails["StepCompleteTime"])["TruckLoad"][1];
    selectedTerminal =
        widget.trip.stepCompleteTimeDb.terminal.terminalName.toString();
    selectedGasType = gasTypes[0];
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
                              builder: (_) =>
                                  EditCarTripScreen(widget.jwt, widget.trip),
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
          }

          if (snapshot.data != "") {}
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: Theme.of(context).primaryColor,
              title: const Text("تعديل الرحلة"),
            ),
            body: Center(
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(30),
                  child: ListView(
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
                      //   _pickUpPointController.clear();
                      //   for (var i = 0;
                      //       i <
                      //           Compartments[selectedCompartmentIndex]
                      //               .length;
                      //       i++) {
                      //     _dropOffPointControllers[i].clear();
                      //   }
                      //   selectedCarNoPlate = item;
                      //   // Set the selected compartment index to item index
                      //   selectedCompartmentIndex =
                      //       CarNoPlates.indexOf(item);
                      // }),
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
                        popupItemBuilder: (context, item, isSelected) {
                          // dynamic Car = Cars.where(
                          //   (element) => element["car_no_plate"] == item,
                          // ).toList()[0];
                          return SizedBox(
                            height: 50,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Text(
                                          item,
                                          style: TextStyle(
                                            color: isSelected
                                                ? Theme.of(context).primaryColor
                                                : Cars.where((element) =>
                                                                element[
                                                                    "car_no_plate"] ==
                                                                item).toList()[
                                                            0]["is_in_trip"] ==
                                                        true
                                                    ? Colors.grey
                                                    : Colors.black,
                                            fontSize: 17,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
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
                        items: CarNoList,
                        selectedItem: selectedCar["car_no_plate"],
                        onChanged: (item) => setState(() {
                          _pickUpPointController.clear();
                          // for (var i = 0;
                          //     i < Compartments[selectedCompartmentIndex].length;
                          //     i++) {
                          //   _dropOffPointControllers[i].clear();
                          // }
                          dynamic Car = Cars.where(
                                  (element) => element["car_no_plate"] == item)
                              .toList()[0];
                          selectedCar = Car;
                          // Set the selected compartment index to item index
                        }),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      DropdownSearch<String>(
                        dropdownSearchTextAlign: TextAlign.left,
                        searchFieldProps: TextFieldProps(
                          autocorrect: false,
                          cursorColor: Theme.of(context).primaryColor,
                        ),
                        popupItemBuilder: (context, item, isSelected) {
                          return SizedBox(
                            height: 50,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Text(
                                          item,
                                          style: TextStyle(
                                            color: isSelected
                                                ? Theme.of(context).primaryColor
                                                : Drivers.where((element) =>
                                                                element[
                                                                    "name"] ==
                                                                item).toList()[
                                                            0]["is_in_trip"] ==
                                                        true
                                                    ? Colors.grey
                                                    : Colors.black,
                                            fontSize: 17,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
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
                        items: DriverNameList,
                        selectedItem: selectedDriver["name"],
                        onChanged: (item) => setState(() {
                          _pickUpPointController.clear();
                          // for (var i = 0;
                          //     i < Compartments[selectedCompartmentIndex].length;
                          //     i++) {
                          //   _dropOffPointControllers[i].clear();
                          // }
                          dynamic Driver = Drivers.where(
                              (element) => element["name"] == item).toList()[0];
                          selectedDriver = Driver;
                          // Set the selected compartment index to item index
                        }),
                      ),
                      // DropdownSearch<String>(

                      //   dropdownSearchDecoration: const InputDecoration(
                      //     border: OutlineInputBorder(
                      //       borderSide: BorderSide(),
                      //     ),
                      //     labelText: "Driver Name*",
                      //   ),
                      //   mode: Mode.MENU,
                      //   showSelectedItems: true,
                      //   showSearchBox: true,
                      //   enabled: true,
                      //   items: Drivers,
                      //   selectedItem: selectedDriver,
                      //   onChanged: (item) => setState(() {
                      //     selectedDriver = item as String;
                      //   }),
                      // ),
                      // TextField(
                      //   cursorColor: Theme.of(context).primaryColor,
                      //   controller: _driverNameController,
                      //   decoration: const InputDecoration(
                      //     label: Text("Driver Name*"),
                      //     border: OutlineInputBorder(),
                      //   ),
                      // ),
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
                        popupItemBuilder: (context, item, isSelected) =>
                            SizedBox(
                          height: 50,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text(
                                        item,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Theme.of(context).primaryColor
                                              : Colors.black,
                                          fontSize: 17,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        showSelectedItems: true,
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          autocorrect: false,
                          cursorColor: Theme.of(context).primaryColor,
                        ),
                        enabled: true,
                        items: Terminals,
                        selectedItem: selectedTerminal,
                        onChanged: (item) => setState(() {
                          selectedTerminal = item as String;
                        }),
                      ),

                      for (var i = 1;
                          i < selectedCar["json_compartments"].length + 1;
                          i++)
                        Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: DropdownSearch<String>(
                                    searchFieldProps: TextFieldProps(
                                      autocorrect: false,
                                      cursorColor:
                                          Theme.of(context).primaryColor,
                                    ),
                                    popupItemBuilder:
                                        (context, item, isSelected) => SizedBox(
                                      height: 50,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            children: [
                                              Center(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      10.0),
                                                  child: Text(
                                                    item,
                                                    style: TextStyle(
                                                      color: isSelected
                                                          ? Theme.of(context)
                                                              .primaryColor
                                                          : Colors.black,
                                                      fontSize: 17,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    dropdownSearchDecoration: InputDecoration(
                                      border: const OutlineInputBorder(
                                        borderSide: BorderSide(),
                                      ),
                                      labelText:
                                          "Customer $i ${selectedCar["json_compartments"][i - 1]}*",
                                    ),
                                    mode: Mode.MENU,
                                    showSelectedItems: true,
                                    showSearchBox: true,
                                    enabled: true,
                                    items: Customers,
                                    dropdownBuilder: (context, selectedItem) =>
                                        Text(
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
                                  searchFieldProps: TextFieldProps(
                                    autocorrect: false,
                                    cursorColor: Theme.of(context).primaryColor,
                                  ),
                                  popupItemBuilder:
                                      (context, item, isSelected) => SizedBox(
                                    height: 50,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Center(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: Text(
                                                  item,
                                                  style: TextStyle(
                                                    color: isSelected
                                                        ? Theme.of(context)
                                                            .primaryColor
                                                        : Colors.black,
                                                    fontSize: 17,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
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
                                  selectedItem: _gasTypeControllers[i - 1].text,
                                  onChanged: (item) => setState(() {
                                    _gasTypeControllers[i - 1].text =
                                        item as String;
                                    if (item == "Empty") {
                                      _dropOffPointControllers[i - 1].text =
                                          item;
                                    }
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ),
                      IconButton(
                        onPressed: () async {
                          DateTime? pickDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2099),
                          );
                          if (pickDate != null) {
                            widget.currentDate =
                                intl.DateFormat("yyyy-MM-dd").format(pickDate);
                          }
                        },
                        icon: const Icon(Icons.calendar_today),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Center(
                        child: TextButton(
                          onPressed: () async {
                            for (var i = 0;
                                i < selectedCar["json_compartments"].length;
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
                                  i < selectedCar["json_compartments"].length;
                                  i++) {
                                _dropOffPointControllers[i].text != ""
                                    ? {
                                        DropOffPoints.add({
                                          "time_stamp": "",
                                          "location_name":
                                              _dropOffPointControllers[i].text,
                                          "capacity":
                                              selectedCar["json_compartments"]
                                                  [i],
                                          "gas_type":
                                              _gasTypeControllers[i].text,
                                          "status": false,
                                        }),
                                        noOfDropOfPoints++
                                      }
                                    : {};
                              }
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
                                  i < selectedCar["json_compartments"].length;
                                  i++) {
                                if (_dropOffPointControllers[i].text != "") {
                                  formattedCompartments.add(
                                    <dynamic>[
                                      selectedCar["json_compartments"][i],
                                      _dropOffPointControllers[i].text,
                                      _gasTypeControllers[i].text,
                                    ],
                                  );
                                }
                              }
                              try {
                                var request = await http
                                    .post(
                                  Uri.parse('$SERVER_IP/api/EditCarTrip'),
                                  headers: {
                                    "Cookie": "jwt=${widget.jwt}",
                                    "Content-Type": "application/json",
                                  },
                                  body: jsonEncode(
                                    {
                                      "ID": widget.trip.id,
                                      "date": widget.currentDate,
                                      "car_id": selectedCar["ID"],
                                      "driver_id": selectedDriver["ID"],
                                      "pick_up_point": selectedTerminal,
                                      "no_of_drop_off_points": noOfDropOfPoints,
                                      "Compartments": formattedCompartments,
                                      "step_complete_time": {
                                        "terminal": {
                                          "time_stamp": "",
                                          "terminal_name": selectedTerminal,
                                          "status": false,
                                        },
                                        "drop_off_points": DropOffPoints
                                      },
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
                                    // for (var i = 0;
                                    //     i <
                                    //         Compartments[
                                    //                 selectedCompartmentIndex]
                                    //             .length;
                                    //     i++) {
                                    //   _dropOffPointControllers[i].clear();
                                    // }
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
                                                      Navigator.pushReplacement(
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
                                }).timeout(
                                  const Duration(seconds: 4),
                                );
                              } catch (e) {
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
                                                  Navigator.pushReplacement(
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
                              "تعديل الرحلة",
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
