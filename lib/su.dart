import 'dart:ui';

import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class suhang extends StatefulWidget {
  final Map<String, dynamic>? sh;
  final List suData;
  const suhang({
    Key? key,
    required this.sh,
    required this.suData,
  }) : super(key: key);

  @override
  State<suhang> createState() => _suhangState();
}

class _suhangState extends State<suhang> {
  DateTime _selectedValue = DateTime.now();
  DatePickerController _controller = DatePickerController();
  @override
  int num = 10;
  void initState() {
    super.initState();
    num = 10;
  }

  Widget naeyeong(Map<String, dynamic>? shlist, DateTime tgtdate) {
    if (shlist != null) {
      String a = DateFormat('yyMMdd').format(tgtdate);
      a.toString();
      if (shlist[a] != null && shlist[a] != '없음') {
        List ho = shlist[a].toString().split(',');
        return ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemCount: ho.length,
          itemBuilder: (BuildContext context, int index) {
            return Item(ho[index], index);
          },
        );
      } else {
        return Center(child: Text('수행평가 일정이 없습니다.'));
      }
    }
    return Center(child: Text('에러 발생. 에러코드: jeonsoobin'));
  }

  Widget Item(dynamic input, int index) {
    input.toString();
    List<int> colorlist = [0xffDCFCEF, 0xffDCF0FC, 0xffFCEBDC];
    List<int> lftclr = [0xff65E0AC, 0xff65A5E0, 0xffFD9800];
    List<int> maintxt = [0xff015C36, 0xff092862, 0xffE06E04];
    return Container(
      margin: EdgeInsets.only(top: 8, bottom: 8, left: 25, right: 25),
      padding: EdgeInsets.all(10),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          stops: [0.02, 0.02],
          colors: [Color(lftclr[index % 3]), Color(colorlist[index % 3])],
        ),
        // color: Color(colorlist[index % 4]),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          // BoxShadow(
          //   color: Color(colorlist[index % 3]).withOpacity(0.5),
          //   spreadRadius: 5,
          //   blurRadius: 10,
          //   offset: const Offset(0, 5),
          // ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const SizedBox(width: 5),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      input['name'],
                      style: TextStyle(
                        color: Color(maintxt[index % 3]),
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Text(
                      input['caption'], // have to change
                      style: TextStyle(
                        color: Color(maintxt[index % 3]).withOpacity(0.6),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.watch_later_outlined,
                          color: Color(maintxt[index % 3]),
                          size: 18,
                        ),
                        SizedBox(
                          width: 3,
                        ),
                        Text(
                          input['date'],
                          style: TextStyle(
                            color: Color(maintxt[index % 3]),
                            fontSize: 13,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              child: Row(
                children: [
                  VerticalDivider(
                    color: Color(maintxt[index % 3]).withOpacity(0.6),
                    thickness: 0.8,
                  ),
                  Material(
                    color: Colors.transparent,
                    child: IconButton(
                      splashRadius: 30,
                      onPressed: () {},
                      icon: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Color(maintxt[index % 3]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? sh = widget.sh;
    List suData = widget.suData;
    return Scaffold(
      extendBodyBehindAppBar: true,
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
      body: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: suData.length,
          itemBuilder: (BuildContext context, int index) {
            print(suData[index]);
            return Item(suData[index], index);
          }),
    );
  }
}

class Items extends StatefulWidget {
  final List suData;
  Items({
    Key? key,
    required this.suData,
  }) : super(key: key);

  @override
  State<Items> createState() => _ItemsState();
}

class _ItemsState extends State<Items> {
  Widget Item(dynamic input, int index) {
    input.toString();
    List<int> colorlist = [0xffDCFCEF, 0xffDCF0FC, 0xffFCEBDC];
    List<int> lftclr = [0xff65E0AC, 0xff65A5E0, 0xffFD9800];
    List<int> maintxt = [0xff015C36, 0xff092862, 0xffE06E04];
    return Container(
      margin: EdgeInsets.only(top: 8, bottom: 8, left: 25, right: 25),
      padding: EdgeInsets.all(10),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          stops: [0.02, 0.02],
          colors: [Color(lftclr[index % 3]), Color(colorlist[index % 3])],
        ),
        // color: Color(colorlist[index % 4]),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          // BoxShadow(
          //   color: Color(colorlist[index % 3]).withOpacity(0.5),
          //   spreadRadius: 5,
          //   blurRadius: 10,
          //   offset: const Offset(0, 5),
          // ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const SizedBox(width: 5),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      input['name'],
                      style: TextStyle(
                        color: Color(maintxt[index % 3]),
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Text(
                      input['caption'], // have to change
                      style: TextStyle(
                        color: Color(maintxt[index % 3]).withOpacity(0.6),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.watch_later_outlined,
                          color: Color(maintxt[index % 3]),
                          size: 18,
                        ),
                        SizedBox(
                          width: 3,
                        ),
                        Text(
                          input['date'],
                          style: TextStyle(
                            color: Color(maintxt[index % 3]),
                            fontSize: 13,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              child: Row(
                children: [
                  VerticalDivider(
                    color: Color(maintxt[index % 3]).withOpacity(0.6),
                    thickness: 0.8,
                  ),
                  Material(
                    color: Colors.transparent,
                    child: IconButton(
                      splashRadius: 30,
                      onPressed: () {},
                      icon: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Color(maintxt[index % 3]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List suData = widget.suData;
    return ListView.builder(
        shrinkWrap: true,
        itemCount: suData.length,
        itemBuilder: (BuildContext context, int index) {
          return Item(suData[index], index);
        });
  }
}
