import 'package:flutter/material.dart';
import 'package:RevMate/controllers/status_controller.dart';
import 'package:RevMate/models/reservation_service.dart';

class StatusPage extends StatelessWidget {
  final List<String> equipmentNames = [
    '싱글플러스_04(S4)',
    '싱글플러스_05(S5)',
    '싱글플러스_06(S6)',
    '싱글플러스_07(S7)',
    '스타일_01(cubstyle01)',
    '스타일_02(cubstyle02)',
    '스타일_03(cubstyle03)',
    '엔더5_01(ender5_01)',
    '엔더5_02(ender5_02)',
    '신도리코_01(sin_01)',
    '신도리코_02(sin_02)',
    '신도리코_03(sin_03)',
    '신도리코_04(sin_04)',
    '레이저커터12*9(12*9)',
    '레이저커터9*6(9*6)',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('실시간 장비 현황'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 20, height: 20, color: Colors.red),
                const SizedBox(width: 10),
                const Text(
                  '예약불가',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 20),
                Container(width: 20, height: 20, color: Colors.blue),
                const SizedBox(width: 10),
                const Text(
                  '예약 가능',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Center(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: equipmentNames.length,
          itemBuilder: (context, index) {
            final fullName = equipmentNames[index];
            final displayName = fullName.split('(')[0];
            final firebaseName = fullName.split('(')[1].replaceAll(')', '');

            return FutureBuilder<bool>(
              future: StatusController(ReservationService()).isEquipmentAvailable(firebaseName),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final isAvailable = snapshot.data ?? false;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            displayName,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Image.asset(
                          'assets/equipment_$index.png',
                          width: 100,
                          height: 80,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 100,
                              height: 80,
                              color: Colors.grey,
                              child: const Icon(Icons.broken_image, color: Colors.white, size: 40),
                            );
                          },
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 24,
                          height: 24,
                          color: isAvailable ? Colors.blue : Colors.red,
                        ),
                      ],
                    ),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}
