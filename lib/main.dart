import 'package:RevMate/models/fcm_service.dart';
import 'package:RevMate/models/firebase_options.dart';
import 'package:RevMate/views/login/login_page.dart';
import 'package:RevMate/views/main/main_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:RevMate/route.dart'; // AppRoutes import 추가

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Firebase 초기화
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // FCM 설정 및 토큰 처리
    await _initializeFCM();

    // FCM 서비스 초기화
    FCMService();

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

  // 알림 권한 요청
  await _requestNotificationPermission();

  User? user = FirebaseAuth.instance.currentUser;

  // 로그인된 사용자에 대해 FCM 토큰 저장
  if (user != null) {
    String? token = await messaging.getToken();
    if (token != null) {
      await saveTokenToDatabase(user.uid, token); // 토큰 저장
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

// 알림 권한 요청 함수 (Android, iOS 모두 대응)
Future<void> _requestNotificationPermission() async {
  PermissionStatus status = await Permission.notification.request();

  if (status.isGranted) {
    print('알림 권한 허용됨');
  } else if (status.isDenied) {
    print('알림 권한 거부됨');
    openAppSettings();
  } else if (status.isPermanentlyDenied) {
    print('알림 권한 영구적으로 거부됨');
    openAppSettings();
  }
}

// FCM 토큰을 Firebase Realtime Database에 저장하는 함수
Future<void> saveTokenToDatabase(String uid, String token) async {
  DatabaseReference ref = FirebaseDatabase.instance.ref('users/$uid/token');
  await ref.set(token); // Firebase Realtime Database에 토큰 저장
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
      initialRoute: '/', // 초기 경로 설정
      onGenerateRoute: AppRoutes.generateRoute,
      home: const AuthCheck(),// AppRoutes에 정의된 라우팅 사용
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
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(context, AppRoutes.loginPage);
            });
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(context, AppRoutes.mainPage);
            });
          }
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
