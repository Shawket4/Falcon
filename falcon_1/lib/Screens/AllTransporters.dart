// ignore_for_file: file_names, non_constant_identifier_names, unused_local_variable
import 'package:dio/dio.dart';
import 'package:falcon_1/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:lottie/lottie.dart';

class AllTransporters extends StatefulWidget {
  const AllTransporters({Key? key, required this.jwt}) : super(key: key);
  final String jwt;
  @override
  State<AllTransporters> createState() => _AllTransportersState();
}

List<dynamic> TransporterList = [];
Dio dio = Dio();

class _AllTransportersState extends State<AllTransporters> {
  Future<String> get loadData async {
    if (TransporterList.isEmpty) {
      try {
        var res = await dio
            .post("$SERVER_IP/api/GetTransporterProfileData")
            .then((response) {
          // Print Json Response  where date is = DateFrom
          for (var i = 0; i < response.data.length; i++) {
            TransporterList.add(response.data[i]);
          }
          TransporterList.sort(
              (a, b) => a['TransporterName'].compareTo(b['TransporterName']));
        });
      } catch (e) {
        return "Error";
      }
    }
    setState(() {});
    return "";
  }

  Future<void> reloadData() async {
    TransporterList.clear();
    var res = await dio
        .post("$SERVER_IP/api/GetTransporterProfileData")
        .then((response) {
      // Print Json Response  where date is = DateFrom
      for (var i = 0; i < response.data.length; i++) {
        TransporterList.add(response.data[i]);
      }
      TransporterList.sort(
          (a, b) => a['TransporterName'].compareTo(b['TransporterName']));
    });
    setState(() {});
    return;
  }

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
            if (!snapshot.hasData) {
              return Center(
                // Display lottie animation
                child: Lottie.asset(
                  "lottie/SplashScreen.json",
                  height: 200,
                  width: 200,
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
                                builder: (_) => AllTransporters(
                                  jwt: widget.jwt,
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
              return LiquidPullToRefresh(
                onRefresh: reloadData,
                animSpeedFactor: 1.5,
                backgroundColor: Colors.grey[300],
                color: Theme.of(context).primaryColor,
                height: 200,
                child: ListView(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
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
                                    tag:
                                        "Transporter ${TransporterList[index]["TransporterId"].toString()}",
                                    child: const CircleAvatar(
                                      backgroundImage:
                                          AssetImage('images/truck.jpg'),
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
                    ),
                  ],
                ),
              );
            }
          }),
    );
  }
}
