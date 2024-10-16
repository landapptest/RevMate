import 'package:flutter/material.dart';
import 'package:RevMate/views/widgets/equipment_list_item.dart';
import 'package:RevMate/models/reservation_service.dart';
import 'package:RevMate/controllers/status_controller.dart';

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
      ),
      body: ListView.builder(
        itemCount: equipmentNames.length,
        itemBuilder: (context, index) {
          final fullName = equipmentNames[index];
          final displayName = fullName.split('(')[0];
          final firebaseName = fullName.split('(')[1].replaceAll(')', '');

          return FutureBuilder<bool>(
            future: StatusController(ReservationService()).isEquipmentAvailable(firebaseName),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                final isAvailable = snapshot.data ?? false;
                return EquipmentListItem(
                  name: displayName,
                  isAvailable: isAvailable,
                );
              }
            },
          );
        },
      ),
    );
  }
}