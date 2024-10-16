import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Firebase 초기화
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // FCM 설정 및 토큰 처리
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // 로그인된 사용자 정보 가져오기
    User? user = FirebaseAuth.instance.currentUser;

    // 사용자 로그인이 되어있는 경우 FCM 토큰 저장
    if (user != null) {
      String? token = await messaging.getToken();  // FCM 토큰 가져오기
      if (token != null) {
        await saveTokenToDatabase(user.uid, token);  // 토큰 저장
      }
    }

    // FCM 토큰이 갱신될 때마다 호출되는 리스너 설정
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      if (user != null) {
        await saveTokenToDatabase(user.uid, newToken);  // 갱신된 토큰 저장
      }
    });

    runApp(const MyApp());
  } catch (e) {
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Firebase 초기화에 실패했습니다: $e'),
        ),
      ),
    ));
  }
}

// FCM 토큰을 Firebase Realtime Database에 저장하는 함수
Future<void> saveTokenToDatabase(String uid, String token) async {
  DatabaseReference ref = FirebaseDatabase.instance.ref('users/$uid/token');
  await ref.set(token);  // Firebase Realtime Database에 토큰 저장
  print("FCM 토큰 저장 완료: $token");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RevMate',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      navigatorObservers: <NavigatorObserver>[observer],
      home: const Login(),
    );
  }
}
