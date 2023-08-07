// ignore_for_file: unused_local_variable

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:lottie/lottie.dart';

import '../main.dart';

class AddDriverLoanScreen extends StatefulWidget {
  const AddDriverLoanScreen({super.key, required this.jwt, required this.id});
  final String jwt;
  final int id;
  @override
  State<AddDriverLoanScreen> createState() => _AddDriverLoanScreenState();
}

class _AddDriverLoanScreenState extends State<AddDriverLoanScreen> {
  Dio dio = Dio();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController methodController = TextEditingController();

  late BuildContext dialogContext;
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
        title: const Text("Register Loan"),
      ),
      body: Center(
          child: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(30),
          child: ListView(
            children: <Widget>[
              GestureDetector(
                onTap: () async {
                  DateTime? pickDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2099));
                  if (pickDate != null) {
                    dateController.text =
                        intl.DateFormat("yyyy-MM-dd").format(pickDate);
                  }
                },
                child: TextField(
                  enabled: false,
                  controller: dateController,
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
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(),
                decoration: const InputDecoration(
                  label: Text("Amount *"),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              TextField(
                controller: methodController,
                decoration: const InputDecoration(
                  label: Text("Method *"),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Center(
                child: TextButton(
                  onPressed: () async {
                    dialogContext = context;
                    try {
                      var res = await dio
                          .post("$SERVER_IP/api/RegisterTripLoans/", data: {
                        "trip_id": widget.id,
                        "loans": [
                          {
                            "date": dateController.text,
                            "amount":
                                double.parse(amountController.text.toString()),
                            "method": methodController.text,
                          }
                        ]
                      }).then((response) {
                        if (response.statusCode == 200) {
                          // _currentOdometerController.clear();
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
                                              "lottie/Success.json",
                                              height: 300,
                                              width: 300,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(dialogContext);

                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => HomeScreen(
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
                      }).timeout(const Duration(seconds: 4));
                    } catch (e) {
                      print(e);
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: SizedBox(
                                height: 400,
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
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => HomeScreen(
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
                      "Register Loan",
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
      )),
    );
  }
}
