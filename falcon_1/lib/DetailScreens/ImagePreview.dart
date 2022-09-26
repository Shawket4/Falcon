// ignore_for_file: non_constant_identifier_names, must_be_immutable, use_key_in_widget_constructors, file_names

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImagePreview extends StatefulWidget {
  ImagePreview({Key? key, this.images, required this.title})
      : pageController = PageController(initialPage: 0),
        pageIndex = 0;
  final dynamic images;
  final String title;
  late int pageIndex;
  final PageController pageController;
  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.title,
          style: GoogleFonts.josefinSans(
            textStyle: const TextStyle(
              fontSize: 22,
            ),
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () async {
          Navigator.pop(context);
        },
        child: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          radius: 30,
          child: const Icon(
            Icons.check_rounded,
            size: 50,
            color: Colors.white,
          ),
        ),
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
              pageController: widget.pageController,
              itemCount: 1,
              builder: (context, index) {
                final imageBytes = widget.images;
                return PhotoViewGalleryPageOptions(
                  imageProvider: MemoryImage(imageBytes),
                );
              },
              onPageChanged: (index) => setState(() {
                widget.pageIndex = index;
              }),
            ),
          ),
          // Column(
          //   children: [
          //     const Spacer(),
          //     Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         TextButton(
          //           onPressed: () {
          //             Navigator.pop(context);
          //           },
          //           child: CircleAvatar(
          //             backgroundColor: Theme.of(context).primaryColor,
          //             radius: 30,
          //             child: const Icon(Icons.check_rounded, size: 50, color: Colors.white,
          //             ),
          //           ),
          //         ),
          //         TextButton(
          //           onPressed: () {},
          //           child: Icon(Icons.cancel, size: 70, color: Theme.of(context).primaryColor,
          //           ),
          //         ),
          //         // Icon(Icons.check, size: 30, color: Colors.white,),
          //       ],
          //     ),
          //    const SizedBox(height: 100,)
          //   ],
          // ),
        ],
      ),
    );
  }
}
