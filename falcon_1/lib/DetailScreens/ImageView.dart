// ignore_for_file: non_constant_identifier_names, file_names, must_be_immutable, use_key_in_widget_constructors

import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:falcon_1/main.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:http/http.dart' as http;
import 'package:wc_flutter_share/wc_flutter_share.dart';

class ImageView extends StatefulWidget {
  const ImageView({
    Key? key,
    this.images,
    required this.name,
    required this.type,
    required this.id,
  });
  final dynamic images;
  final String name;
  final String type;
  final int id;
  @override
  State<ImageView> createState() => _ImageViewState();
}

String? title = "";
int pageIndex = 0;
final PageController pageController = PageController(initialPage: 0);

class _ImageViewState extends State<ImageView> {
  List<dynamic> imageBytesList = [];
  @override
  void initState() {
    imageBytesList = widget.images.entries.map((e) => e.value).toList();
    title = widget.images.keys.toList().first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title!),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: Theme.of(context).primaryColor,
            onPressed: () async {
              await http.post(
                  Uri.parse("$SERVER_IP/api/protected/GetPhotoAlbum"),
                  body: jsonEncode(
                    {
                      "id": widget.id,
                      "type": widget.type,
                    },
                  ),
                  headers: {
                    "Cookie": "jwt=$jwt",
                    "Content-Type": "application/json"
                  }).then((response) async {
                Map<String, Uint8List>? files = {};
                String filepath =
                    await FilePicker.platform.getDirectoryPath() as String;
                final decoded_data = GZipCodec().decode(response.bodyBytes);
                // final dynamic file =
                //     await File("$filepath/file.tar").writeAsBytes(decoded_data);
                var tarFile = TarDecoder().decodeBytes(decoded_data);
                for (var file in tarFile.files) {
                  files[file.name] = file.rawContent!.toUint8List();
                }
                // await File("$filepath/23.jpg")
                //     .writeAsBytes(file.files[0].rawContent!.toUint8List());

                // final stream = file.openRead().transform(gzip.decoder);
                // await TarReader.forEach(stream, (entry) async {
                //   print(entry.header.name);
                //   files[entry.header.name] = await entry.contents.first;
                //   // print(await entry.contents.first);
                // });
                Directory("$filepath/${widget.name}").create();
                files.forEach((key, value) async {
                  await File("$filepath/${widget.name}/$key")
                      .writeAsBytes(value);
                });
                //   if (Platform.isIOS || Platform.isAndroid) {
                //     bool status = await Permission.storage.isGranted;
                //     if (!status) await Permission.storage.request();
                //     MimeType type = MimeType.OTHER;
                //     await FileSaver.instance.saveAs(
                //         "Table", Uint8List.fromList(filesBytes[0]), "jpeg", type);
                //   } else {
                //     String? filePath = await FilePicker.platform.saveFile(
                //         dialogTitle: "Save File", fileName: "Table.jpeg");
                //     File file = File(filePath!);
                //     file.writeAsBytes(Uint8List.fromList(filesBytes[0]));
                //   }
              });
            },
            child: const Icon(
              Icons.download_rounded,
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          if (Platform.isIOS || Platform.isAndroid)
            FloatingActionButton(
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: () async {
                await WcFlutterShare.share(
                    sharePopupTitle: widget.name,
                    fileName: '${widget.name}.png',
                    mimeType: 'image',
                    bytesOfFile:
                        imageBytesList[pageIndex].buffer.asUint8List());
              },
              child: const Icon(
                Icons.share,
              ),
            ),
        ],
      ),
      backgroundColor: Colors.black,
      // body: CreateImage(image: widget.image));
      body: Stack(
        children: [
          GestureDetector(
            onVerticalDragUpdate: (details) {
              if (details.delta.dy.abs() >= 20) {
                Navigator.of(context).pop();
              }
            },
            child: PhotoViewGallery.builder(
              pageController: pageController,
              itemCount: imageBytesList.length,
              builder: (context, index) {
                final imageBytes = imageBytesList[index];
                return PhotoViewGalleryPageOptions(
                  imageProvider: MemoryImage(imageBytes),
                );
              },
              onPageChanged: (index) => setState(() {
                pageIndex = index;
                title = widget.images.keys.firstWhere(
                    (k) => widget.images[k] == imageBytesList[index],
                    orElse: () => "null");
              }),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: () {
                if (pageIndex < imageBytesList.length - 1) {
                  setState(() {
                    pageController.nextPage(
                      duration: const Duration(seconds: 1),
                      curve: Curves.ease,
                    );
                    pageIndex = pageIndex + 1;
                  });
                }
              },
              color: Colors.blue,
              iconSize: 40,
              icon: const Icon(Icons.arrow_circle_right_rounded),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () {
                if (pageIndex > 0) {
                  setState(() {
                    pageController.previousPage(
                      duration: const Duration(seconds: 1),
                      curve: Curves.ease,
                    );
                    pageIndex = pageIndex - 1;
                  });
                }
              },
              color: Colors.blue,
              iconSize: 40,
              icon: const Icon(Icons.arrow_circle_left_rounded),
            ),
          ),
        ],
      ),
    );
  }
}
