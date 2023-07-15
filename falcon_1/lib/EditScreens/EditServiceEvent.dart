// ignore_for_file: non_constant_identifier_names, unused_local_variable, file_names, deprecated_member_use

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:falcon_1/Screens/AllServiceEvents.dart';
import 'package:falcon_1/Screens/CarProgressScreen.dart';
import 'package:falcon_1/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

class EditServiceEvent extends StatefulWidget {
  const EditServiceEvent({
    super.key,
    required this.jwt,
    required this.event,
  });
  final String jwt;
  final ServiceEvent event;
  @override
  State<EditServiceEvent> createState() => _EditServiceEventState();
}

class _EditServiceEventState extends State<EditServiceEvent> {
  final TextEditingController _serviceTypeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _serviceOdometerController =
      TextEditingController();
  final TextEditingController _currentOdometerController =
      TextEditingController();
  dynamic selectedCar;
  List<dynamic> Cars = [];
  List<String> CarNoList = [];
  BuildContext? dialogContext;
  Dio dio = Dio();
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
          for (var car in Cars) {
            CarNoList.add(car["car_no_plate"]);
          }
          // var carCompartments = str["Compartments"];
          selectedCar = Cars.firstWhere(
              (element) => element["car_no_plate"] == widget.event.CarNoPlate);
        });
      }
    } catch (e) {
      return "Error";
    }
    return {
      "Cars": Cars,
    };
  }

  @override
  void initState() {
    dio.options.headers["Cookie"] = "jwt=${widget.jwt}";
    dio.options.headers["Content-Type"] = "application/json";
    selectedCar = null;
    _dateController.text = widget.event.Date;
    _serviceTypeController.text = widget.event.ServiceType;
    _serviceOdometerController.text = widget.event.Odometer.toString();
    super.initState();
  }

  @override
  void dispose() {
    selectedCar = null;
    _dateController.clear();
    _serviceTypeController.clear();
    _serviceOdometerController.clear();
    _currentOdometerController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                              builder: (_) => AllServiceEvents(jwt: widget.jwt),
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
                title: Text("${widget.event.CarNoPlate} تعديل صيانة"),
              ),
              body: Center(
                child: SafeArea(
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    child: ListView(
                      children: [
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
                                            style: const TextStyle(
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
                            // for (var i = 0;
                            //     i < Compartments[selectedCompartmentIndex].length;
                            //     i++) {
                            //   _dropOffPointControllers[i].clear();
                            // }
                            dynamic Car = Cars.where((element) =>
                                element["car_no_plate"] == item).toList()[0];
                            selectedCar = Car;
                            // Set the selected compartment index to item index
                          }),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        GestureDetector(
                          onTap: () async {
                            DateTime? pickDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2099));
                            if (pickDate != null) {
                              _dateController.text =
                                  intl.DateFormat("yyyy-MM-dd")
                                      .format(pickDate);
                            }
                          },
                          child: TextField(
                            enabled: false,
                            controller: _dateController,
                            decoration: const InputDecoration(
                              suffixIcon: Icon(Icons.calendar_today),
                              label: Text("Date *"),
                              disabledBorder: OutlineInputBorder(),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        TextField(
                          controller: _serviceTypeController,
                          decoration: const InputDecoration(
                            label: Text("نوع الصيانة *"),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        TextField(
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          controller: _serviceOdometerController,
                          decoration: const InputDecoration(
                            label: Text("عداد الصيانة*"),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Center(
                          child: TextButton(
                            onPressed: () async {
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
                              try {
                                var request = await http
                                    .post(
                                  Uri.parse("$SERVER_IP/api/EditServiceEvent"),
                                  headers: {
                                    "Cookie": "jwt=${widget.jwt}",
                                    "Content-Type": "application/json",
                                  },
                                  body: jsonEncode(
                                    {
                                      "ID": widget.event.ServiceId,
                                      "car_id": selectedCar["ID"],
                                      "service_type":
                                          _serviceTypeController.text,
                                      "date_of_service": _dateController.text,
                                      "odometer_reading": int.parse(
                                        _serviceOdometerController.text,
                                      )
                                    },
                                  ),
                                )
                                    .then((response) {
                                  if (response.statusCode == 200) {
                                    selectedCar = null;
                                    _serviceTypeController.clear();
                                    _dateController.clear();
                                    _serviceOdometerController.clear();
                                    _currentOdometerController.clear();
                                    setState(() {
                                      Navigator.pop(dialogContext!);
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
                                                            dialogContext!);
                                                      });
                                                      Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (_) =>
                                                              AllServiceEvents(
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
                                                            dialogContext!);
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
                                }).timeout(const Duration(seconds: 4));
                              } catch (_) {
                                showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) {
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
                                "تعديل الصيانة",
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
                    ),
                  ),
                ),
              ),
            );
          }
        });
  }
}
