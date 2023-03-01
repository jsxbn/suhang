import 'dart:ui';

import 'package:chat_bubbles/bubbles/bubble_normal.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:lottie/lottie.dart';

class ChatPage extends StatefulWidget {
  ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  ScrollController _scrollController = ScrollController();
  List<String> chatlist = ['안녕하세요! \n무엇을 도와드릴까요?'];

  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;

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
            '정확하지 않은 결과를 도출할 수 있습니다.\n사실관계 확인이 필요하며, 이로인해 발생하는 모든 책임은 사용자에게 있습니다',
            textAlign: TextAlign.center,
          ),
        ),
        chatlist.length == 1 ? exampleChat() : SizedBox()
      ],
    );
  }

  Widget exampleChat() {
    return Column(
      children: [
        Container(
          width: 250,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Write an assey about global warming'
          ),
        )
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
            onLongPress: () async{
              await Clipboard.setData(ClipboardData(text: "your text"));
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
        print(chatlist[index]);
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

  void _handleSubmitted(String text) async {
    print('pressed!');
    _textController.clear();
    setState(() {
      chatlist.add(text);
      _isLoading = true;
    });
    print(text);
    String response = await getOpenAIResponse(text);
    debugPrint(response);
    if (this.mounted) {
      setState(() {
        chatlist.add(response.substring(2));
        _isLoading = false;
      });
    }
  }

  Future<String> getOpenAIResponse(String prompt) async {
    bool isOnline = await InternetConnectionChecker().hasConnection;
    if (isOnline) {
      const apiKey = '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';

      var url = Uri.https("api.openai.com", "/v1/completions");
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer $apiKey"
        },
        body: json.encode({
          "model": "text-davinci-003",
          "prompt": prompt,
          'temperature': 0,
          'max_tokens': 800,
          'top_p': 1,
          'frequency_penalty': 0.0,
          'presence_penalty': 0.0,
        }),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> newresponse =
            jsonDecode(utf8.decode(response.bodyBytes));
        print(response.statusCode);
        return newresponse['choices'][0]['text'];
      } else {
        return '에러 발생:\nStatus Code ${response.statusCode}\n에러가 지속될시 문의하세요';
      }
    } else {
      return '인터넷 연결 안됨';
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        print('widget binding');
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
                  _isLoading
                      ? Container(
                          width: 250,
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Color(0xFFF5F5F7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Lottie.asset('assets/64108-loading-dots.json'),
                              Text('로드하는동안 탭을 변경하지 마세요')
                            ],
                          ),
                        )
                      : const SizedBox(),
                  const SizedBox(height: 80)
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: double.infinity,
              height: 60,
              padding: const EdgeInsets.all(8.0),
              margin: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Color.fromARGB(255, 12, 11, 13).withOpacity(0.8)),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      onChanged: ((value) => setState(() {})),
                      enabled: !_isLoading,
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
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
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
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
