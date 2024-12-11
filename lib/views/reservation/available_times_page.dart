import 'package:flutter/material.dart';
import 'package:RevMate/controllers/available_times_controller.dart';
import 'package:RevMate/models/reservation_service.dart';
import 'package:RevMate/route.dart';

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
  List<String> selectedTimes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AvailableTimesController(ReservationService());
    fetchTimes();
  }

  Future<void> fetchTimes() async {
    try {
      List<String> times = await _controller.fetchAvailableTimes(widget.equipment, widget.duration);
      setState(() {
        availableTimes = times;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('시간을 가져오는 중 오류가 발생했습니다: $e')),
      );
    }
  }

  void toggleTimeSelection(String time) {
    setState(() {
      if (selectedTimes.contains(time)) {
        selectedTimes.remove(time);
      } else {
        selectedTimes.add(time);
      }
    });
  }

  Future<void> reserveSelectedTimes() async {
    if (selectedTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('예약할 시간을 선택해주세요.')),
      );
      return;
    }

    try {
      for (String selectedTime in selectedTimes) {
        await _controller.reserveTimes(widget.equipment, selectedTime, widget.duration);
      }
      _showConfirmationDialog();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('예약에 실패했습니다: $e')),
      );
    }
  }

  void _showConfirmationDialog() {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('가장 빠른 일자'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              '2024-11-03', // 날짜 텍스트로 변경
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: availableTimes.length,
                itemBuilder: (context, index) {
                  final time = availableTimes[index];
                  return ListTile(
                    title: Text(time),
                    trailing: Checkbox(
                      value: selectedTimes.contains(time),
                      onChanged: (bool? value) {
                        toggleTimeSelection(time);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: reserveSelectedTimes,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('예약', style: TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}
