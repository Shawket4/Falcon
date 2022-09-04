// ignore_for_file: file_names

import 'dart:convert';

import 'package:falcon_1/Screens/CarProgressScreen.dart';
import 'package:falcon_1/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;

class AddTransporter extends StatefulWidget {
  const AddTransporter({Key? key, required this.jwt}) : super(key: key);
  final String jwt;
  @override
  State<AddTransporter> createState() => _AddTransporterState();
}

final _nameController = TextEditingController();
final _emailController = TextEditingController();
final _passwordController = TextEditingController();
List<TextEditingController> _phoneControllers = [];
List<TextEditingController> _phoneNameControllers = [];
List<CupertinoFormRow> formChildren = [];
int _phoneCount = 0;
List<Map<String, String>> phoneNumbers = [];
late BuildContext dialogContext;

class _AddTransporterState extends State<AddTransporter> {
  @override
  void initState() {
    _nameController.clear();
    formChildren = [];
    _phoneControllers = [];
    _phoneNameControllers = [];
    phoneNumbers = [];
    _phoneControllers.add(TextEditingController());
    _phoneNameControllers.add(TextEditingController());
    _phoneCount = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          _phoneCount++;
          _phoneControllers.add(TextEditingController());
          _phoneNameControllers.add(TextEditingController());
          formChildren.add(CupertinoFormRow(
            prefix: const Text("رقم الهاتف"),
            child: CupertinoTextFormFieldRow(
              controller: _phoneControllers[_phoneCount],
              placeholder: "رقم الهاتف*",
            ),
          ));
          formChildren.add(CupertinoFormRow(
            prefix: const Text("الأسم"),
            child: CupertinoTextFormFieldRow(
              controller: _phoneNameControllers[_phoneCount],
              placeholder: "الأسم*",
            ),
          ));

          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'إضافة مقاول',
          style: GoogleFonts.josefinSans(
            textStyle: const TextStyle(
              fontSize: 22,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: <Widget>[
              Directionality(
                textDirection: TextDirection.rtl,
                child: CupertinoFormSection(
                  header: const Text(
                    "تفاصيل المقاول",
                  ),
                  children: [
                    CupertinoFormRow(
                      prefix: const Text("أسم المقاول"),
                      child: CupertinoTextFormFieldRow(
                        controller: _nameController,
                        placeholder: "أسم المقاول*",
                      ),
                    ),
                    CupertinoFormRow(
                      prefix: const Text("البريد الإلكتروني"),
                      child: CupertinoTextFormFieldRow(
                        controller: _emailController,
                        placeholder: "البريد الإلكتروني*",
                      ),
                    ),
                    CupertinoFormRow(
                      prefix: const Text("كلمة المرور"),
                      child: CupertinoTextFormFieldRow(
                        controller: _passwordController,
                        placeholder: "كلمة المرور*",
                        obscureText: true,
                      ),
                    ),
                    CupertinoFormRow(
                      prefix: const Text("رقم الهاتف"),
                      child: CupertinoTextFormFieldRow(
                        controller: _phoneControllers[0],
                        placeholder: "رقم الهاتف*",
                      ),
                    ),
                    CupertinoFormRow(
                      prefix: const Text("الأسم"),
                      child: CupertinoTextFormFieldRow(
                        controller: _phoneNameControllers[0],
                        placeholder: "الأسم*",
                      ),
                    ),
                    ...formChildren,
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                // ignore: deprecated_member_use
                child: FlatButton(
                  onPressed: () async => {
                    if (_nameController.text.isEmpty ||
                        _phoneControllers[0].text.isEmpty ||
                        _phoneNameControllers[0].text.isEmpty ||
                        _emailController.text.isEmpty ||
                        _passwordController.text.isEmpty)
                      {
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
                        ),
                      }
                    else
                      {
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
                        // Make a list of map of phoneNumber and phoneName

                        for (int i = 0; i <= _phoneCount; i++)
                          {
                            phoneNumbers.add({
                              _phoneNameControllers[i].text:
                                  _phoneControllers[i].text,
                            }),
                          },

                        await http
                            .post(
                          Uri.parse("$SERVER_IP/api/RegisterTransporter"),
                          headers: {
                            "Content-Type": "application/json",
                            "Cookie": "jwt=${widget.jwt}"
                          },
                          body: jsonEncode(
                            {
                              "TransporterName": _nameController.text,
                              "TransporterPhones": phoneNumbers,
                            },
                          ),
                        )
                            .then((value) async {
                          // print(value.body);
                          await http.post(
                            Uri.parse("$SERVER_IP/api/RegisterUser"),
                            headers: {
                              "Content-Type": "application/json",
                              "Cookie": "jwt=${widget.jwt}",
                            },
                            body: jsonEncode({
                              "name": _nameController.text,
                              "email": _emailController.text,
                              "password": _passwordController.text,
                              "permission": "1",
                            }),
                          );
                          _nameController.clear();
                          formChildren = [];
                          _phoneControllers = [];
                          _phoneNameControllers = [];
                          phoneNumbers = [];
                          _phoneControllers.add(TextEditingController());
                          _phoneNameControllers.add(TextEditingController());
                          _phoneCount = 0;
                        }),
                      },
                    Navigator.pop(dialogContext),
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CarProgressScreen(
                          jwt: widget.jwt.toString(),
                        ),
                      ),
                    ),
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
                      "إضافة المقاول",
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
    );
  }
}
