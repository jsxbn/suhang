import 'dart:ui';

import 'package:chat_bubbles/bubbles/bubble_normal.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
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
  int _selected = 1;
  List<Map<String, String>> _messages = [
    {
      "role": "system",
      "content":
          "Your name is Quest AI, and you are an assistant who helps students with their homework."
    },
  ];
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
        SizedBox(height: 5),
        CustomSlidingSegmentedControl<int>(
          initialValue: 1,
          children: {
            1: const Text(
              '채팅',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            2: const Text(
              '검색',
              style: TextStyle(fontWeight: FontWeight.w500),
            )
          },
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          thumbDecoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4.0,
                spreadRadius: 1.0,
                offset: const Offset(
                  0.0,
                  2.0,
                ),
              ),
            ],
          ),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInToLinear,
          onValueChanged: (v) {
            setState(() {
              _isLoading = false;
              _selected = v;
              _messages = [
                {
                  "role": "system",
                  "content": '''
Your name is Quest AI.
'''
                },
              ];
              chatlist = _selected == 1
                  ? ['새로운 대화 세션입니다.\n무엇을 도와드릴까요?']
                  : [
                      '검색 모드입니다.\n검색 엔진과 연동하여 비교적 정확하고, 최신의 정보를 제공합니다.\n이전 채팅 내용을 기억할 수 없습니다.'
                    ];
            });
          },
        ),
        SizedBox(
          height: 10,
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
      _messages.add({"role": "user", "content": text});
      _isLoading = true;
    });
    print(text);
    String response = await getOpenAIResponse(text);
    debugPrint(response);
    if (this.mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String> extractQuery(String apiKey, String text) async {
    var url = Uri.https(
      "api.openai.com",
      "/v1/chat/completions",
    );

    var response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {
              "role": "system",
              "content": '''
Please convert the received question into a search term or search keyword format that is easy to handle by search engines, and return it. 
Please do not enclose the string in quotation marks and avoid using special characters as much as possible.
Only show the converted search term.
Current date: ${DateTime.now()}
the question you received is:
                '''
            },
            {'role': 'user', 'content': "\"$text\""}
          ]
        }));
    return jsonDecode(utf8.decode(response.bodyBytes))["choices"][0]["message"]
        ["content"];
  }

  Future<List<Map<String, dynamic>>> search(String query) async {
    var url = Uri.parse(
        "https://api.bing.microsoft.com/v7.0/search?q=$query&count=5");
    http.Response response = await http.get(
      url,
      headers: {
        'Ocp-Apim-Subscription-Key': "cc34dfd75fd34d73b854cc5d48ab3c07",
        "Content-Type": "application/json"
      },
    );
    return (json.decode(utf8.decode(response.bodyBytes))["webPages"]["value"]
            as List)
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }

  String formalResutls(List<Map<String, dynamic>> results) {
    String formed = results
        .map((r) => "${results.indexOf(r)}. ${r['name']}, ${r['snippet']}")
        .join('\n');
    return formed;
  }

  String makesource(List<Map<String, dynamic>> results) {
    String source = results
        .map((r) => "${results.indexOf(r)}. ${r['name']}, ${r['url']}")
        .join('\n');
    return source;
  }

  Future<String> getOpenAIResponse(String prompt) async {
      const apiKey = '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';
      String formresults = "";
      String sourceresults = "";
      http.Response response;
      if (_selected == 2) {
        String searchquery = await extractQuery(apiKey, prompt);
        List<Map<String, dynamic>> searchresults =
            await search(searchquery) as List<Map<String, dynamic>>;
        formresults = formalResutls(searchresults);
        sourceresults = makesource(searchresults);
        var url = Uri.https("api.openai.com", "/v1/chat/completions");
        response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            "Authorization": "Bearer $apiKey"
          },
          body: json.encode({
            "model": "gpt-3.5-turbo",
            'messages': [
              {
                "role": "system",
                "content": '''
Using the following guidelines, please create a newly organized text in step-by-step fashion.
(1) Use the given references related to the question to create a completely new text.
(1-1) The context should be as smooth as possible.
(1-2) Use vocabulary that is easy to read.
(1-3) It is okay to mix the context back and forth.
(1-4) responde as Korean.
(2) Mark the relevant reference number in the form of a comment [number] at the end of the word, sentence, or paragraph.
(2-1) Always include a reference for proper nouns.
(2-2) e.g. His name is Moon Jae-In[1][3], and he was South Korea's president[2].
(3) Use the following criteria for references.
(3-1) Do not use subjective or biased references.
(3-2) Do not use uncertain or factually unsupported references.
(3-3) Try to avoid using references other than Wikipedia, media, government, or corporate websites.
(3-4) Do not make up stories when there are no references available.
The given references are as follows:
${formresults}
the question is:
'''
              },
              {"role": "user", "content": prompt}
            ],
          }),
        );
      } else {
        var url = Uri.https("api.openai.com", "/v1/chat/completions");
        response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            "Authorization": "Bearer $apiKey"
          },
          body: json.encode({
            "model": "gpt-3.5-turbo",
            'messages': _messages,
          }),
        );
      }

      if (response.statusCode == 200) {
        Map<String, dynamic> newresponse =
            jsonDecode(utf8.decode(response.bodyBytes));
        print(response.statusCode);
        if (_selected == 1) {
          _messages.add({
            "role": "assistant",
            "content": newresponse['choices'][0]['message']['content']
          });
          chatlist.add(newresponse['choices'][0]['message']['content']);
          return newresponse['choices'][0]['message']['content'];
        } else {
          chatlist.add('''${newresponse['choices'][0]['message']['content']}
==========
참조:
$sourceresults
''');
          return '''${newresponse['choices'][0]['message']['content']}
==========
참조:
$sourceresults
''';
        }
      } else {
        return '에러 발생:\nStatus Code ${response.statusCode}\n다시 시도해주세요.\n에러가 지속될시 문의하세요';
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
                  chatlist.length >= 9
                      ? Center(
                          child: Text(
                          '한 대화 세션당 최대 대화 횟수는 4번입니다.\n왼쪽 하단 버튼을 눌러 새로운 세션을 시작하세요.',
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
                    ;
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
                                enabled: !_isLoading && chatlist.length < 9,
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
