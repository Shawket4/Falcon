// ignore_for_file: file_names, non_constant_identifier_names
import 'package:dio/dio.dart';
import 'package:falcon_1/DetailScreens/TransporterProfileDetails.dart';
import 'package:falcon_1/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class AllTransporters extends StatefulWidget {
  const AllTransporters({Key? key, required this.jwt}) : super(key: key);
  final String jwt;
  @override
  State<AllTransporters> createState() => _AllTransportersState();
}
List<dynamic> TransporterList = [];
Dio dio = Dio();
Future<String> get loadData async {
  if (TransporterList.isEmpty) {
    var res = await dio.post("$SERVER_IP/api/GetTransporterProfileData").then((
        response) {
      // Print Json Response  where date is = DateFrom
      for (var i = 0; i < response.data.length; i++) {
        TransporterList.add(response.data[i]);
      }
      TransporterList.sort((a, b) =>
          a['TransporterName'].compareTo(b['TransporterName']));
      return "";
    });
    return "";
  } else {
    return "";
  }
}

class _AllTransportersState extends State<AllTransporters> {

  @override
  void initState() {
    // Empty the list of Transporters
    TransporterList.clear();
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
        title: const Text('المقاولين'),
      ),
      body: FutureBuilder(
          future: loadData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) =>
                      //         TransporterProfileDetails(),
                      //   ),
                      // );
                    },
                    child: Card(
                      elevation: 4,
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Hero(
                              tag: "Transporter ${TransporterList[index]["TransporterId"].toString()}",
                              child: const CircleAvatar(
                                backgroundImage: AssetImage('images/truck.jpg'),
                                radius: 35,
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                TransporterList[index]['TransporterName'],
                                style: GoogleFonts.josefinSans(
                                  textStyle: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                itemCount: TransporterList.length,
              );
            } else {
              return Center(
                // Display lottie animation
                child: Lottie.asset(
                  "lottie/SplashScreen.json",
                  height: 200,
                  width: 200,
                ),
              );
            }
          }),
    );
  }
}
