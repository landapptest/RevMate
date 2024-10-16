import 'package:flutter/material.dart';
import 'package:RevMate/controllers/login_controller.dart';

class LoginPage extends StatelessWidget {
  final LoginController _loginController = LoginController();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: '이메일'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: '비밀번호'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _loginController.signIn(
                    _emailController.text.trim(),
                    _passwordController.text.trim(),
                  );
                  // 로그인 성공 시 다음 페이지로 이동
                  Navigator.pushReplacementNamed(context, '/main');
                } catch (e) {
                  // 로그인 실패 처리
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('로그인 실패: $e')));
                }
              },
              child: const Text('로그인'),
            ),
          ],
        ),
      ),
    );
  }
}
