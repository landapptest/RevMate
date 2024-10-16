import 'package:flutter/material.dart';
import 'reservation_service.dart'; // ReservationService 임포트
import 'calendarwidget.dart'; // 기존 캘린더 위젯 사용

class DeadlineWidget extends StatefulWidget {
  final String selectedEquipment;
  final String ocrText;

  const DeadlineWidget({Key? key, required this.selectedEquipment, required this.ocrText}) : super(key: key);

  @override
  _DeadlineWidgetState createState() => _DeadlineWidgetState();
}

class _DeadlineWidgetState extends State<DeadlineWidget> {
  DateTime _selectedDate = DateTime.now();
  int? _selectedDay;
  final ReservationService _reservationService = ReservationService(); // ReservationService 인스턴스 생성

  void _handleDaySelected(DateTime selectedDate, int selectedDay) {
    setState(() {
      _selectedDate = selectedDate;
      _selectedDay = selectedDay;
    });
  }

  void _confirmReservation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('예약 확인'),
          content: Text('선택한 날짜로 예약 요청을 진행하시겠습니까?\n\n날짜: ${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}'),
          actions: [
            TextButton(
              child: const Text('아니요'),
              onPressed: () {
                Navigator.of(context).pop(); // 경고창 닫기
              },
            ),
            TextButton(
              child: const Text('예'),
              onPressed: () {
                Navigator.of(context).pop(); // 경고창 닫기
                _makeReservation();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _makeReservation() async {
    String dateString = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
    int duration = int.parse(widget.ocrText.split(':')[0]);

    List<String> times = List.generate(duration, (index) {
      int hour = _selectedDate.hour + index;
      return "${hour.toString().padLeft(2, '0')}:00 - ${(hour + 1).toString().padLeft(2, '0')}:00";
    });

    try {
      await _reservationService.reserveTimes(widget.selectedEquipment, dateString, times, isRequest: true);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('예약이 완료되었습니다: $dateString')));
      Navigator.of(context).pop(); // 예약 완료 후 이전 페이지로 돌아가기
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('예약에 실패했습니다: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('마감일 선택'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CalendarWidget(
              selectedDate: _selectedDate,
              selectedDay: _selectedDay,
              onDaySelected: _handleDaySelected,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _confirmReservation,
              child: const Text('확인'),
            ),
          ],
        ),
      ),
    );
  }
}
