import 'package:flutter/material.dart';

class CalendarWidget extends StatefulWidget {
  final DateTime selectedDate;
  final int? selectedDay;
  final Function(DateTime, int) onDaySelected; // UI용 콜백
  final Function(DateTime) onDateSelected; // 예약 로직용 콜백

  const CalendarWidget({
    super.key,
    required this.selectedDate,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onDateSelected, // 새로운 콜백 추가
  });

  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late DateTime displayedDate;
  int? _selectedDay; // 현재 선택된 일자

  @override
  void initState() {
    super.initState();
    displayedDate = widget.selectedDate;
    _selectedDay = widget.selectedDay;
  }

  void _goToPreviousMonth() {
    setState(() {
      displayedDate = DateTime(displayedDate.year, displayedDate.month - 1);
      widget.onDaySelected(displayedDate, -1); // 선택된 날짜 초기화
    });
  }

  void _goToNextMonth() {
    setState(() {
      displayedDate = DateTime(displayedDate.year, displayedDate.month + 1);
      widget.onDaySelected(displayedDate, -1); // 선택된 날짜 초기화
    });
  }

  Widget _buildDate(int day) {
    final date = DateTime(displayedDate.year, displayedDate.month, day);
    final isSelected = _selectedDay == day &&
        date.month == widget.selectedDate.month &&
        date.year == widget.selectedDate.year;
    final isCurrentMonth = date.month == displayedDate.month;
    final now = DateTime.now();
    final isPast = date.isBefore(DateTime(now.year, now.month, now.day));

    Color textColor = isCurrentMonth ? Colors.black : Colors.grey;
    if (isPast && !date.isAtSameMomentAs(DateTime(now.year, now.month, now.day))) {
      textColor = Colors.grey;
    }

    return GestureDetector(
      onTap: () {
        if (!isPast || date.isAtSameMomentAs(DateTime(now.year, now.month, now.day))) {
          setState(() {
            _selectedDay = day; // 사용자가 선택한 일자를 저장
          });
          widget.onDaySelected(displayedDate, day); // 날짜와 일자를 함께 반환
          widget.onDateSelected(date); // 선택된 날짜를 예약 로직에 전달
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          color: isSelected ? Colors.blueAccent : Colors.transparent, // 선택된 날짜의 배경색 변경
        ),
        alignment: Alignment.center,
        child: Text(
          day.toString(),
          style: TextStyle(fontSize: 16.0, color: textColor),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _goToPreviousMonth,
              ),
              Text(
                '${displayedDate.month}월, ${displayedDate.year}',
                style: const TextStyle(fontSize: 18.0),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: _goToNextMonth,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10.0),
        GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
          ),
          itemCount: DateTime(displayedDate.year, displayedDate.month + 1, 0).day,
          itemBuilder: (BuildContext context, int index) {
            final day = index + 1;
            return _buildDate(day);
          },
        ),
      ],
    );
  }
}
