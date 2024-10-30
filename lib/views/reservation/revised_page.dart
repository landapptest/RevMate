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

  @override
  void initState() {
    super.initState();
    print("RevisedPage initialized with equipment: ${widget.equipment}");
  }

  void _handleDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
      print("Selected date updated: $selectedDate");
    });
  }

  void _toggleTime(String time) {
    setState(() {
      if (selectedTimes.contains(time)) {
        selectedTimes.remove(time);
      } else {
        selectedTimes.add(time);
      }
      print("Selected times updated: $selectedTimes");
    });
  }

  void _confirmReservation() {
    try {
      if (selectedTimes.isEmpty) {
        throw Exception("No times selected");
      }
      print("Reserving times: $selectedTimes on $selectedDate");
      _reserveController.reserveTime(widget.equipment, selectedDate.toString(), selectedTimes);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('예약이 완료되었습니다.')),
      );
      print("Reservation confirmed successfully");
    } catch (e) {
      print("Error confirming reservation: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('예약 중 오류가 발생했습니다: $e')),
      );
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
