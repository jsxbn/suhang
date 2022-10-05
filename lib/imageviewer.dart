import "package:flutter/material.dart";
import 'package:lottie/lottie.dart';
import 'package:photo_view/photo_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:ui';

class imageviewer extends StatefulWidget {
  final String url;
  imageviewer({
    Key? key,
    required this.url,
  }) : super(key: key);

  @override
  State<imageviewer> createState() => _imageviewerState();
}

class _imageviewerState extends State<imageviewer> {
  late String imageurl;

  // Future<bool> fileExists(url) async{
  //   await FirebaseStorage.instance.ref().child(url).getDownloadURL().then((url) => {true}).catchError((){return false;});
  // }
  @override
  Widget build(BuildContext context) {
    String url = widget.url;
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
        title: const Text(
          '상세 이미지',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white.withAlpha(100),
        elevation: 0,
      ),
      body: FutureBuilder(
        future: FirebaseStorage.instance
            .ref()
            .child(url)
            .getDownloadURL()
            .then((url) {
          imageurl = url;
          return true;
        }).catchError(() {
          return false;
        }),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Text('로딩중...'));
          }
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data == true) {
              print(snapshot.data);
              return PhotoView(
                backgroundDecoration: BoxDecoration(
                  color: Colors.white10,
                ),
                imageProvider: NetworkImage(imageurl),
              );
            } else {
              print(snapshot.data);
              return Text('False');
            }
          }
          return Center(
            child: Text('error'),
          );
        },
      ),
      // body: ElevatedButton(
      //     onPressed: () async {
      //       // await FirebaseStorage.instance.ref().child(url).getDownloadURL().then((exsists) => {if (exsists[0]){}});
      //       // await FirebaseStorage.instance.ref().child(url).
      //       // print(url);
      //       // print(imageurl);
      //       try {
      //         final imageurl = await FirebaseStorage.instance.ref().child(url).getDownloadURL();
      //         print(imageurl);
      //       }
      //       catch(error) {
      //         print('무언가 ㅈ됨');
      //       }
      //     },
      //     child: Text('press this')),
    );
    // body: Center(
    //   child: SizedBox(
    //     width: 200,
    //     child: Lottie.asset(
    //       "assets/7728-image-loading-improved.zip",
    //     ),
    //   ),
    // ));
  }
}
