import 'package:flutter/material.dart';

class TimeSelectWidget extends StatelessWidget {
  final List<String> selectedTimes;
  final Map<String, bool> reservedTimes;
  final Function(String) toggleTime;
  final DateTime selectedDate;

  const TimeSelectWidget({
    super.key,
    required this.selectedTimes,
    required this.reservedTimes,
    required this.toggleTime,
    required this.selectedDate,
  });

  Widget _buildTime(String time) {
    final isSelected = selectedTimes.contains(time);
    final isReserved = reservedTimes.containsKey(time) && reservedTimes[time] == true;
    final now = DateTime.now();
    final timeParts = time.split(' - ')[0].split(':');
    final startTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day,
        int.parse(timeParts[0]), int.parse(timeParts[1]));
    final isPast = selectedDate.isBefore(DateTime(now.year, now.month, now.day)) ||
        (selectedDate.isAtSameMomentAs(DateTime(now.year, now.month, now.day)) && startTime.isBefore(now));

    return GestureDetector(
      onTap: () {
        if (!isReserved && !isPast) {
          toggleTime(time);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          color: isSelected ? Colors.green : (isReserved || isPast) ? Colors.grey : Colors.transparent,
        ),
        child: Text(
          time,
          style: TextStyle(fontSize: 16.0, color: isReserved || isPast ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: [
        _buildTime('09:00 - 10:00'),
        _buildTime('10:00 - 11:00'),
        _buildTime('11:00 - 12:00'),
        _buildTime('12:00 - 13:00'),
        _buildTime('13:00 - 14:00'),
        _buildTime('14:00 - 15:00'),
        _buildTime('15:00 - 16:00'),
        _buildTime('16:00 - 17:00'),
        _buildTime('17:00 - 18:00'),
        _buildTime('18:00 - 19:00'),
        _buildTime('19:00 - 20:00'),
        _buildTime('20:00 - 21:00'),
      ],
    );
  }
}
