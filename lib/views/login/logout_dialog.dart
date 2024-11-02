import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:RevMate/route.dart';
import 'package:RevMate/views/login/login_page.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('로그아웃 하시겠습니까?'),
      content: const Text('로그인 화면으로 돌아갑니다.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.of(context).pushReplacementNamed(AppRoutes.loginPage);
          },
          child: const Text('로그아웃'),
        ),
      ],
    );
  }
}
