import 'package:flutter/material.dart';
import 'status_page.dart';
import 'reserve_page.dart';
import 'my_page.dart';
import 'package:RevMate/views/widgets/animated_page_route.dart';
import 'logout_dialog.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('메인 페이지'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const LogoutDialog(),
              );
            },
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildMenuButton(context, '예약 현황', StatusPage()),
          _buildMenuButton(context, '예약하기', ReservePage()),
          _buildMenuButton(context, '마이페이지', MyPage()),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String label, Widget page) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).push(animatedPageRoute(page: page));
      },
      child: Text(label),
    );
  }
}
