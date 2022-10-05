import "package:flutter/material.dart";
import 'package:lottie/lottie.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:ui';

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
        appBar: AppBar(
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 10,
              sigmaY: 10,
            ),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
          ),
        ),
        title: Text('수행평가 일정',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w700,
            )),
        backgroundColor: Colors.white.withAlpha(200),
        elevation: 0,
      ),
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
