// ignore_for_file: non_constant_identifier_names, file_names, must_be_immutable, use_key_in_widget_constructors

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../EditScreens/EditDriver.dart';
import '../main.dart';

class ImageViewUpdateDriver extends StatefulWidget {
  ImageViewUpdateDriver({Key? key, this.images, required this.name})
      : pageController = PageController(initialPage: 0),
        pageIndex = 0;
  final dynamic images;
  final String name;
  late int pageIndex;
  final PageController pageController;
  @override
  State<ImageViewUpdateDriver> createState() => _ImageViewUpdateDriverState();
}

String? title = "";

class _ImageViewUpdateDriverState extends State<ImageViewUpdateDriver> {
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
              final result = await FilePicker.platform.pickFiles();
              if (result == null) return;
              PlatformFile platformFile = result.files.single;
              File imgFile = File(platformFile.path!);
              Uint8List imgBytes = await CompressFile(imgFile) as Uint8List;
              imageBytesList[widget.pageIndex] = imgBytes;
              setState(() {});
            },
            child: const Icon(
              Icons.edit,
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          FloatingActionButton(
            backgroundColor: Theme.of(context).primaryColor,
            onPressed: () async {
              if (imageBytesList[0] != null) {
                idLicenseImgBytes = imageBytesList[0];
              }
              if (imageBytesList[1] != null) {
                idLicenseImgBytesBack = imageBytesList[1];
              }
              if (imageBytesList[2] != null) {
                driverLicenseImgBytes = imageBytesList[2];
              }
              if (imageBytesList[3] != null) {
                safetyLicenseImgBytes = imageBytesList[3];
              }
              if (imageBytesList[4] != null) {
                drugTestImgBytes = imageBytesList[4];
              }
              if (imageBytesList[5] != null) {
                criminalRecordImgBytes = imageBytesList[5];
              }
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.check_box,
              size: 30,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      // body: CreateImage(image: widget.image));
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.delta.dy.abs() >= 20) {
            Navigator.of(context).pop();
          }
        },
        child: PhotoViewGallery.builder(
          pageController: widget.pageController,
          itemCount: imageBytesList.length,
          builder: (context, index) {
            final imageBytes = imageBytesList[index];
            return PhotoViewGalleryPageOptions(
                imageProvider: MemoryImage(imageBytes));
          },
          onPageChanged: (index) => setState(() {
            widget.pageIndex = index;
            title = widget.images.keys.firstWhere(
                (k) => widget.images[k] == imageBytesList[index],
                orElse: () => "null");
          }),
        ),
      ),
    );
  }
}
