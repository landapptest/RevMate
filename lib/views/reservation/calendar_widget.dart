import 'package:flutter/material.dart';

class CalendarWidget extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const CalendarWidget({Key? key, required this.selectedDate, required this.onDateSelected}) : super(key: key);

  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late DateTime displayedDate;

  @override
  void initState() {
    super.initState();
    displayedDate = widget.selectedDate;
  }

  void goToPreviousMonth() {
    setState(() {
      displayedDate = DateTime(displayedDate.year, displayedDate.month - 1);
    });
  }

  void goToNextMonth() {
    setState(() {
      displayedDate = DateTime(displayedDate.year, displayedDate.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: goToPreviousMonth,
            ),
            Text("${displayedDate.month}월 ${displayedDate.year}"),
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: goToNextMonth,
            ),
          ],
        ),
        // 날짜 선택 UI
        GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
          itemCount: DateTime(displayedDate.year, displayedDate.month + 1, 0).day,
          itemBuilder: (context, index) {
            final day = index + 1;
            final date = DateTime(displayedDate.year, displayedDate.month, day);
            return GestureDetector(
              onTap: () {
                widget.onDateSelected(date);
              },
              child: Container(
                alignment: Alignment.center,
                child: Text(day.toString()),
              ),
            );
          },
        ),
      ],
    );
  }
}
