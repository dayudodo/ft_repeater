import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
// import 'dart:typed_data';

import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: '中文支持如何'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentIndex;
  AudioPlayer audioPlayer = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: FutureBuilder<List<Sentence>>(
          future: fetchLesson(http.Client()),
          builder: (context, snapshot) {
            if (snapshot.hasError) print(snapshot.error);
            List<Sentence> items = snapshot.data;
            return (ListView.builder(
              itemCount: items.length,
              itemBuilder: (itemContext, index) {
                return Container(
                    child: ListTile(
                      title: Text('${items[index].originalSentence}'),
                      onTap: () => _tapBy(index, items[index].soundFileName),
                    ),
                    color: currentIndex == index
                        ? Color(0xFF00FF00)
                        : Colors.white);
              },
            ));
          }),
    );
  }

  void _tapBy(int index, String soundUrl) {
    play() async {
      audioPlayer.stop();
      String realUrl = "https://www.gsenglish.cn" + soundUrl;
      int result = await audioPlayer.play(realUrl);
      if (result == 1) {
        print('play $soundUrl');
      }
    }

    play();
    setState(() {
      // _mapColor = const Color(0xFF00FF00);
      currentIndex = index;
    });
  }
}

class Sentence {
  final String originalSentence;
  final double startMiliSecond;
  final double endMiliSecond;
  final int positionInMedia;
  final String soundFileName;
  Sentence(
      {this.originalSentence,
      this.startMiliSecond,
      this.endMiliSecond,
      this.positionInMedia,
      this.soundFileName});
  factory Sentence.fromJson(Map<String, dynamic> json) {
    return Sentence(
        originalSentence: json['originalSentence'] as String,
        startMiliSecond: json['startMiliSecond'] as double,
        endMiliSecond: json['endMiliSecond'] as double,
        positionInMedia: json['positionInMedia'] as int,
        soundFileName: json['soundFileName'] as String);
  }
}

List<Sentence> parseLesson(String responseBody) {
  final parsed =
      json.decode(responseBody)['sentences'].cast<Map<String, dynamic>>();

  return parsed.map<Sentence>((json) => Sentence.fromJson(json)).toList();
}

Future<List<Sentence>> fetchLesson(http.Client client) async {
  final response =
      await client.get('https://www.gsenglish.cn/newconcept/show/36.json');

  return parseLesson(response.body);
}
