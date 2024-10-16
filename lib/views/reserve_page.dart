import 'package:flutter/material.dart';
import 'package:RevMate/controllers/reserve_controller.dart';
import 'package:RevMate/models/reservation_service.dart';


class ReservePage extends StatefulWidget {
  const ReservePage({Key? key}) : super(key: key);

  @override
  _ReservePageState createState() => _ReservePageState();
}

class _ReservePageState extends State<ReservePage> {
  final ReserveController _reserveController = ReserveController(ReservationService());

  // 예약 관련 상태 변수들
  String? selectedEquipment;
  List<String> selectedTimes = [];
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('예약 페이지'),
      ),
      body: Column(
        children: [
          DropdownButton<String>(
            items: <String>['장비 1', '장비 2'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                selectedEquipment = newValue;
              });
            },
            hint: const Text('장비 선택'),
            value: selectedEquipment,
          ),
          // 시간 선택 위젯 및 예약 버튼 추가...
          ElevatedButton(
            onPressed: () {
              if (selectedEquipment != null && selectedTimes.isNotEmpty) {
                _reserveController.reserveTime(selectedEquipment!, "2024-10-16", selectedTimes);
              }
            },
            child: const Text('예약하기'),
          ),
        ],
      ),
    );
  }
}
