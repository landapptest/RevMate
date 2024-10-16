import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:RevMate/views/login_page.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('로그아웃'),
      content: const Text('로그아웃 하시겠습니까?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.of(context)
              ..pop()
              ..pushReplacement(
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
          },
          child: const Text('로그아웃'),
        ),
      ],
    );
  }
}
