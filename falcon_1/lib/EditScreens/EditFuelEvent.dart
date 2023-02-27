// ignore_for_file: non_constant_identifier_names, unused_local_variable, file_names

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:falcon_1/Screens/AllFuelEvents.dart';
import 'package:falcon_1/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

class EditFuelEvent extends StatefulWidget {
  const EditFuelEvent({super.key, required this.jwt, required this.event});
  final String jwt;
  final FuelEvent event;
  @override
  State<EditFuelEvent> createState() => _EditFuelEventState();
}

class _EditFuelEventState extends State<EditFuelEvent> {
  final TextEditingController _liters = TextEditingController();
  final TextEditingController _pricePerLiter = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _odometerBeforeController =
      TextEditingController();
  final TextEditingController _odometerAfterController =
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
    _liters.text = widget.event.Liters.toString();
    _pricePerLiter.text = widget.event.PricePerLiter.toString();
    _odometerBeforeController.text = widget.event.OdometerBefore.toString();
    _odometerAfterController.text = widget.event.OdometerAfter.toString();
    super.initState();
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
                              builder: (_) => EditFuelEvent(
                                jwt: widget.jwt,
                                event: widget.event,
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
            return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                backgroundColor: Theme.of(context).primaryColor,
                title: const Text("تعديل التفويلة"),
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
                            cursorColor: Theme.of(context).accentColor,
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
                          controller: _liters,
                          decoration: const InputDecoration(
                            label: Text("* عدد الترات"),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        TextField(
                          controller: _pricePerLiter,
                          decoration: const InputDecoration(
                            label: Text("* سعر اللتر"),
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
                          controller: _odometerBeforeController,
                          decoration: const InputDecoration(
                            label: Text("* العداد قبل"),
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
                          controller: _odometerAfterController,
                          decoration: const InputDecoration(
                            label: Text("* العداد الحالي"),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Center(
                          // ignore: deprecated_member_use
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
                                  Uri.parse(
                                      "$SERVER_IP/api/protected/EditFuelEvent"),
                                  headers: {
                                    "Cookie": "jwt=${widget.jwt}",
                                    "Content-Type": "application/json",
                                  },
                                  body: jsonEncode(
                                    {
                                      "ID": widget.event.EventId,
                                      "car_id": selectedCar["ID"],
                                      "date": _dateController.text,
                                      "liters": double.parse(
                                        _liters.text,
                                      ),
                                      "price_per_liter": double.parse(
                                        _pricePerLiter.text,
                                      ),
                                      "odometer_before": int.parse(
                                        _odometerBeforeController.text,
                                      ),
                                      "odometer_after": int.parse(
                                        _odometerAfterController.text,
                                      ),
                                    },
                                  ),
                                )
                                    .then((response) {
                                  if (response.statusCode == 200) {
                                    selectedCar = null;
                                    _dateController.clear();
                                    _liters.clear();
                                    _pricePerLiter.clear();
                                    _odometerBeforeController.clear();
                                    _odometerAfterController.clear();
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
                                                              AllFuelEvents(
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
                                                          AllFuelEvents(
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
                                "تعديل التفويلة",
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
