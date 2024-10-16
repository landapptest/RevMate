import 'package:flutter/material.dart';
import 'package:RevMate/controllers/status_controller.dart';
import 'package:RevMate/models/reservation_service.dart';

class StatusPage extends StatelessWidget {
  final List<String> equipmentNames = [
    '싱글플러스_04(S4)', '싱글플러스_05(S5)', '스타일_01(cubstyle01)', // ... 추가
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('실시간 현황'),
      ),
      body: ListView.builder(
        itemCount: equipmentNames.length,
        itemBuilder: (context, index) {
          final name = equipmentNames[index];
          final displayName = name.split('(')[0];
          final firebaseName = name.split('(')[1].replaceAll(')', '');

          return FutureBuilder<bool>(
            future: StatusController(ReservationService()).isEquipmentAvailable(firebaseName),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Text('Error');
              } else {
                final isAvailable = snapshot.data ?? false;
                return ListTile(
                  title: Text(displayName),
                  trailing: Icon(
                    isAvailable ? Icons.check_circle : Icons.cancel,
                    color: isAvailable ? Colors.green : Colors.red,
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
