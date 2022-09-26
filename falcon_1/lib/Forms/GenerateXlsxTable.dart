// ignore_for_file: file_names

import 'dart:convert';
import 'dart:io';

import 'package:falcon_1/main.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class GenerateTableScreen extends StatefulWidget {
  const GenerateTableScreen({Key? key, this.jwt}) : super(key: key);
  final String? jwt;
  @override
  State<GenerateTableScreen> createState() => _GenerateTableScreenState();
}

final _dateFrom = TextEditingController();
final _dateTo = TextEditingController();

class _GenerateTableScreenState extends State<GenerateTableScreen> {
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
                                intl.DateFormat("yyyy-MM-dd").format(pickDate);
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
                                _dateFrom.text = intl.DateFormat("yyyy-MM-dd")
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
                                intl.DateFormat("yyyy-MM-dd").format(pickDate);
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
                                _dateTo.text = intl.DateFormat("yyyy-MM-dd")
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
                  onPressed: () async => {
                    await http
                        .post(
                      Uri.parse("$SERVER_IP/api/GenerateCSVTable"),
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
                      if (Platform.isIOS ||
                          Platform.isAndroid ||
                          Platform.isMacOS) {
                        bool status = await Permission.storage.isGranted;
                        if (!status) await Permission.storage.request();
                        MimeType type = MimeType.OTHER;
                        await FileSaver.instance.saveAs("Table", bodyBytes, "xlsx", type);
                      }
                    }),
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
