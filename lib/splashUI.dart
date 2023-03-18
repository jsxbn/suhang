import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class splashui extends StatelessWidget {
  final bool indicator;
  const splashui({
    Key? key,
    required this.indicator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '_samban',
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            const Text(
              '행신중 3-3\nVersion 3.5.7',
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 5,
            ),
            indicator ? const CupertinoActivityIndicator() : const SizedBox()
          ],
        ),
      ),
    );
  }
}
