import 'package:flutter/material.dart';

class TimeSelectWidget extends StatelessWidget {
  final List<String> selectedTimes;
  final Function(String) toggleTime;

  const TimeSelectWidget({
    Key? key,
    required this.selectedTimes,
    required this.toggleTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      children: List.generate(12, (index) {
        final timeSlot = "${9 + index}:00 - ${10 + index}:00";
        final isSelected = selectedTimes.contains(timeSlot);
        return ChoiceChip(
          label: Text(timeSlot),
          selected: isSelected,
          onSelected: (bool selected) {
            toggleTime(timeSlot);
          },
        );
      }),
    );
  }
}
