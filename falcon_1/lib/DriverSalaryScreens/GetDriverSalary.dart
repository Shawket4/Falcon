import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

import '../main.dart';

class GetDriverSalary extends StatefulWidget {
  const GetDriverSalary({super.key, required this.driverID, required this.jwt});
  final int driverID;
  final String jwt;

  @override
  State<GetDriverSalary> createState() => _GetDriverSalaryState();
}

class _GetDriverSalaryState extends State<GetDriverSalary> {
  final TextEditingController _dateFrom = TextEditingController();
  final TextEditingController _dateTo = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Get Driver Salary',
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
              CupertinoFormSection(
                header: const Text(
                  "Details",
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
                          Text("From"),
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
                        placeholder: "Date From*",
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
                          Text("To"),
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
                        placeholder: "Date To*",
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                // ignore: deprecated_member_use
                child: TextButton(
                  onPressed: () async {
                    try {
                      await http
                          .post(
                        Uri.parse("$SERVER_IP/api/CalculateDriverSalary"),
                        headers: {
                          "Content-Type": "application/json",
                          "Cookie": "jwt=${widget.jwt}",
                        },
                        body: jsonEncode({
                          "id": widget.driverID,
                          "date_from": _dateFrom.text,
                          "date_to": _dateTo.text,
                        }),
                      )
                          .then((response) async {
                        if (response.body != "") {
                          print("No Data Returned");
                        }
                        var bodyBytes = response.bodyBytes;
                        if (Platform.isIOS || Platform.isAndroid) {
                          bool status = await Permission.storage.isGranted;
                          if (!status) await Permission.storage.request();
                          MimeType type = MimeType.OTHER;
                          await FileSaver.instance
                              .saveAs("Table", bodyBytes, "xlsx", type);
                        } else {
                          String? filePath = await FilePicker.platform.saveFile(
                              dialogTitle: "Save File", fileName: "Table.xlsx");
                          File file = File(filePath!);
                          file.writeAsBytes(bodyBytes);
                        }
                      }).timeout(
                        const Duration(seconds: 4),
                      );
                    } catch (e) {
                      print(e);
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
                      "Get Salary",
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
