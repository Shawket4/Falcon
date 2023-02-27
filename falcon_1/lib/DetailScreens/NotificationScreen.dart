// ignore_for_file: file_names

import 'package:falcon_1/DetailScreens/CarProfileDetails.dart';
import 'package:falcon_1/DetailScreens/DriverProfileDetails.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_list/grouped_list.dart';

class NotificationScreen extends StatefulWidget {
  final List<dynamic> notifications;
  final String jwt;
  const NotificationScreen(
      {super.key, required this.notifications, required this.jwt});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        // Hamburger Menu
        title: Text(
          'التنبيهات',
          style: GoogleFonts.josefinSans(
            textStyle: const TextStyle(
              fontSize: 22,
            ),
          ),
        ),
      ),
      body: Scrollbar(
        scrollbarOrientation: ScrollbarOrientation.left,
        thickness: 8,
        child: GroupedListView<dynamic, String>(
          groupBy: (element) => element["Type"][0],
          groupSeparatorBuilder: (value) => Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.black,
            child: Text(
              "Type: $value",
              style: GoogleFonts.josefinSans(
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          elements: widget.notifications,
          itemBuilder: ((context, element) => GestureDetector(
                onTap: () {
                  if (element["Type"][0] == "Car") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CarProfileDetails(
                          jwt: widget.jwt,
                          car: element["Car"],
                        ),
                      ),
                    );
                  } else if (element["Type"][0] == "Driver") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DriverProfileDetails(
                          jwt: widget.jwt,
                          driver: element["Driver"],
                        ),
                      ),
                    );
                  }
                },
                child: Card(
                  elevation: 4,
                  child: Row(
                    children: <Widget>[
                      // Image.network(
                      //   "",
                      //   width: 100,
                      //   height: 100,
                      // ),
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: CircleAvatar(
                          backgroundImage: element["Type"][0] == "Car"
                              ? const AssetImage('images/truck.jpg')
                              : const AssetImage("images/driver.png"),
                          radius: 35,
                        ),
                      ),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              element['Name'],
                              style: GoogleFonts.josefinSans(
                                textStyle: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              child: Text(
                                element['Message'].toString(),
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.josefinSans(
                                  textStyle: const TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ),
      ),
    );
  }
}
