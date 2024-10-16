import 'package:flutter/material.dart';
import 'package:RevMate/views/calendar_widget.dart';
import 'package:RevMate/controllers/reserve_controller.dart';
import 'package:RevMate/models/reservation_service.dart';

class DeadlineWidget extends StatefulWidget {
  final String equipment;

  const DeadlineWidget({Key? key, required this.equipment}) : super(key: key);

  @override
  _DeadlineWidgetState createState() => _DeadlineWidgetState();
}

class _DeadlineWidgetState extends State<DeadlineWidget> {
  DateTime selectedDate = DateTime.now();
  final ReserveController _reserveController = ReserveController(ReservationService());

  void _handleDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
    });
  }

  void _confirmReservation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('예약 확인'),
        content: Text('선택한 날짜로 예약을 진행하시겠습니까?\n날짜: $selectedDate'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              _reserveController.reserveTime(widget.equipment, selectedDate.toString(), ['09:00 - 10:00']); // 가정된 시간
              Navigator.of(context).pop();
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('마감일 선택')),
      body: Column(
        children: [
          CalendarWidget(
            selectedDate: selectedDate,
            onDateSelected: _handleDateSelected,
          ),
          ElevatedButton(
            onPressed: _confirmReservation,
            child: const Text('예약하기'),
          ),
        ],
      ),
    );
  }
}
