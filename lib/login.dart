import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'mainpage.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else {
              if (snapshot.hasData) {
                return const MainPage();
              } else {
                return const LoginPage();
              }
            }
          }
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인'),
      ),
      body: LoginForm(),
    );
  }
}

class LoginForm extends StatelessWidget {
  final TextEditingController _emailInputText = TextEditingController();
  final TextEditingController _passInputText = TextEditingController();

  LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/icons_logo.png',
            height: 100,
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: TextField(
              controller: _emailInputText,
              decoration: const InputDecoration(hintText: '아이디'),
            ),
          ),
          const SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: TextField(
              controller: _passInputText,
              obscureText: true,
              decoration: const InputDecoration(hintText: '비밀번호'),
            ),
          ),
          const SizedBox(height: 24.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const ElevatedButton(
                onPressed: _launchSignUpURL,
                child: Text('회원가입'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_emailInputText.text.isEmpty || _passInputText.text.isEmpty) return;

                  try {
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: _emailInputText.text.toLowerCase().trim(),
                      password: _passInputText.text.trim(),
                    );

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MainPage()),
                    );
                  } on FirebaseAuthException catch (e) {
                    String errorMessage;

                    if (e.code == 'user-not-found') {
                      errorMessage = '이메일이 맞지않습니다.';
                    } else if (e.code == 'wrong-password') {
                      errorMessage = '비밀번호가 틀렸습니다.';
                    } else {
                      errorMessage = '로그인에 실패했습니다.';
                    }

                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('로그인 실패'),
                        content: Text(errorMessage),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('확인'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: const Text('로그인'),
              ),
            ],
          )
        ],
      ),
    );
  }
}

void _launchSignUpURL() async {
  const url = 'https://himakerland.com/maker/page/signup.motion?bmode=type';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
