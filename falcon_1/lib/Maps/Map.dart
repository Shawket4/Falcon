// ignore_for_file: file_names, unused_local_variable
import 'dart:ui' as ui;
import 'package:dio/dio.dart';
import 'package:falcon_1/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:url_launcher/url_launcher.dart';

String mapStyle = '''
  [
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#ebe3cd"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#523735"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#f5f1e6"
      }
    ]
  },
  {
    "featureType": "administrative",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#c9b2a6"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#dcd2be"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#ae9e90"
      }
    ]
  },
  {
    "featureType": "landscape.natural",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#dfd2ae"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#dfd2ae"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#93817c"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#a5b076"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#447530"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#f5f1e6"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#fdfcf8"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "labels",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#f8c967"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#e9bc62"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "road.highway.controlled_access",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e98d58"
      }
    ]
  },
  {
    "featureType": "road.highway.controlled_access",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#db8555"
      }
    ]
  },
  {
    "featureType": "road.local",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#806b63"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#dfd2ae"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#8f7d77"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#ebe3cd"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#dfd2ae"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#b9d3c2"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#92998d"
      }
    ]
  }
]
''';

class MapUtils {
  MapUtils._();
  static Future<void> openMap(double latitude, double longitude) async {
    String googleUrl =
        "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";
    if (await canLaunchUrl(Uri.parse(googleUrl))) {
      await launchUrl(Uri.parse(googleUrl));
    } else {
      throw 'Could not open the map.';
    }
  }
}

Position? pos;

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  pos = await Geolocator.getCurrentPosition();
  return await Geolocator.getCurrentPosition();
}

Set<Marker> _markers = {};
LatLng? firstMarker;
BitmapDescriptor? mapMarker;

Future<Uint8List> getBytesFromAsset(String path, int width) async {
  ByteData data = await rootBundle.load(path);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
      targetWidth: width);
  ui.FrameInfo fi = await codec.getNextFrame();
  return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
      .buffer
      .asUint8List();
}

Future<String> loadMapData(String jwt, BuildContext context) async {
  _markers.clear();
  await _determinePosition();

  Dio dio = Dio();
  dio.options.headers["Cookie"] = "jwt=$jwt";
  dio.options.headers["Content-Type"] = "application/json";
  var res =
      await dio.get("$SERVER_IP/api/GetVehicleMapPoints").then((response) {
    var str = response.data;
    // str.forEach((element) { _markers.add(Marker(markerId: MarkerId(element["PlateNo"]), position: LatLng(double.parse(element["Latitude"]), double.parse(element["Longitude"])), infoWindow: InfoWindow(title: element["PlateNo"]))));
    str.forEach((element) async {
      _markers.add(Marker(
        markerId: MarkerId(element["PlateNo"]),
        position: LatLng(double.parse(element["Latitude"]),
            double.parse(element["Longitude"])),
        infoWindow: InfoWindow(
            title: element["PlateNo"],
            snippet:
                "Lat: ${element["Latitude"]}\nLong: ${element["Longitude"]}\nSpeed: ${element["Speed"]}",
            onTap: () {
              showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  builder: (context) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height / 2,
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        // crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          const SizedBox(
                            height: 20,
                          ),
                          Center(
                            child: Text(
                              element["PlateNo"],
                              style: GoogleFonts.josefinSans(
                                textStyle: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, right: 12.0),
                            child: Text(
                              "السرعة الحالية: ${element["Speed"]}",
                              textDirection: ui.TextDirection.rtl,
                              style: GoogleFonts.josefinSans(
                                textStyle: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, right: 12.0),
                            child: Text(
                              "إحداثيات السيارة: ${element["Latitude"]}, ${element["Longitude"]}",
                              textDirection: ui.TextDirection.rtl,
                              style: GoogleFonts.josefinSans(
                                textStyle: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, right: 12.0),
                            child: Text(
                              "حالة المتور: ${element["EngineStatus"]}",
                              textDirection: ui.TextDirection.rtl,
                              style: GoogleFonts.josefinSans(
                                textStyle: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(50.0),
                            child: Center(
                              child: GestureDetector(
                                onTap: () {
                                  MapUtils.openMap(
                                    double.parse(element["Latitude"]),
                                    double.parse(
                                      element["Longitude"],
                                    ),
                                  );
                                },
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.map_rounded,
                                      size: 40,
                                    ),
                                    Text(
                                      "Open Maps",
                                      textDirection: ui.TextDirection.rtl,
                                      style: GoogleFonts.josefinSans(
                                        textStyle: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  });
            }),
        icon: mapMarker!,
      ));
    });
    firstMarker = pos != null
        ? LatLng(pos!.latitude, pos!.longitude)
        : LatLng(double.parse(str[0]["Latitude"]),
            double.parse(str[0]["Longitude"]));
  });
  return "";
}

void setCustomMarker() async {
  final Uint8List markerIcon =
      await getBytesFromAsset('images/mapMarker.png', 200);
  mapMarker = BitmapDescriptor.fromBytes(markerIcon);
}

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key, required this.jwt}) : super(key: key);
  final String jwt;
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  void _onMapCreated(GoogleMapController controller) {
    controller.setMapStyle(mapStyle);
  }

  @override
  void initState() {
    setCustomMarker();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'الخريطة',
          style: GoogleFonts.josefinSans(
            textStyle: const TextStyle(
              fontSize: 22,
            ),
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      // floatingActionButton: FloatingActionButton(child: Icon(Icons.my_location_rounded), onPressed: (){},),
      body: FutureBuilder(
          future: loadMapData(widget.jwt, context),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return GoogleMap(
                myLocationEnabled: true,
                mapToolbarEnabled: true,
                myLocationButtonEnabled: true,
                onMapCreated: _onMapCreated,
                markers: _markers,
                initialCameraPosition: CameraPosition(
                  target: firstMarker!,
                  zoom: 15,
                ),
              );
            } else {
              return Center(
                // Display lottie animation
                child: lottie.Lottie.asset(
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
