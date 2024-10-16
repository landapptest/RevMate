import 'package:flutter/material.dart';
import 'package:RevMate/controllers/calendar_controller.dart';

class CalendarWidget extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const CalendarWidget({Key? key, required this.selectedDate, required this.onDateSelected}) : super(key: key);

  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late CalendarController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CalendarController(widget.selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                setState(() {
                  _controller.goToPreviousMonth();
                });
              },
            ),
            Text("${_controller.displayedDate.month}월 ${_controller.displayedDate.year}"),
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () {
                setState(() {
                  _controller.goToNextMonth();
                });
              },
            ),
          ],
        ),
        // 날짜 선택 UI
        GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
          itemBuilder: (context, index) {
            final day = index + 1;
            return GestureDetector(
              onTap: () {
                widget.onDateSelected(DateTime(_controller.displayedDate.year, _controller.displayedDate.month, day));
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
