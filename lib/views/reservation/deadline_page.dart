import 'package:flutter/material.dart';
import 'package:RevMate/views/reservation/calendar_widget.dart';
import 'package:RevMate/controllers/reserve_controller.dart';
import 'package:RevMate/models/reservation_service.dart';

class DeadlineWidget extends StatefulWidget {
  final String equipment;
  final String ocrText; // OCR에서 받아온 시간

  const DeadlineWidget({
    Key? key,
    required this.equipment,
    required this.ocrText,
  }) : super(key: key);

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
    if (widget.equipment.isNotEmpty && widget.ocrText.isNotEmpty) {
      String date = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
      int duration = int.parse(widget.ocrText.split(':')[0]);
      String startTime = formatTime(9); // 시작 시간 예시로 오전 9시 설정
      String endTime = formatTime(9 + duration);

      // 예약 확인 다이얼로그
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('예약 확인'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("날짜: $date"),
                const SizedBox(height: 8),
                Text("시간: $startTime - $endTime"),
                const SizedBox(height: 16),
                const Text('이 시간에 예약하시겠습니까?'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('아니오'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _completeReservation(date, startTime, endTime);
                },
                child: const Text('예'),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('장비와 OCR 데이터가 필요합니다.')),
      );
    }
  }

  void _completeReservation(String date, String startTime, String endTime) {
    try {
      _reserveController.reserveTime(widget.equipment, date, ["$startTime - $endTime"]);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('예약이 완료되었습니다.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('예약에 실패했습니다: $e')),
      );
    }
  }

  String formatTime(int hour) {
    return "${hour.toString().padLeft(2, '0')}:00";
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
            selectedDay: null,
            onDaySelected: (DateTime, int) {},
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _confirmReservation,
            child: const Text('예약하기'),
          ),
        ],
      ),
    );
  }
}
