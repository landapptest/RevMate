import 'package:flutter/material.dart';
import 'package:RevMate/controllers/available_times_controller.dart';
import 'package:RevMate/models/reservation_service.dart';

class AvailableTimesPage extends StatefulWidget {
  final String equipment;
  final int duration;

  const AvailableTimesPage({required this.equipment, required this.duration});

  @override
  _AvailableTimesPageState createState() => _AvailableTimesPageState();
}

class _AvailableTimesPageState extends State<AvailableTimesPage> {
  late AvailableTimesController _controller;
  List<String> availableTimes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AvailableTimesController(ReservationService());
    fetchTimes();
  }

  Future<void> fetchTimes() async {
    List<String> times = await _controller.fetchAvailableTimes(widget.equipment, widget.duration);
    setState(() {
      availableTimes = times;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('예약 가능한 시간 선택'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: availableTimes.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(availableTimes[index]),
            onTap: () {
              // 예약 시간 선택 로직
            },
          );
        },
      ),
    );
  }
}
