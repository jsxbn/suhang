import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:suhang/imageviewer.dart';
import 'package:suhang/splashUI.dart';
import 'package:suhang/webgimal.dart';
import 'firebase_options.dart';
import 'package:intl/intl.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  });

  print('User granted permission: ${settings.authorizationStatus}');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        // ignore: deprecated_member_use
        androidOverscrollIndicator: AndroidOverscrollIndicator.stretch,
        primarySwatch: Colors.red,
        fontFamily: 'NotoSans',
      ),
      home: Rootpage(),
    );
  }
}

class Rootpage extends StatefulWidget {
  Rootpage({Key? key}) : super(key: key);

  @override
  State<Rootpage> createState() => _RootpageState();
}

class _RootpageState extends State<Rootpage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin? fltNotification;

  Map<String, dynamic>? sh = {}; //수행평가 db
  Map<String, dynamic>? sg = {}; //시간표 db
  double? defwid;
  double? defhet;
  double? tbhet;
  List hey = [];
  List evt = [];
  List nxtlist = [];
  List tdList = [];
  late List suData;
  ScrollController _controller = ScrollController();
  final maxExtent = 230.0;
  double currentExtent = 0.0;

  Widget Item(dynamic input, int index) {
    input.toString();
    List<int> colorlist = [0xffDCFCEF, 0xffDCF0FC, 0xffFCEBDC];
    List<int> lftclr = [0xff65E0AC, 0xff65A5E0, 0xffFD9800];
    List<int> maintxt = [0xff015C36, 0xff092862, 0xffE06E04];
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          stops: const [0.02, 0.02],
          colors: [Color(lftclr[index % 3]), Color(colorlist[index % 3])],
        ),
        // color: Color(colorlist[index % 4]),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
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
                    const SizedBox(
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
                        const SizedBox(
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
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    imageviewer(url: input['url'])));
                      },
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

  List dolist(Map<String, dynamic>? raw, DateTime now) {
    DateTime oo = now;
    if (raw != null) {
      List edtd = [];
      List wow = raw.keys.toList();
      wow.sort();
      String lastformat = wow[wow.length - 1];
      DateTime lasttime = DateTime(
          int.parse('20${lastformat[0] + lastformat[1]}'),
          int.parse(lastformat[2] + lastformat[3]),
          int.parse(lastformat[4] + lastformat[5]));
      Duration duration = lasttime.difference(now);
      for (int i = 0; i < duration.inDays + 2; i++) {
        String a = DateFormat('yyMMdd').format(oo);
        if (raw[a] != null && raw[a] != '없음' && raw[a] != '' && raw[a] != ' ') {
          List bfad = raw[a].toString().split(',');
          for (int z = 0; z < bfad.length; z++) {
            edtd.add(bfad[z]);
          }
        }
        oo = oo.toLocal().add(const Duration(days: 1));
      }
      return edtd;
    }
    return ['에러', '났어', '요.', '문의'];
  }

  List eventdate(Map<String, dynamic>? raw, DateTime now) {
    DateTime oo = now;
    if (raw != null) {
      List rtn = [];
      for (int i = 0; i < raw.values.toList().length; i++) {
        oo = oo.add(Duration(days: i));
        String a = DateFormat('yyMMdd').format(oo);
        if (raw[a] != null && raw[a] != '없음') {
          rtn.add(oo);
        }
      }
      return rtn;
    }
    return [];
  }

  Future<List> getMarker(String formatDate) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("22")
        .doc("io9qAPCblx77fN65yZ1J")
        .collection("suhang")
        .orderBy("rldate")
        .get();
    var allData = snapshot.docs.map((doc) => doc.data());
    List listed = allData.toList();
    Map<String, dynamic> hmmtestgod = listed[0] as Map<String, dynamic>;
    while (hmmtestgod['rldate'] < int.parse(formatDate)) {
      listed.removeAt(0);
      try {
        hmmtestgod = listed[0] as Map<String, dynamic>;
      } on Error {
        listed = ['nodata'];
        break;
      }
    }
    return listed;
  }

  @override
  Widget build(BuildContext context) {
    // Map<String, dynamic>? getDatash() {
    // FirebaseFirestore.instance
    //     .collection("22")
    //     .doc("수행평가")
    //     .get()
    //     .then((value1) => {sh = value1.data()});} // 수행평가 일정 받아오기

    // return sh;
    // }

    // DocumentReference<Map<String, dynamic>> getsh =
    //     FirebaseFirestore.instance.collection("22").doc("수행평가");
    // DocumentReference<Map<String, dynamic>> getsg =
    //     FirebaseFirestore.instance.collection("22").doc("시간표");

    // Map<String, dynamic>? getDatasg() {
    //   FirebaseFirestore.instance
    //       .collection("22")
    //       .doc("시간표")
    //       .get()
    //       .then((value1) => {sg = value1.data()}); // 시간표 받아오기
    // }

    var now = DateTime.now();
    var nxt = now.toLocal().add(const Duration(days: 1));
    String hrs = DateFormat('h:mm a').format(now);
    String formatDate = DateFormat('yyMMdd').format(now);
    String nxtDate = DateFormat('yyMMdd').format(nxt);
    formatDate.toString();
    nxtDate.toString();

    Widget checker(List<dynamic> suData) {
      if (suData[0] != 'nodata') {
        if (suData.isEmpty) {
          return Expanded(
            child: SizedBox(
                height: 200,
                child: Lottie.asset("assets/73061-search-not-found.json")),
          );
        } else {
          return ListView.builder(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: suData.length,
              itemBuilder: (BuildContext context, int index) {
                return Item(suData[index], index);
              });
        }
      } else {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
                height: 200,
                child: Lottie.asset('assets/73061-search-not-found.json')),
            const Text('수행평가 일정 없음'),
          ],
        );
      }
    }

    Future<List> _processdata() async {
      suData = await getMarker(formatDate);
      await FirebaseFirestore.instance
          .collection("22")
          .doc("수행평가")
          .get()
          .then((value1) => {sh = value1.data()});
      await FirebaseFirestore.instance
          .collection("22")
          .doc("시간표")
          .get()
          .then((value1) => {sg = value1.data()});
      defwid = 20;
      defhet = 50;
      tbhet = 50;
      hey = dolist(sh, now);
      evt = eventdate(sh, now);
      nxtlist = sh?[nxtDate].toString().split(',') ?? [];
      tdList = sh?[formatDate].toString().split(',') ?? [];
      return Future.wait([]);
    }

    return Scaffold(
      body: FutureBuilder(
        future: _processdata(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const splashui();
          }
          if (snapshot.hasData) {
            return Scaffold(
              body: CustomScrollView(slivers: [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  pinned: true,
                  floating: true,
                  expandedHeight: 50.0,
                  snap: true,
                  elevation: 0.0,
                  flexibleSpace: FlexibleSpaceBar.createSettings(
                    currentExtent: currentExtent,
                    minExtent: 0,
                    maxExtent: maxExtent,
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 10,
                          sigmaY: 10,
                        ),
                        child: FlexibleSpaceBar(
                          titlePadding: EdgeInsets.zero,
                          title: Container(
                            height: 50,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: const [
                                    SizedBox(width: 20),
                                    Text(
                                      '_leeban',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 28,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     const Text(
                        //       '안녕하세요',
                        //       style: TextStyle(
                        //         color: Color.fromARGB(255, 54, 54, 109),
                        //         fontSize: 28,
                        //         fontWeight: FontWeight.w900,
                        //       ),
                        //     ),
                        //     Container(
                        //       padding: const EdgeInsets.all(10),
                        //       decoration: BoxDecoration(
                        //         borderRadius: BorderRadius.circular(15),
                        //         color: const Color.fromRGBO(250, 250, 250, 1),
                        //         border: Border.all(
                        //             width: 1,
                        //             color:
                        //                 const Color.fromRGBO(211, 211, 211, 1)),
                        //       ),
                        //       // child: Column(
                        //       //   children: [
                        //       //     Text(hrs),
                        //       //     const Text('날씨 맑음 25C'),
                        //       //   ],
                        //       // ),
                        //     ),
                        //   ],
                        // ),
                        // const SizedBox(
                        //   height: 30,
                        // ),
                        // Row(
                        //   children: const [
                        //     Text(
                        //       '다가오는 수행평가',
                        //       style: TextStyle(
                        //         fontSize: 20,
                        //         fontWeight: FontWeight.w700,
                        //       ),
                        //     ),
                        //     SizedBox(),
                        //   ],
                        // ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  '행신중 2-2',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  '안녕하세요',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.transparent,
                                  border: Border.all(
                                    width: 1,
                                    color:
                                        const Color.fromRGBO(211, 211, 211, 1),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '다가오는 수행평가',
                                    ),
                                    Text(
                                      (() {
                                        if (suData.length > 1) {
                                          return "${suData[0]['name']},${suData[1]['name']}";
                                        } else if (suData.length > 0 &&
                                            suData[0] != 'nodata') {
                                          return suData[0]['name'];
                                        } else {
                                          return "없음";
                                        }
                                      })(),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Container(
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
                              customBorder: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)
                              ),
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context) => examview()),);
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
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: Colors.grey,
                                                      blurRadius: 20),
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
                                          '기말까지: D-${DateTime(2022, 12, 6).difference(DateTime.now()).inDays}',
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
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: const [
                            Text(
                              '시간표',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.all(15),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.transparent,
                            border: Border.all(
                              width: 1,
                              color: const Color.fromRGBO(211, 211, 211, 1),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Table(
                                // border: TableBorder.all(
                                //   color: Color.fromRGBO(211, 211, 211, 1),
                                //   borderRadius: BorderRadius.circular(10),
                                // ),
                                defaultColumnWidth: const FixedColumnWidth(50),
                                columnWidths: const {
                                  0: FixedColumnWidth(20),
                                },
                                defaultVerticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                children: const [
                                  TableRow(
                                    children: [
                                      Center(),
                                      Center(
                                        child: Text(
                                          '월',
                                          style: TextStyle(
                                            color: Color.fromRGBO(
                                                158, 158, 158, 1),
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: Text(
                                          '화',
                                          style: TextStyle(
                                            color: Color.fromRGBO(
                                                158, 158, 158, 1),
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: Text(
                                          '수',
                                          style: TextStyle(
                                            color: Color.fromRGBO(
                                                158, 158, 158, 1),
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: Text(
                                          '목',
                                          style: TextStyle(
                                            color: Color.fromRGBO(
                                                158, 158, 158, 1),
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Center(
                                          child: Text(
                                        '금',
                                        style: TextStyle(
                                          color:
                                              Color.fromRGBO(158, 158, 158, 1),
                                          fontSize: 16,
                                        ),
                                      )),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    children: [
                                      SizedBox(
                                        width: defwid,
                                        height: defhet,
                                        child: const Center(
                                          child: Text(
                                            '1',
                                            style: TextStyle(
                                              color: Color.fromRGBO(
                                                  158, 158, 158, 1),
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: defwid,
                                        height: defhet,
                                        child: const Center(
                                          child: Text(
                                            '2',
                                            style: TextStyle(
                                              color: Color.fromRGBO(
                                                  158, 158, 158, 1),
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: defwid,
                                        height: defhet,
                                        child: const Center(
                                          child: Text(
                                            '3',
                                            style: TextStyle(
                                              color: Color.fromRGBO(
                                                  158, 158, 158, 1),
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: defwid,
                                        height: defhet,
                                        child: const Center(
                                          child: Text(
                                            '4',
                                            style: TextStyle(
                                              color: Color.fromRGBO(
                                                  158, 158, 158, 1),
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: defwid,
                                        height: defhet,
                                        child: const Center(
                                          child: Text(
                                            '5',
                                            style: TextStyle(
                                              color: Color.fromRGBO(
                                                  158, 158, 158, 1),
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: defwid,
                                        height: defhet,
                                        child: const Center(
                                          child: Text(
                                            '6',
                                            style: TextStyle(
                                              color: Color.fromRGBO(
                                                  158, 158, 158, 1),
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: defwid,
                                        height: defhet,
                                        child: const Center(
                                          child: Text(
                                            '7',
                                            style: TextStyle(
                                              color: Color.fromRGBO(
                                                  158, 158, 158, 1),
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 250,
                                    child: ListView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      scrollDirection: Axis.vertical,
                                      itemCount: 7,
                                      itemBuilder: (context, clindex) {
                                        return SizedBox(
                                          height: 50,
                                          child: ListView.builder(
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            scrollDirection: Axis.horizontal,
                                            shrinkWrap: true,
                                            itemCount: 5,
                                            itemBuilder: (context, index) {
                                              int a = clindex + 1;
                                              List? p = sg?['${a.toString()}교시']
                                                  .toString()
                                                  .split(',');
                                              if (index == 4 && clindex != 6) {
                                                return Container(
                                                  width: 50,
                                                  decoration:
                                                      const BoxDecoration(
                                                    border: Border(
                                                      top: BorderSide(
                                                        width: 1,
                                                        color: const Color
                                                                .fromRGBO(
                                                            211, 211, 211, 1),
                                                      ),
                                                      left: BorderSide(
                                                        width: 1,
                                                        color: const Color
                                                                .fromRGBO(
                                                            211, 211, 211, 1),
                                                      ),
                                                      right: BorderSide(
                                                        width: 1,
                                                        color: const Color
                                                                .fromRGBO(
                                                            211, 211, 211, 1),
                                                      ),
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child:
                                                        Text(p?[index] ?? ""),
                                                  ),
                                                );
                                              }
                                              if (clindex == 6 && index != 4) {
                                                return Container(
                                                  width: 50,
                                                  decoration:
                                                      const BoxDecoration(
                                                    border: Border(
                                                      top: BorderSide(
                                                        width: 1,
                                                        color: const Color
                                                                .fromRGBO(
                                                            211, 211, 211, 1),
                                                      ),
                                                      left: BorderSide(
                                                        width: 1,
                                                        color: const Color
                                                                .fromRGBO(
                                                            211, 211, 211, 1),
                                                      ),
                                                      bottom: BorderSide(
                                                        width: 1,
                                                        color: const Color
                                                                .fromRGBO(
                                                            211, 211, 211, 1),
                                                      ),
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child:
                                                        Text(p?[index] ?? ""),
                                                  ),
                                                );
                                              }
                                              if (index == 4 && clindex == 6) {
                                                return Container(
                                                  width: 50,
                                                  decoration:
                                                      const BoxDecoration(
                                                    border: Border(
                                                      top: BorderSide(
                                                        width: 1,
                                                        color: const Color
                                                                .fromRGBO(
                                                            211, 211, 211, 1),
                                                      ),
                                                      left: BorderSide(
                                                        width: 1,
                                                        color: const Color
                                                                .fromRGBO(
                                                            211, 211, 211, 1),
                                                      ),
                                                      right: BorderSide(
                                                        width: 1,
                                                        color: const Color
                                                                .fromRGBO(
                                                            211, 211, 211, 1),
                                                      ),
                                                      bottom: BorderSide(
                                                        width: 1,
                                                        color: const Color
                                                                .fromRGBO(
                                                            211, 211, 211, 1),
                                                      ),
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child:
                                                        Text(p?[index] ?? ""),
                                                  ),
                                                );
                                              }
                                              return Container(
                                                width: 50,
                                                decoration: const BoxDecoration(
                                                  border: Border(
                                                    top: BorderSide(
                                                      width: 1,
                                                      color:
                                                          const Color.fromRGBO(
                                                              211, 211, 211, 1),
                                                    ),
                                                    left: BorderSide(
                                                      width: 1,
                                                      color:
                                                          const Color.fromRGBO(
                                                              211, 211, 211, 1),
                                                    ),
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Text(p?[index] ?? ""),
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  '수행평가',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            checker(suData),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
            );
          } else if (snapshot.hasError) {
            return const Text('에러 발생. 에러코드: wowddongo');
          }
          return const Text('에러 발생. 에러코드:ssibal');
        },
      ),
    );
  }
}
