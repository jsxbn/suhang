import "package:flutter/material.dart";
import 'package:lottie/lottie.dart';
import 'package:photo_view/photo_view.dart';

class imageviewer extends StatefulWidget {
  imageviewer({Key? key}) : super(key: key);

  @override
  State<imageviewer> createState() => _imageviewerState();
}

class _imageviewerState extends State<imageviewer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xffF4F4F4),
        appBar: AppBar(title: Text("wow")),
        body: Center(
          child: SizedBox(
            width: 200,
            child: Lottie.asset(
              "assets/7728-image-loading-improved.zip",
            ),
          ),
        ));
  }
}
