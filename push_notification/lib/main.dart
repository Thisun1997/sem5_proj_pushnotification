import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:push_notification/Message.dart';
import 'package:push_notification/SharedPref.dart';


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
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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
  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  List<Message> _messages;
  List<Message> _messages_reversed;
  List<String> messageList;
  SharedPref sharedPref = SharedPref();
  final List<Color> colors = [Colors.red, Colors.yellow,Colors.green];
  DateTime now;

  void _firedaseconfig(){
     _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async{
        print('on message $message');
        _setMessage(message);
      },
      onResume: (Map<String, dynamic> message) async{
        print('on resume $message');
        _setMessage(message);
      },
      onLaunch: (Map<String, dynamic> message) async{
        print('on launch $message');
        _setMessage(message);
      },
    );
  }

  void _gettoken(){
    _firebaseMessaging.getToken().then((token) => print(token));
  }

  void initState(){
    super.initState();
    loadSharedPrefs();
    _firedaseconfig();
    _gettoken();
  }

  loadSharedPrefs() async {
    //sharedPref.remove('message_list');
    List<String> messageListFromPrefs = await sharedPref.read('message_list');
    messageList = messageListFromPrefs;
    setState(() {
      _messages = List<Message>();
      _messages_reversed = List<Message>();
      for(int i=0; i<messageList.length;i++){
          Message m = Message.fromJson(json.decode(messageList[i]));
          _messages.add(m);
      }
      _messages_reversed = new List.from(_messages.reversed);
    });
    print(messageList);
  }

  _setMessage(Map<String, dynamic> message){
    final data = message['data'];
    if(data != null){
      final String title = data['title'];
      final String body = data['body'];
      final String level = data['level'];
      final String datetime = data['date_time'];
      setState(() {
        Message m = new Message(title, body, level,datetime);
        if(messageList.length == 10){
          messageList.removeAt(0);
          _messages.removeAt(0);
        }
        messageList.add(json.encode(m));
        _messages.add(m);
        print(messageList.length);
        print( _messages.length);
        sharedPref.save('message_list',messageList);
        _messages_reversed = new List.from(_messages.reversed);
      });
    }
    
  }
  


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
      body: Center(
        //Center is a layout widget. It takes a single child and positions it
        //in the middle of the parent.
        child: ListView.builder(
          itemCount: null == _messages_reversed ? 0: _messages_reversed.length,
          itemBuilder: (context, index){
            return Card(
              color: colors[int.parse(_messages_reversed[index].level) - 1],
              child: ListTile(
                title: Text(_messages_reversed[index].title),
                subtitle: Text('''${_messages_reversed[index].body}
                
${_messages_reversed[index].datetime}'''),
              ),
            );
          },
        ),
      ),        
    );
  }
}
