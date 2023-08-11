// ignore_for_file: file_names

import 'dart:convert';
import 'dart:io';

import 'package:falcon_1/main.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';

class GenerateFuelTableScreen extends StatefulWidget {
  const GenerateFuelTableScreen({Key? key, this.jwt}) : super(key: key);
  final String? jwt;
  @override
  State<GenerateFuelTableScreen> createState() =>
      _GenerateFuelTableScreenState();
}

final _dateFrom = TextEditingController();
final _dateTo = TextEditingController();

class _GenerateFuelTableScreenState extends State<GenerateFuelTableScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'تحميل الجدول',
          style: GoogleFonts.josefinSans(
            textStyle: const TextStyle(
              fontSize: 22,
            ),
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              Directionality(
                textDirection: TextDirection.rtl,
                child: CupertinoFormSection(
                  header: const Text(
                    "التفاصيل",
                  ),
                  children: [
                    GestureDetector(
                      onTap: () async {
                        DateTime? pickDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2099));
                        if (pickDate != null) {
                          setState(() {
                            _dateFrom.text =
                                intl.DateFormat("dd-MM-yyyy").format(pickDate);
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
                            Text("من"),
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
                                _dateFrom.text = intl.DateFormat("dd-MM-yyyy")
                                    .format(pickDate);
                              });
                            }
                          },
                          controller: _dateFrom,
                          placeholder: "التاريخ من*",
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
                            _dateTo.text =
                                intl.DateFormat("dd-MM-yyyy").format(pickDate);
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
                            Text("الي"),
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
                                _dateTo.text = intl.DateFormat("dd-MM-yyyy")
                                    .format(pickDate);
                              });
                            }
                          },
                          controller: _dateTo,
                          placeholder: "التاريخ الي*",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                // ignore: deprecated_member_use
                child: TextButton(
                  onPressed: () async {
                    try {
                      await http
                          .post(
                        Uri.parse("$SERVER_IP/api/protected/GenerateFuelTable"),
                        headers: {
                          "Content-Type": "application/json",
                          "Cookie": "jwt=${widget.jwt}",
                        },
                        body: jsonEncode({
                          "DateFrom": _dateFrom.text,
                          "DateTo": _dateTo.text,
                        }),
                      )
                          .then((value) async {
                        var bodyBytes = value.bodyBytes;
                        if (Platform.isIOS || Platform.isAndroid) {
                          bool status = await Permission.storage.isGranted;
                          if (!status) await Permission.storage.request();
                          MimeType type = MimeType.OTHER;
                          await FileSaver.instance.saveAs(
                              "Fuel_Table ${_dateFrom.text}-${_dateTo.text}",
                              bodyBytes,
                              "xlsx",
                              type);
                        } else {
                          String? filePath = await FilePicker.platform.saveFile(
                              dialogTitle: "Save File",
                              fileName:
                                  "Fuel_Table ${_dateFrom.text}-${_dateTo.text}.xlsx");
                          File file = File(filePath!);
                          file.writeAsBytes(bodyBytes);
                        }
                      }).timeout(
                        const Duration(seconds: 4),
                      );
                    } catch (e) {
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
                                        setState(() {
                                          Navigator.pop(context);
                                        });
                                        // Navigator.pushReplacement(
                                        //   context,
                                        //   MaterialPageRoute(
                                        //     builder: (_) => CarProgressScreen(
                                        //       jwt: widget.jwt.toString(),
                                        //     ),
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
                      "تحميل الجدول",
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
    );
  }
}
