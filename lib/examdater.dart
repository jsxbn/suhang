import 'package:flutter/material.dart';
import 'package:suhang/webgimal.dart';

class ExamDater extends StatelessWidget {
  const ExamDater({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: const Color(0xffDCF0FC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          highlightColor: Colors.transparent,
          splashColor: Colors.grey.withOpacity(0.15),
          customBorder:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          onTap: () async {
            await Future.delayed(Duration(milliseconds: 300));
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => examview()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Stack(
                  children: [
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 10,
                        width: 100,
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(color: Colors.grey, blurRadius: 20),
                            ]),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Image.asset('assets/exam.png'),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '기말까지: D${DateTime.now().difference(DateTime(2022, 12, 6)).inDays - 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                    Text('시험범위 확인하기'),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
