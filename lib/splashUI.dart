import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class splashui extends StatelessWidget {
  const splashui({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '_leeban',
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            Text('만든놈 전수빈'),
            SizedBox(height: 5,),
            CupertinoActivityIndicator()
          ],
        ),
      ),
    );
  }
}
