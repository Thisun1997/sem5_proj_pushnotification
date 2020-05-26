import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:push_notification/Message.dart';
import 'package:push_notification/SharedPref.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

const EVENTS_KEY = "current_longLat_push";


void backgroundFetchHeadlessTask(String taskId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  print(position);
  print("[BackgroundFetch] Headless event received: $taskId");
  String tokenGet = prefs.getString('fcm_token_push');
  print(tokenGet);

  List<String> events = [];
  String json = prefs.getString(EVENTS_KEY);
  if (json != null) {
     events = jsonDecode(json).cast<String>();
   }
  if(events.length == 2){
    events.removeLast();
  }
  events.insert(0, "$position");
  prefs.setString(EVENTS_KEY, jsonEncode(events));

  var currLocationList = events[0].split(', ');
  var currLocation = [currLocationList[0].substring(5),currLocationList[1].substring(6)];
  var prevLocation = null;
  if (events.length ==2){
    var prevLocationList = events[1].split(', ');
    prevLocation = [prevLocationList[0].substring(5),prevLocationList[1].substring(6)];
  }

  var res = {
    'prev_location': prevLocation,
    'curr_location': currLocation,
    'FCM_token': tokenGet
  };
  print(res);
  BackgroundFetch.finish(taskId);
}



void main() { runApp(new MyApp());
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);}


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
      home: MyHomePage(title: 'Push notification System'),
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
  bool _enabled = true;
  List<String> _events = [];
  String _token_get;

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

  void _gettoken() async{
    String token = await _firebaseMessaging.getToken();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('fcm_token_push', token);
  }


  void initState(){
    super.initState();
    loadSharedPrefs();
    _firedaseconfig();
    _gettoken();
    initPlatformState();
  }

  Future<Map<String,dynamic>> _saveLocation() async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String json = prefs.getString(EVENTS_KEY);
      if (json != null) {
        setState(() {
          _events = jsonDecode(json).cast<String>();
        });
      }

      Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      print(position);
      setState(() {
        if(_events.length == 2){
          _events.removeLast();
        }
        _events.insert(0, "$position");
      });

      prefs.setString(EVENTS_KEY, jsonEncode(_events));
      //print(_events);
      _token_get = prefs.getString('fcm_token_push');
      print(_token_get);
      var currLocationList = _events[0].split(', ');
      var currLocation = [currLocationList[0].substring(5),currLocationList[1].substring(6)];
      var prevLocation = null;
      if (_events.length ==2){
        var prevLocationList = _events[1].split(', ');
        prevLocation = [prevLocationList[0].substring(5),prevLocationList[1].substring(6)];
      }

      var res = {
        'prev_location': prevLocation,
        'curr_location': currLocation,
        'FCM_token': _token_get
      };
      //send to server
      return res;
  }

  Future<void> initPlatformState() async {
    
    // Load persisted fetch events from SharedPreferences
    var l =await  _saveLocation();
    print(l);
    //send to server
    
    

    // Configure BackgroundFetch.
    BackgroundFetch.configure(BackgroundFetchConfig(
        minimumFetchInterval: 15,
        forceAlarmManager: false,
        stopOnTerminate: false,
        startOnBoot: true,
        enableHeadless: true,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresStorageNotLow: false,
        requiresDeviceIdle: false,
        requiredNetworkType: NetworkType.NONE,
    ), _onBackgroundFetch).then((int status) {
      print('[BackgroundFetch] configure success: $status');

    }).catchError((e) {
      print('[BackgroundFetch] configure ERROR: $e');
    
    });
    if (!mounted) return;
  }


  void _onBackgroundFetch(String taskId) async {
    var l =await _saveLocation();
    print(l);
    BackgroundFetch.finish(taskId);
  }

  void _onClickEnable(enabled) {
    setState(() {
      _enabled = enabled;
    });
    if (enabled) {
      BackgroundFetch.start().then((int status) {
        print('[BackgroundFetch] start success: $status');
      }).catchError((e) {
        print('[BackgroundFetch] start FAILURE: $e');
      });
    } else {
      BackgroundFetch.stop().then((int status) {
        print('[BackgroundFetch] stop success: $status');
      });
    }
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
        actions: <Widget>[
            Switch(value: _enabled, onChanged: _onClickEnable),
          ]
      ),
      body: 
      Center( 
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
