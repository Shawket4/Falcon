// ignore_for_file: file_names, constant_identifier_names, use_build_context_synchronously

import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

import '../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

const storage = FlutterSecureStorage();
late BuildContext dialogContext;
final _emailController = TextEditingController();
final _passwordController = TextEditingController();

Future<String> get jwtOrEmpty async {
  var jwt = await storage.read(key: "jwt");
  if (jwt == null) return "";
  return jwt;
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    storage.delete(key: "jwt");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: Stack(
            children: [
              Positioned(
                top: 200,
                left: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: const BoxDecoration(
                    color: Color(0x304599ff),
                    borderRadius: BorderRadius.all(
                      Radius.circular(150),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                right: -10,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: const BoxDecoration(
                    color: Color(0x30cc33ff),
                    borderRadius: BorderRadius.all(
                      Radius.circular(100),
                    ),
                  ),
                ),
              ),
              Positioned(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 80,
                    sigmaY: 80,
                  ),
                  child: Container(),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 50,
                      ),
                      _logo(),
                      const SizedBox(
                        height: 70,
                      ),
                      _loginLabel(),
                      const SizedBox(
                        height: 70,
                      ),
                      _labelTextInput(
                          "البريد الالكتروني", "yourname@example.com", false),
                      const SizedBox(
                        height: 50,
                      ),
                      _labelTextInput("كلمة السر", "yourpassword", true),
                      const SizedBox(
                        height: 90,
                      ),
                      _loginBtn(context),
                      const SizedBox(
                        height: 90,
                      ),
                    ],
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

Widget _loginBtn(BuildContext context) {
  return Container(
    width: double.infinity,
    height: 60,
    decoration: const BoxDecoration(
      color: Color.fromRGBO(50, 75, 205, 1),
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
    child: TextButton(
      onPressed: () async {
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
            });
        var jwt =
            await attemptLogIn(_emailController.text, _passwordController.text);
        if (jwt != null) {
          storage.write(key: "jwt", value: jwt);
          Navigator.pop(dialogContext);
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const MainWidget()));
        } else {
          Navigator.pop(dialogContext);
          displayDialog(context, "An Error Occurred",
              "No account was found matching that username and password");
        }
      },
      child: Text(
        "تسجيل الدخول",
        style: GoogleFonts.josefinSans(
          textStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 24,
          ),
        ),
      ),
    ),
  );
}

Widget _labelTextInput(String label, String hintText, bool isPassword) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Align(
        alignment: Alignment.centerRight,
        child: Text(
          label,
          style: GoogleFonts.josefinSans(
            textStyle: const TextStyle(
              color: Color(0xff8fa1b6),
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
        ),
      ),
      TextField(
        textAlign: TextAlign.right,
        obscureText: isPassword,
        cursorColor: Colors.red,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.josefinSans(
            textStyle: const TextStyle(
              color: Color(0xffc5d2e1),
              fontWeight: FontWeight.w400,
              fontSize: 20,
            ),
          ),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xffdfe8f3)),
          ),
        ),
        controller: isPassword ? _passwordController : _emailController,
      ),
    ],
  );
}

Widget _loginLabel() {
  return Center(
    child: Text(
      "تسجيل الدخول",
      style: GoogleFonts.josefinSans(
        textStyle: const TextStyle(
          color: Color(0xff164276),
          fontWeight: FontWeight.w900,
          fontSize: 34,
        ),
      ),
    ),
  );
}

Widget _logo() {
  return const Center(
    child: SizedBox(
      height: 80,
      child: Image(
        image: AssetImage(
          "images/login.png",
        ),
      ),
    ),
  );
}

void displayDialog(BuildContext context, String title, String text) =>
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(title: Text(title), content: Text(text)),
    );
Future attemptLogIn(String email, String password) async {
  var res = await http.post(
    Uri.parse("$SERVER_IP/api/login"), headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "email": email,
      "password": password,
    }),
  );
  var jsonData = jsonDecode(res.body);
  if (res.statusCode == 200 && jsonData["permission"] >= 1) {
        return res.body;
      } else {
        return null;
      }
  // Dio dio = Dio();
  // dio.options.headers['content-Type'] = 'application/json';
  //   var res = await dio.post("$SERVER_IP/api/Login",
  //       data: jsonEncode({"email": email, "password": password})).then((value) {
  //
  //   });
  //   print(res.data);
  //   var jsonData = jsonDecode(jsonEncode(res.data));
  //   print(jsonData);
  //   if (res.statusCode == 200 && jsonData["permission"] >= 1) {
  //     return "{jwt:${jsonData["jwt"]}}";
  //   } else {
  //     return null;
  //   }

    // print(res.body);

}
