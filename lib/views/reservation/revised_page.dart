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
      _reserveController.reserveTime(widget.equipment, selectedDate.toString(), selectedTimes);
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
            onDateSelected: _handleDateSelected,
          ),
          TimeSelectWidget(
            selectedTimes: selectedTimes,
            toggleTime: _toggleTime,
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
