import 'package:flutter/material.dart';
import 'reservation_service.dart';

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
        title: const Text('실시간 현황'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  color: Colors.red,
                ),
                const SizedBox(width: 10),
                const Text(
                  '예약불가',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 20),
                Container(
                  width: 20,
                  height: 20,
                  color: Colors.blue,
                ),
                const SizedBox(width: 10),
                const Text(
                  '예약 가능',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              EquipmentList(equipmentNames: equipmentNames),
            ],
          ),
        ),
      ),
    );
  }
}

class EquipmentList extends StatelessWidget {
  final List<String> equipmentNames;

  const EquipmentList({required this.equipmentNames});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: equipmentNames.length,
      itemBuilder: (BuildContext context, int index) {
        final fullName = equipmentNames[index];
        final displayName = fullName.split('(')[0];
        final firebaseName = fullName.split('(')[1].replaceAll(')', '');

        return FutureBuilder<bool>(
          future: getEquipmentStatus(firebaseName),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final isAvailable = snapshot.data ?? true;
              return EquipmentListItem(
                name: displayName,
                isAvailable: isAvailable,
                index: index + 1,
              );
            }
          },
        );
      },
    );
  }

  Future<bool> getEquipmentStatus(String name) async {
    try {
      // 현재 날짜 가져오기
      final now = DateTime.now();
      final today = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      // ReservationService 인스턴스를 통해 장비 예약 상태 조회
      ReservationService reservationService = ReservationService();

      // 예약된 시간을 조회 (isRequest는 false로 설정해 승인된 예약만 조회)
      final reservedTimes = await reservationService.fetchReservedTimes(name, today, isRequest: false);

      bool isAvailable = true;

      // 예약된 시간이 있는지 확인
      if (reservedTimes.isNotEmpty) {
        for (var timeRange in reservedTimes.keys) {
          // 시간 범위 안에 현재 시간이 있는지 확인
          if (isTimeInRange(timeRange, now)) {
            isAvailable = false;
            break;
          }
        }
      }

      return isAvailable;
    } catch (e) {
      print('Error fetching equipment status: $e');
      return false;
    }
  }


  bool isTimeInRange(String timeRange, DateTime now) {
    try {
      final times = timeRange.split(' - ');
      final startTime = DateTime(now.year, now.month, now.day, int.parse(times[0].split(':')[0]), int.parse(times[0].split(':')[1]));
      final endTime = DateTime(now.year, now.month, now.day, int.parse(times[1].split(':')[0]), int.parse(times[1].split(':')[1]));

      final isInRange = now.isAfter(startTime) && now.isBefore(endTime);
      print('Debug: now: $now, startTime: $startTime, endTime: $endTime, isInRange: $isInRange');

      return isInRange;
    } catch (e) {
      print('Error parsing time range: $e');
      return false;
    }
  }
}

class EquipmentListItem extends StatelessWidget {
  final String name;
  final bool isAvailable;
  final int index;

  const EquipmentListItem({required this.name, required this.isAvailable, required this.index});

  @override
  Widget build(BuildContext context) {
    final boxColor = isAvailable ? Colors.blue : Colors.red;
    final imagePath = 'assets/equipment_$index.png';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: Row(
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Image.asset(
            imagePath,
            width: 120,
            height: 80,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 120,
                height: 80,
                color: Colors.grey,
                child: const Icon(Icons.broken_image, color: Colors.white, size: 50),
              );
            },
          ),
          const SizedBox(width: 20),
          Container(
            width: 30,
            height: 30,
            color: boxColor,
          ),
        ],
      ),
    );
  }
}
