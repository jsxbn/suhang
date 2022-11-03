import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';


class examview extends StatelessWidget {
  const examview({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: WebView(
          initialUrl: "https://leebanstudio.tistory.com/3",
        ),
      ),
    );
  }
}