import 'package:flutter/material.dart';
import 'package:RevMate/views/reservation/calendar_widget.dart';
import 'package:RevMate/controllers/reserve_controller.dart';
import 'package:RevMate/models/reservation_service.dart';
import 'package:RevMate/route.dart';

class DeadlineWidget extends StatefulWidget {
  final String equipment;
  final String ocrText;

  const DeadlineWidget(
      {Key? key, required this.equipment, required this.ocrText})
      : super(key: key);

  @override
  _DeadlineWidgetState createState() => _DeadlineWidgetState();
}

class _DeadlineWidgetState extends State<DeadlineWidget> {
  DateTime selectedDate = DateTime.now();
  final ReserveController _reserveController =
      ReserveController(ReservationService());

  void _handleDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
    });
  }

  void _confirmReservation() {
    if (widget.equipment.isNotEmpty && widget.ocrText.isNotEmpty) {
      String date =
          "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
      int duration = int.parse(widget.ocrText.split(':')[0]);
      String startTime = formatTime(9);
      String endTime = formatTime(9 + duration);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('예약 완료'),
            content: const Text('예약이 완료되었습니다. 메인 페이지로 이동합니다.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.mainPage,
                    (Route<dynamic> route) => false,
                  );
                },
                child: const Text('확인'),
              ),
            ],
          );
        },
      );

      _completeReservation(date, startTime, endTime);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('장비와 OCR 데이터가 필요합니다.')),
      );
    }
  }

  void _completeReservation(String date, String startTime, String endTime) {
    try {
      _reserveController
          .reserveTime(widget.equipment, date, ["$startTime - $endTime"]);
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
            child: const Text('예약'),
          ),
        ],
      ),
    );
  }
}
