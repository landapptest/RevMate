import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';

class Logout extends StatelessWidget {
  const Logout({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;

    return AlertDialog(
      title: const Text('로그아웃'),
      content: const Text('로그아웃 하시겠습니까?\n로그인 페이지로 돌아갑니다.'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('아니오'),
        ),
        TextButton(
          onPressed: () async {
            await auth.signOut();
            Navigator.of(context)
              ..pop()
              ..pushReplacement(
                MaterialPageRoute(builder: (context) => const Login()),
              );
          },
          child: const Text('예'),
        ),
      ],
    );
  }
}
