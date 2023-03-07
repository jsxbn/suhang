import 'dart:async';
import 'dart:ui';
import 'dart:convert';

import 'package:chat_bubbles/bubbles/bubble_normal.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:lottie/lottie.dart';

class AdvancedChatPage extends StatefulWidget {
  AdvancedChatPage({Key? key}) : super(key: key);

  @override
  State<AdvancedChatPage> createState() => _AdvancedChatPageState();
}

class _AdvancedChatPageState extends State<AdvancedChatPage> {
//   List<Map<String, String>> _messages = [
//     {
//       "role": "system",
//       "content": '''
// Please convert the received question into a search term or search keyword format that is easy to handle by search engines, and return it.
// The returned string must be in the same language as the question.
// Please do not enclose the string in quotation marks and avoid using special characters as much as possible.
// Only show the converted search term.

// Current Date: ${DateTime.now()}
//           '''
//     },
//   ];
  List<Map<String, String>> _messages = [
    {
      "role": "system",
      "content":
          "Your name is Quest AI, and you are an assistant who helps students with their homework."
    },
  ];
  ScrollController _scrollController = ScrollController();
  List<String> chatlist = ['안녕하세요! \n무엇을 도와드릴까요?'];
  String _cache = " ";

  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;
  StreamController _stream = StreamController();

  Widget preFix() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/questlogo.png',
          width: 150,
          height: 150,
        ),
        Text(
          'quest',
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(
          width: 300,
          child: Text(
            'ADVANCED PAGE\n정확하지 않은 결과를 도출할 수 있습니다.\n사실관계 확인이 필요하며, 이로인해 발생하는 모든 책임은 사용자에게 있습니다',
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget chatList() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: chatlist.length,
      itemBuilder: (context, index) {
        if (index % 2 == 0) {
          return GestureDetector(
            onLongPress: () async {
              await Clipboard.setData(ClipboardData(text: chatlist[index]));
              Fluttertoast.showToast(msg: '클립보드에 복사됨');
            },
            child: BubbleNormal(
              isSender: false,
              color: Color(0xFFF5F5F7),
              text: chatlist[index],
              textStyle: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF27262A),
              ),
            ),
          );
        }
        return BubbleNormal(
          isSender: true,
          color: Color(0xFF6E62E6),
          text: chatlist[index],
          textStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        );
      },
    );
  }

  // Future<Map<String, dynamic>> search(String query) async{
  //   var client = auth.clientViaApiKey("AIzaSyCLyWsU7rX95FQIMu8bDNn2M_2RE9hAm7k");
  //   final searchapi = CustomSearchApi(client);
  //   final searchresult = searchapi.cse.list(
  //     cx: "f7786ab9abe5c4536"
  //     $fields:
  //   );
  //   print(data);
  //   return data;
  // }

  void _handleSubmitted(String text) async {
    _textController.clear();
    setState(() {
      chatlist.add(text);
      _messages.add({"role": "user", "content": text});
      _isLoading = true;
    });
    chatlist.add('');
    await getOpenAIResponse(text);
    print("well-done.");
    setState(() {
      _isLoading = false;
    });
  }

  applychange(String response) {
    if (this.mounted) {
      setState(() {
        chatlist.last = response;
      });
    }
  }

  Future<void> getOpenAIResponse(String prompt) async {
    bool? isOnline;
    String streamtext = "";
    try {
      isOnline = await InternetConnectionChecker().hasConnection;
    } catch (e) {
      isOnline = true;
    }
    if (isOnline) {
      const apiKey = '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';

      var url = Uri.https(
        "api.openai.com",
        "/v1/chat/completions",
      );
      http.StreamedRequest request = http.StreamedRequest(
        'POST',
        url,
      )
        ..headers['Accept'] = 'text/event-stream'
        ..headers['Content-Type'] = 'application/json'
        ..headers['Authorization'] = 'Bearer $apiKey';

      request.sink.add(utf8.encode(json.encode({
        "model": "gpt-3.5-turbo",
        "messages": _messages,
        "stream": true,
      })));
      request.sink.close();
      http.StreamedResponse finalresponse = await request.send();

      if (finalresponse.statusCode == 200) {
        finalresponse.stream.listen((data) {
          String utfdecoded = utf8.decode(data);
          if (utfdecoded.contains('content')){
            print(utfdecoded);
            String content = jsonDecode(utfdecoded.substring(6))["choices"][0]["delta"]
                ["content"];
            print(content);
            streamtext +=content;
            print(streamtext);
          applychange(streamtext);
          }
          if(utfdecoded.contains('DONE')){
            _messages.add({"role": "assistant", "content": streamtext});
          }
        });
      } else {
        applychange(
            '에러 발생:\nStatus Code ${finalresponse.statusCode}\n다시 시도해주세요.\n에러가 지속될시 문의하세요');
      }
    } else {
      applychange('인터넷 연결 안됨');
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.fastOutSlowIn,
        );
      },
    );
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  preFix(),
                  SizedBox(height: 20),
                  chatList(),
                  chatlist.length >= 33
                      ? Center(
                          child: Text(
                          '한 대화 세션당 최대 대화 횟수는 16번입니다.\n왼쪽 하단 버튼을 눌러 새로운 세션을 시작하세요.',
                          textAlign: TextAlign.center,
                        ))
                      : const SizedBox(),
                  const SizedBox(height: 80)
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _messages = [
                      {
                        "role": "system",
                        "content":
                            "Your name is Quest AI, and you are an assistant who helps students with their homework."
                      },
                    ];
                    chatlist = ['새로운 대화 세션입니다.\n무엇을 도와드릴까요?'];
                    _isLoading = false;
                  });
                },
                child: Container(
                  height: 60,
                  width: 60,
                  margin: EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 44, 132, 233),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.clear_all_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              IntrinsicWidth(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        height: 60,
                        width: MediaQuery.of(context).size.width - 90,
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Color.fromARGB(255, 12, 11, 13)
                                .withOpacity(0.8)),
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                autocorrect: false,
                                onChanged: ((value) => setState(() {})),
                                enabled: !_isLoading && chatlist.length < 33,
                                controller: _textController,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "물어보기",
                                  hintStyle: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white30,
                                  ),
                                ),
                                cursorColor: Colors.white38,
                              ),
                            ),
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: IconButton(
                                color: Colors.white60,
                                icon: Icon(Icons.send),
                                onPressed: _textController.text == ''
                                    ? null
                                    : () {
                                        _handleSubmitted(_textController.text);
                                      },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
