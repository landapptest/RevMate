import 'package:flutter/material.dart';
import 'package:RevMate/controllers/login_controller.dart';
import 'package:RevMate/views/widgets/styles.dart';
import 'package:url_launcher/url_launcher.dart';

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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons_logo.png', // 경로 유지
              height: 100,
            ),
            const SizedBox(height: 20),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    try {
                      _launchSignUpURL(); // URL 유지
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('회원가입 페이지를 열 수 없습니다: $e')),
                      );
                    }
                  },
                  style: primaryButtonStyle,
                  child: const Text('회원가입'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await _loginController.signIn(
                        _emailController.text.trim(),
                        _passwordController.text.trim(),
                      );
                      Navigator.pushReplacementNamed(context, '/main'); // 수정된 라우트
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('로그인 실패: $e')),
                      );
                    }
                  },
                  style: primaryButtonStyle,
                  child: const Text('로그인'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void _launchSignUpURL() async {
  const url = 'https://himakerland.com/maker/page/signup.motion?bmode=type'; // 유지된 URL
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
