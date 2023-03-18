import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:suhang/chatAI.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:suhang/advancedChatAI.dart';
import 'package:suhang/imageviewer.dart';
import 'package:suhang/settings.dart';
import 'package:suhang/splashUI.dart';
import 'package:suhang/tablex.dart';
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
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: MaterialApp(
        
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          useMaterial3: true,
          fontFamily: 'NotoSans',
        ),
        home: Rootpage(),
      ),
    );
  }
}

class Rootpage extends StatefulWidget {
  Rootpage({Key? key}) : super(key: key);

  @override
  State<Rootpage> createState() => _RootpageState();
}

class _RootpageState extends State<Rootpage> with TickerProviderStateMixin {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FlutterLocalNotificationsPlugin? fltNotification;

  Map<String, dynamic>? sh = {}; //수행평가 db
  Map<String, dynamic>? sg; //시간표 db
  double? defwid;
  double? defhet;
  double? tbhet;
  List hey = [];
  List evt = [];
  List nxtlist = [];
  List tdList = [];
  List suData = ['nodata'];
  ScrollController _controller = ScrollController();
  final maxExtent = 230.0;
  double currentExtent = 0.0;
  int _selectedIndex = 0;
  late String formatDate;
  late String nxtDate;
  late var now;
  late List<Widget> _widgetOptions;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // TODO: implement initState
    now = DateTime.now();
    var nxt = now.toLocal().add(const Duration(days: 1));
    formatDate = DateFormat('yyMMdd').format(now);
    nxtDate = DateFormat('yyMMdd').format(nxt);
    formatDate.toString();
    nxtDate.toString();
    _tabController = TabController(
      length: 3,
      vsync: this, //vsync에 this 형태로 전달해야 애니메이션이 정상 처리됨
    );
  }

  void _onItemTapped(int index) {
    // 탭을 클릭했을떄 지정한 페이지로 이동
    setState(() {
      _selectedIndex = index;
    });
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
    sg = sg;
    defwid = 20;
    defhet = 50;
    tbhet = 50;
    evt = eventdate(sh, now);
    nxtlist = sh?[nxtDate].toString().split(',') ?? [];
    tdList = sh?[formatDate].toString().split(',') ?? [];
    return Future.wait([]);
  }

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
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [],
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

  Widget MainPage() {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          '행신중 3-3',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w400),
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
                            color: const Color.fromRGBO(211, 211, 211, 1),
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
                const SizedBox(height: 15),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '시간표',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
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
                  child: TTableX(sg: sg),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _processdata(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return splashui(indicator: true);
          }
          if (snapshot.hasData) {
            return Scaffold(
              body: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: [
                  MainPage(),
                  !kIsWeb? AdvancedChatPage()
                  :ChatPage(),
                  splashui(indicator: false),
                ],
              ),
              // body: [MainPage(), ChatPage(), splashui()]
              //     .elementAt(_selectedIndex), //_selectedIndex
              bottomNavigationBar: SafeArea(
                child: Container(
                  height: 60,
                  padding: EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 50,
                        blurRadius: 40,
                      ),
                    ],
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                    // border: Border.all(
                    //   width: 1,
                    //   color: Color.fromARGB(255, 222, 222, 222),
                    // ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.blue[400],
                    unselectedLabelColor: Colors.black38,
                    indicatorColor: Colors.transparent,
                    tabs: [
                      Icon(
                        Icons.home_filled,
                        size: 30,
                      ),
                      Icon(
                        CupertinoIcons.chat_bubble_2_fill,
                        size: 30,
                      ),
                      Icon(
                        Icons.info,
                        size: 30,
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return const Text('에러 발생. 에러코드: SNHE');
          }
          return const Text('에러 발생. 에러코드: MSSTH');
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
