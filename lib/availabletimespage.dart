import 'package:flutter/material.dart';
import 'reservation_service.dart';

class AvailableTimesPage extends StatefulWidget {
  final String equipment;
  final int duration;

  const AvailableTimesPage(
      {Key? key, required this.equipment, required this.duration})
      : super(key: key);

  @override
  _AvailableTimesPageState createState() => _AvailableTimesPageState();
}

class _AvailableTimesPageState extends State<AvailableTimesPage> {
  final ReservationService _reservationService = ReservationService();
  List<String> availableTimes = [];
  bool isLoading = true;
  String? selectedTime;
  List<String> debugLogs = [];

  @override
  void initState() {
    super.initState();
    fetchAvailableTimes();
  }

  void addDebugLog(String message) {
    setState(() {
      debugLogs.add(message);
    });
  }

  Future<void> fetchAvailableTimes() async {
    addDebugLog('Debug: fetchAvailableTimes called');
    DateTime currentDate = DateTime.now();
    List<String> foundTimes = [];

    while (foundTimes.length < 3) {
      String dateString = _formatDate(currentDate);
      addDebugLog('Debug: Checking date $dateString');

      // reservation_requests에서 예약된 시간을 조회
      Map<String, bool> reservedTimes = await _reservationService
          .fetchReservedTimes(widget.equipment, dateString, isRequest: true);
      addDebugLog('Debug: Reserved times for $dateString - $reservedTimes');

      List<String> possibleTimes = _getPossibleTimes(currentDate, reservedTimes);

      if (possibleTimes.isNotEmpty) {
        foundTimes.addAll(possibleTimes.take(3 - foundTimes.length));
      }

      // 다음 날로 이동
      currentDate = currentDate.add(Duration(days: 1));
    }

    setState(() {
      availableTimes = foundTimes;
      isLoading = false;
    });
    addDebugLog('Debug: availableTimes - $availableTimes');
  }

  List<String> _getPossibleTimes(DateTime currentDate, Map<String, bool> reservedTimes) {
    List<String> possibleTimes = [];
    int startHour = currentDate.isSameDate(DateTime.now()) ? currentDate.hour : 9;

    for (int i = startHour; i <= 21; i++) {
      bool isAvailable = true;
      List<String> timeSlots = [];

      for (int j = 0; j < widget.duration; j++) {
        int hourSlot = i + j;
        String timeSlot = _formatTimeSlot(hourSlot);

        // 예약된 시간이 포함되어 있는지 확인
        if (reservedTimes.isNotEmpty && reservedTimes[timeSlot] == true) {
          isAvailable = false;
          break;
        }
        timeSlots.add(timeSlot);
      }

      if (isAvailable) {
        String startTime = "${i.toString().padLeft(2, '0')}:00";
        String endTime = _formatEndTime(i + widget.duration);

        possibleTimes.add("${_formatDate(currentDate)} $startTime - $endTime");

        // 만약 종료 시간이 21시를 넘어서면 다음날 오전 9시부터 남은 시간을 포함
        if (endTime == "00:00") {
          DateTime nextDay = currentDate.add(Duration(days: 1));
          String nextDayString = _formatDate(nextDay);
          possibleTimes.add("$nextDayString 09:00 - ${_formatEndTime(9 + (i + widget.duration) % 24)}");
        }
      }
    }

    return possibleTimes;
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  String _formatTimeSlot(int hour) {
    return "${hour.toString().padLeft(2, '0')}:00 - ${(hour + 1).toString().padLeft(2, '0')}:00";
  }

  String _formatEndTime(int endHour) {
    return (endHour > 21)
        ? "${(endHour % 24).toString().padLeft(2, '0')}:00"
        : "${endHour.toString().padLeft(2, '0')}:00";
  }


  void reserveTime(String dateTime) async {
    String date = dateTime.split(' ')[0];
    String startTime = dateTime.split(' ')[1].split(' - ')[0];
    List<String> times = List.generate(widget.duration, (index) {
      int hour = int.parse(startTime.split(':')[0]) + index;
      return "${(hour % 24).toString().padLeft(2, '0')}:00 - ${(hour + 1) % 24}:00";
    });

    try {
      await _reservationService.reserveTimes(widget.equipment, date, times, isRequest: true);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('예약 요청이 완료되었습니다: $dateTime')));
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('예약 요청에 실패했습니다: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('예약 가능한 시간 선택'),
      ),
      body: isLoading
          ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Center(child: CircularProgressIndicator()),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: debugLogs.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 2.0, horizontal: 10.0),
                  child: Text(debugLogs[index]),
                );
              },
            ),
          ),
        ],
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: availableTimes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(availableTimes[index]),
                  trailing: Checkbox(
                    value: selectedTime == availableTimes[index],
                    onChanged: (bool? value) {
                      setState(() {
                        selectedTime =
                        value == true ? availableTimes[index] : null;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: selectedTime == null
                ? null
                : () => reserveTime(selectedTime!),
            child: const Text('예약 요청'),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: debugLogs.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 2.0, horizontal: 10.0),
                  child: Text(debugLogs[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

extension DateTimeExtension on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
