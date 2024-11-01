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
      // 선택된 모든 시간에 대해 예약 요청
      for (String selectedTime in selectedTimes) {
        await _controller.reserveTimes(widget.equipment, selectedTime, widget.duration);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('예약이 완료되었습니다.')),
      );
      Navigator.pop(context); // 예약 완료 후 이전 화면으로 돌아감
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('예약에 실패했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('예약 가능한 시간 선택'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              '원하는 시간을 선택하세요',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 3,
                ),
                itemCount: availableTimes.length,
                itemBuilder: (context, index) {
                  final time = availableTimes[index];
                  final isSelected = selectedTimes.contains(time);
                  return GestureDetector(
                    onTap: () => toggleTimeSelection(time),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blueAccent : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Colors.blueAccent : Colors.grey,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                            ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          time,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
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
          child: const Text('예약 요청', style: TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}
