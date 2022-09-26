// ignore_for_file: non_constant_identifier_names, file_names, must_be_immutable, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_gallery.dart';

import 'package:wc_flutter_share/wc_flutter_share.dart';

class ImageView extends StatefulWidget {
  ImageView({Key? key, this.images, required this.name})
      : pageController = PageController(initialPage: 0),
        pageIndex = 0;
  final dynamic images;
  final String name;
  late int pageIndex;
  final PageController pageController;
  @override
  State<ImageView> createState() => _ImageViewState();
}

String? title = "";

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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () async {
          await WcFlutterShare.share(
              sharePopupTitle: widget.name,
              fileName: '${widget.name}.png',
              mimeType: 'image',
              bytesOfFile:
                  imageBytesList[widget.pageIndex].buffer.asUint8List());
        },
        child: const Icon(
          Icons.share,
        ),
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
