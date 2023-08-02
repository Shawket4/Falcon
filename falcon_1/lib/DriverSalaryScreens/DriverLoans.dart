// ignore_for_file: non_constant_identifier_names, unused_local_variable

import 'package:dio/dio.dart';
import 'package:falcon_1/DriverSalaryScreens/AddDriverLoanScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:lottie/lottie.dart';

import '../main.dart';

class DriverLoans extends StatefulWidget {
  const DriverLoans(
      {super.key,
      required this.jwt,
      required this.id,
      required this.driverName});
  final String jwt;
  final String driverName;
  final int id;
  @override
  State<DriverLoans> createState() => _DriverLoansState();
}

List<dynamic> LoanList = [];
Dio dio = Dio();

class _DriverLoansState extends State<DriverLoans> {
  Future<String> get loadData async {
    if (LoanList.isEmpty) {
      try {
        var res = await dio.post("$SERVER_IP/api/GetDriverLoans", data: {
          "id": widget.id,
        }).then((response) {
          // Print Json Response  where date is = DateFrom
          for (var i = 0; i < response.data.length; i++) {
            LoanList.add(response.data[i]);
          }
          LoanList.sort((a, b) => a['date'].compareTo(b['date']));
        }).timeout(
          const Duration(seconds: 4),
        );
      } catch (e) {
        return "Error";
      }
    }
    setState(() {});
    return "";
  }

  Future<void> reloadData() async {
    LoanList.clear();
    var res = await dio.post("$SERVER_IP/api/GetDriverLoans").then((response) {
      // Print Json Response  where date is = DateFrom
      for (var i = 0; i < response.data.length; i++) {
        LoanList.add(response.data[i]);
      }
      LoanList.sort((a, b) => a['date'].compareTo(b['date']));
    }).timeout(
      const Duration(seconds: 4),
    );

    setState(() {});
    return;
  }

  @override
  void initState() {
    //Clear list
    LoanList.clear();
    // Empty the list of cars
    dio.options.headers["Cookie"] = "jwt=${widget.jwt}";
    dio.options.headers["Content-Type"] = "application/json";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddDriverLoanScreen(
                      jwt: widget.jwt,
                      id: widget.id,
                    ),
                  ),
                );
              },
              icon: const Icon(
                Icons.add_circle_rounded,
                color: Colors.green,
                size: 30,
              ),
            ),
          ),
        ],
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          widget.driverName,
          style: GoogleFonts.jost(
            textStyle: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
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
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return LoanList.isEmpty
                ? const Center(
                    child: Text("No Loans Found"),
                  )
                : Scrollbar(
                    scrollbarOrientation: ScrollbarOrientation.left,
                    thickness: 8,
                    child: LiquidPullToRefresh(
                      onRefresh: reloadData,
                      animSpeedFactor: 1.5,
                      backgroundColor: Colors.grey[300],
                      color: Theme.of(context).primaryColor,
                      height: 200,
                      child: GroupedListView<dynamic, String>(
                        physics: const BouncingScrollPhysics(),
                        useStickyGroupSeparators: true,
                        scrollDirection: Axis.vertical,
                        groupBy: (element) => element["date"],
                        sort: true,
                        elements: LoanList.toList(),
                        groupSeparatorBuilder: (value) => Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          color: Colors.black,
                          child: Text(
                            value,
                            style: GoogleFonts.josefinSans(
                              textStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        itemBuilder: (context, element) => GestureDetector(
                          onTap: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => CarProfileDetails(
                            //       car: element,
                            //       jwt: widget.jwt,
                            //     ),
                            //   ),
                            // );
                          },
                          child: Card(
                            elevation: 4,
                            child: Row(
                              children: <Widget>[
                                const Padding(
                                  padding: EdgeInsets.all(14),
                                  child: CircleAvatar(
                                    backgroundImage:
                                        AssetImage('images/driver.png'),
                                    radius: 35,
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${element['amount']} (${element['method']})",
                                      style: GoogleFonts.josefinSans(
                                        textStyle: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      element["date"].toString(),
                                      style: GoogleFonts.josefinSans(
                                        textStyle: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
          }
        },
      ),
    );
  }
}
