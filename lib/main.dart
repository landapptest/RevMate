import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:RevMate/views/login/login_page.dart';
import 'package:RevMate/views/main/main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Firebase 초기화
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // FCM 설정 및 토큰 처리
    await _initializeFCM();

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

// FCM 초기화 및 토큰 처리 함수
Future<void> _initializeFCM() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  User? user = FirebaseAuth.instance.currentUser;

  // 로그인된 사용자에 대해 FCM 토큰 저장
  if (user != null) {
    String? token = await messaging.getToken();
    if (token != null) {
      await saveTokenToDatabase(user.uid, token);  // 토큰 저장
    }
  }

  // 토큰 갱신 시마다 처리
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    User? refreshedUser = FirebaseAuth.instance.currentUser;
    if (refreshedUser != null) {
      await saveTokenToDatabase(refreshedUser.uid, newToken);
    }
  });
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
      home: const AuthCheck(),  // AuthCheck 위젯 추가
    );
  }
}

// 로그인 상태 확인 후 페이지 전환
class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 사용자가 로그인한 상태면 MainPage로 이동
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user == null) {
            // 로그인한 사용자가 없으면 LoginPage로 이동
            return LoginPage();
          } else {
            // 로그인한 사용자가 있으면 MainPage로 이동
            return const MainPage();
          }
        }
        // 로딩 중일 때
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
