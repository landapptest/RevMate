import 'package:flutter/material.dart';
import 'status_page.dart';
import '../reservation/reserve_page.dart';
import 'my_page.dart';
import 'package:RevMate/views/widgets/animated_page_route.dart';
import '../login/logout_dialog.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Revmate'),
        toolbarHeight: 70,
        actions: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const LogoutDialog(),
                  );
                },
              ),
              const Text('로그아웃', style: TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMenuButton(
              context,
              'assets/status_icon.png',
              '실시간 현황',
              '현재 예약된 장비 현황을 확인합니다.',
                  () => Navigator.of(context).push(
                animatedPageRoute(page: StatusPage()),
              ),
            ),
            _buildMenuButton(
              context,
              'assets/reserve_icon.png',
              '예약',
              '이용하고자 하는 장비를 예약합니다.',
                  () => Navigator.of(context).push(
                animatedPageRoute(page: const ReservePage()),
              ),
            ),
            _buildMenuButton(
              context,
              'assets/cancel_icon.png',
              '예약 취소',
              '예약된 장비를 취소합니다.',
                  () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const MyPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String assetPath, String title, String subtitle, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Stack(
        children: [
          Image.asset(
            assetPath,
            fit: BoxFit.cover,
            width: double.infinity,
          ),
          Positioned(
            left: 16.0,
            top: 16.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
