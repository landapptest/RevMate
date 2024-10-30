import 'package:flutter/material.dart';
import 'package:RevMate/views/reservation/calendar_widget.dart';
import 'package:RevMate/controllers/reserve_controller.dart';
import 'package:RevMate/models/reservation_service.dart';
import 'package:RevMate/views/widgets/time_select_widget.dart';

class RevisedPage extends StatefulWidget {
  final String equipment;

  const RevisedPage({Key? key, required this.equipment}) : super(key: key);

  @override
  _RevisedPageState createState() => _RevisedPageState();
}

class _RevisedPageState extends State<RevisedPage> {
  DateTime selectedDate = DateTime.now();
  List<String> selectedTimes = [];
  final ReserveController _reserveController = ReserveController(ReservationService());

  void _handleDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
    });
  }

  void _toggleTime(String time) {
    setState(() {
      if (selectedTimes.contains(time)) {
        selectedTimes.remove(time);
      } else {
        selectedTimes.add(time);
      }
    });
  }

  void _confirmReservation() {
    if (selectedTimes.isNotEmpty) {
      try {
        String date = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

        // 예약할 시간을 고정된 형식으로 설정
        List<String> formattedTimes = selectedTimes.map((time) {
          final startHour = int.parse(time.split(':')[0]);
          final endHour = startHour + 1;
          return "${startHour.toString().padLeft(2, '0')}:00 - ${endHour.toString().padLeft(2, '0')}:00";
        }).toList();

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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('예약할 시간을 선택해주세요.')),);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('자율 예약')),
      body: Column(
        children: [
          CalendarWidget(
            selectedDate: selectedDate,
            onDateSelected: _handleDateSelected, selectedDay: null, onDaySelected: (DateTime , int ) {  },
          ),
          const Padding(padding: EdgeInsets.all(16.0),),
          TimeSelectWidget(
            selectedTimes: selectedTimes,
            toggleTime: _toggleTime, reservedTimes: {},
            selectedDate: selectedDate,
          ),
          const Padding(padding: EdgeInsets.all(16.0),),
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
