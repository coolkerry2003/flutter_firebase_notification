import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  String? token = await FirebaseMessaging.instance.getToken();
  print("token: $token");
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print(message);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _push_messsage = "";

  void _initFirebaseMessage()async{
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    //for iOS 的權限設定
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true
    );
    if(settings.authorizationStatus != AuthorizationStatus.authorized){
      //顯示提示Dialog
      // DialogUtil.showMessageDialog(context, "如果不授予權限，將無法收到推播訊息進行驗證。");
    }else{
      FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
        //APP關閉時，透過原生Notification點進APP時的觸發點
        print('Got a message whilst in the getInitialMessage!');
        StringBuffer stringBuffer = StringBuffer();
        stringBuffer.write("Got a message whilst in the getInitialMessage! \n");
        if(message != null){
          print("body: ${message.notification?.body}");
          stringBuffer.write("${message.notification?.body} \n");
          setState((){
            _push_messsage = stringBuffer.toString();
          });
        }
      });
      FirebaseMessaging.onMessage.listen((RemoteMessage message){
        //前景接message
        print('Got a message whilst in the onMessage!');
        StringBuffer stringBuffer = StringBuffer();
        stringBuffer.write("Got a message whilst in the onMessage! \n");
        if(message != null){
          print("body: ${message.notification?.body}");
          stringBuffer.write("${message.notification?.body} \n");
          setState((){
            _push_messsage = stringBuffer.toString();
          });
        }
      });
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message){
        //APP在背景時，點Notification進入APP時的觸發點。
        print('Got a message whilst in the onMessageOpenedApp!');
        StringBuffer stringBuffer = StringBuffer();
        stringBuffer.write("Got a message whilst in the onMessageOpenedApp! \n");
        if(message != null){
          print("body: ${message.notification?.body}");
          stringBuffer.write("${message.notification?.body} \n");
          setState((){
            _push_messsage = stringBuffer.toString();
          });
        }
      });
    }
  }

  

  @override
  Widget build(BuildContext context) {
    _initFirebaseMessage();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Push Messsage',
            ),
            Text(
              _push_messsage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}

