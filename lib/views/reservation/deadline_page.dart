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
    if (widget.equipment != null && widget.ocrText != null) {
      try {
        String date = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

        // OCR로 얻은 예상 시간을 바탕으로 고정된 시간대 생성
        int duration = int.parse(widget.ocrText.split(':')[0]);
        List<String> formattedTimes = List.generate(duration, (index) {
          return formatTimeSlot(
              "${9 + index}", // 예약 시작 시간 예시로 오전 9시부터 시작
              "${9 + index + 1}"
          );
        });

        _reserveController.reserveTime(widget.equipment, date, formattedTimes);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('예약이 완료되었습니다.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('예약에 실패했습니다: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('장비와 OCR 데이터가 필요합니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('마감일 선택')),
      body: Column(
        children: [
          CalendarWidget(
            selectedDate: selectedDate,
            onDateSelected: _handleDateSelected, selectedDay: null, onDaySelected: (DateTime , int ) {  },
          ),
          ElevatedButton(
            onPressed: _confirmReservation,
            child: const Text('예약하기'),
          ),
        ],
      ),
    );
  }

  String formatTimeSlot(String startTime, String endTime) {
    return "${startTime.padLeft(2, '0')}:00 - ${endTime.padLeft(2, '0')}:00";
  }
}
