import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../main.dart';

class MapHistory extends StatefulWidget {
  const MapHistory({super.key, required this.tripID, required this.jwt});
  final int tripID;
  final String jwt;
  @override
  State<MapHistory> createState() => _MapHistoryState();
}

Dio dio = Dio();

class _MapHistoryState extends State<MapHistory> {
  final List<Marker> _markers = [];
  DateTime? currentTimeStamp;
  int stampIndex = 0;
  double sliderValue = 0;
  List<LatLng> latlen = [];
  bool isLoaded = false;
  Map<DateTime, LatLng> points = {};
  TripSummary tripSummary = TripSummary();
  Future<bool> loadData() async {
    print("object");

    if (isLoaded) {
      return true;
    }
    var request = await dio.post(
      "$SERVER_IP/api/protected/GetTripRouteHistory",
      data: {"ID": widget.tripID},
    );
    print(request.data);

    if (request.statusCode == 200) {
      tripSummary = TripSummary.fromJson(request.data["trip_summary"]);
      for (var point in request.data["Points"]) {
        var parsedDate =
            DateFormat("dd/MM/yyyy HH:mm:ss").parse(point["time_stamp"]);
        points[parsedDate] = LatLng(
            double.parse(point["latitude"]), double.parse(point["longitude"]));
      }
      latlen = points.entries.map((e) => e.value).toList();
      currentTimeStamp = points.entries.map((e) => e.key).first;
      // _polyline.add(Polyline(
      //   polylineId: const PolylineId('1'),
      //   endCap: Cap.buttCap,
      //   startCap: Cap.buttCap,
      //   points: latlen,
      //   width: 5,
      //   color: Colors.blue,
      // ));
      setState(() {});

      _markers.add(
        Marker(
          point: points.values.elementAt(0),
          height: 40,
          width: 40,
          builder: (context) => Image.asset("images/mapMarker.png"),
        ),
      );
      _markers.add(
        Marker(
          point: points.values.elementAt(0),
          height: 40,
          width: 40,
          builder: (context) => GestureDetector(
            child: Image.asset("images/startMarker.png"),
            onTap: () {},
          ),
        ),
      );
      _markers.add(
        Marker(
          point: points.values.elementAt(points.length - 1),
          height: 40,
          width: 40,
          builder: (context) => Image.asset("images/endMarker.png"),
        ),
      );
      isLoaded = true;
      return true;
    } else {
      return false;
    }
  }

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
        title: const Text("Map"),
      ),
      body: FutureBuilder(
        future: loadData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return FlutterMap(
              options: MapOptions(
                center: points.values.elementAt(0),
                zoom: 8,
              ),
              nonRotatedChildren: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Slider(
                      value: sliderValue,
                      onChanged: (value) {
                        sliderValue = value;
                        stampIndex = (value * (points.length - 1)).toInt();
                        updateCurrentMarker();
                        setState(() {});
                      },
                      divisions: points.length - 1,
                    ),
                    Platform.isWindows || Platform.isMacOS
                        ? Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.8),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(5.0),
                                        width: 300,
                                        color: Colors.grey.shade300,
                                        child: const Text(
                                          "Route Summary",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Text(
                                          "Mileage: ${tripSummary.TotalMileage}",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Text(
                                          "Stops: ${tripSummary.NumberofStops}",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Text(
                                          "Driving Time: ${tripSummary.TotalActiveTime}",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Text(
                                          "Idle Time: ${tripSummary.TotalIdleTime}",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Text(
                                          "Parking Time: ${tripSummary.TotalPassiveTime}",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Text(
                                          "Disconnected Time: ${tripSummary.TotalDisConnectedTime}",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(5.0),
                                        width: 300,
                                        color: Colors.grey.shade300,
                                        child: const Text(
                                          "Sensors",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Text(
                                          "Ignition Off: ${tripSummary.NoIgnitionOff}",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Text(
                                          "Ignition On: ${tripSummary.NoIgnitionOn}",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 200,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.8),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "${currentTimeStamp!.day}/${currentTimeStamp!.month}/${currentTimeStamp!.year}",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "${currentTimeStamp!.hour}:${currentTimeStamp!.minute}:${currentTimeStamp!.second}",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        // : Padding(
                        //     padding: const EdgeInsets.all(8.0),
                        //     child: Column(
                        //       mainAxisAlignment: MainAxisAlignment.center,
                        //       crossAxisAlignment: CrossAxisAlignment.start,
                        //       children: [
                        //         Container(
                        //           decoration: BoxDecoration(
                        //             color: Colors.black.withOpacity(0.8),
                        //           ),
                        //           child: Column(
                        //             mainAxisAlignment: MainAxisAlignment.center,
                        //             crossAxisAlignment:
                        //                 CrossAxisAlignment.start,
                        //             children: [
                        //               Container(
                        //                 padding: const EdgeInsets.all(5.0),
                        //                 width: 300,
                        //                 color: Colors.grey.shade300,
                        //                 child: const Text(
                        //                   "Route Summary",
                        //                   style: TextStyle(
                        //                     color: Colors.black,
                        //                     fontWeight: FontWeight.bold,
                        //                   ),
                        //                 ),
                        //               ),
                        //               Padding(
                        //                 padding: const EdgeInsets.all(5.0),
                        //                 child: Text(
                        //                   "Mileage: ${tripSummary.TotalMileage}",
                        //                   style: const TextStyle(
                        //                     color: Colors.white,
                        //                     fontWeight: FontWeight.bold,
                        //                   ),
                        //                 ),
                        //               ),
                        //               Padding(
                        //                 padding: const EdgeInsets.all(5.0),
                        //                 child: Text(
                        //                   "Stops: ${tripSummary.NumberofStops}",
                        //                   style: const TextStyle(
                        //                     color: Colors.white,
                        //                     fontWeight: FontWeight.bold,
                        //                   ),
                        //                 ),
                        //               ),
                        //               Padding(
                        //                 padding: const EdgeInsets.all(5.0),
                        //                 child: Text(
                        //                   "Driving Time: ${tripSummary.TotalActiveTime}",
                        //                   style: const TextStyle(
                        //                     color: Colors.white,
                        //                     fontWeight: FontWeight.bold,
                        //                   ),
                        //                 ),
                        //               ),
                        //               Padding(
                        //                 padding: const EdgeInsets.all(5.0),
                        //                 child: Text(
                        //                   "Idle Time: ${tripSummary.TotalIdleTime}",
                        //                   style: const TextStyle(
                        //                     color: Colors.white,
                        //                     fontWeight: FontWeight.bold,
                        //                   ),
                        //                 ),
                        //               ),
                        //               Padding(
                        //                 padding: const EdgeInsets.all(5.0),
                        //                 child: Text(
                        //                   "Parking Time: ${tripSummary.TotalPassiveTime}",
                        //                   style: const TextStyle(
                        //                     color: Colors.white,
                        //                     fontWeight: FontWeight.bold,
                        //                   ),
                        //                 ),
                        //               ),
                        //               Padding(
                        //                 padding: const EdgeInsets.all(5.0),
                        //                 child: Text(
                        //                   "Disconnected Time: ${tripSummary.TotalDisConnectedTime}",
                        //                   style: const TextStyle(
                        //                     color: Colors.white,
                        //                     fontWeight: FontWeight.bold,
                        //                   ),
                        //                 ),
                        //               ),
                        //               Container(
                        //                 padding: const EdgeInsets.all(5.0),
                        //                 width: 300,
                        //                 color: Colors.grey.shade300,
                        //                 child: const Text(
                        //                   "Sensors",
                        //                   style: TextStyle(
                        //                     color: Colors.black,
                        //                     fontWeight: FontWeight.bold,
                        //                   ),
                        //                 ),
                        //               ),
                        //               Padding(
                        //                 padding: const EdgeInsets.all(5.0),
                        //                 child: Text(
                        //                   "Ignition Off: ${tripSummary.NoIgnitionOff}",
                        //                   style: const TextStyle(
                        //                     color: Colors.white,
                        //                     fontWeight: FontWeight.bold,
                        //                   ),
                        //                 ),
                        //               ),
                        //               Padding(
                        //                 padding: const EdgeInsets.all(5.0),
                        //                 child: Text(
                        //                   "Ignition On: ${tripSummary.NoIgnitionOn}",
                        //                   style: const TextStyle(
                        //                     color: Colors.white,
                        //                     fontWeight: FontWeight.bold,
                        //                   ),
                        //                 ),
                        //               ),
                        //             ],
                        //           ),
                        //         ),
                        //         const SizedBox(
                        //           height: 20,
                        //         ),
                        //         Container(
                        //           width: 200,
                        //           height: 80,
                        //           decoration: BoxDecoration(
                        //             color: Colors.black.withOpacity(0.8),
                        //           ),
                        //           child: Center(
                        //             child: Column(
                        //               mainAxisAlignment:
                        //                   MainAxisAlignment.center,
                        //               children: [
                        //                 Text(
                        //                   "${currentTimeStamp!.day}/${currentTimeStamp!.month}/${currentTimeStamp!.year}",
                        //                   style: const TextStyle(
                        //                     color: Colors.white,
                        //                     fontWeight: FontWeight.bold,
                        //                   ),
                        //                 ),
                        //                 Text(
                        //                   "${currentTimeStamp!.hour}:${currentTimeStamp!.minute}:${currentTimeStamp!.second}",
                        //                   style: const TextStyle(
                        //                     color: Colors.white,
                        //                     fontWeight: FontWeight.bold,
                        //                   ),
                        //                 ),
                        //               ],
                        //             ),
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        : Container(),
                  ],
                ),
              ],
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.shawket.falcon1',
                ),
                PolylineLayer(
                  polylineCulling: false,
                  polylines: [
                    Polyline(
                      points: latlen,
                      color: Colors.blue,
                      strokeWidth: 4,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: _markers,
                ),
              ],
            );
            // return Text("Loaded");
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  void updateCurrentMarker() {
    currentTimeStamp = points.keys.elementAt(stampIndex);
    _markers[0] = Marker(
      point: points.values.elementAt(stampIndex),
      height: 40,
      width: 40,
      builder: (context) => Image.asset("images/mapMarker.png"),
    );
    setState(() {});
    // _markers.removeWhere((element) => element.markerId == MarkerId("current"));
    // _markers.add(Marker(
    //   markerId: MarkerId("current"),
    //   position: points.values.elementAt(stampIndex),
    //   icon: mapMarker!,
    // ));
  }
}

class TripSummary {
  TripSummary({
    this.TotalMileage,
    this.TotalActiveTime,
    this.TotalPassiveTime,
    this.TotalIdleTime,
    this.NumberofStops,
    this.TotalDisConnectedTime,
    this.NoIgnitionOff,
    this.NoIgnitionOn,
  });

  String? TotalMileage;
  String? TotalActiveTime;
  String? TotalPassiveTime;
  String? TotalIdleTime;
  String? NumberofStops;
  String? TotalDisConnectedTime;
  String? NoIgnitionOff;
  String? NoIgnitionOn;
  factory TripSummary.fromJson(dynamic json) => TripSummary(
        TotalMileage: json["TotalMileage"],
        TotalActiveTime: json["TotalActiveTime"],
        TotalPassiveTime: json["TotalPassiveTime"],
        TotalIdleTime: json["TotalIdleTime"],
        NumberofStops: json["NumberofStops"],
        TotalDisConnectedTime: json["TotalDisConnectedTime"],
        NoIgnitionOff: json["Sensor1"].replaceAll("#Ignition Off", ""),
        NoIgnitionOn: json["Sensor2"].replaceAll("#Ignition On", ""),
      );
}
