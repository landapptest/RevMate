import 'package:flutter/material.dart';
import 'package:RevMate/views/reservation/calendar_widget.dart';
import 'package:RevMate/controllers/reserve_controller.dart';
import 'package:RevMate/models/reservation_service.dart';

class DeadlineWidget extends StatefulWidget {
  final String equipment;
  final String ocrText; // ocrText 추가

  const DeadlineWidget({
    Key? key,
    required this.equipment,
    required this.ocrText, // ocrText 추가
  }) : super(key: key);

  @override
  _DeadlineWidgetState createState() => _DeadlineWidgetState();
}

class _DeadlineWidgetState extends State<DeadlineWidget> {
  DateTime selectedDate = DateTime.now();
  final ReserveController _reserveController = ReserveController(ReservationService());

  @override
  void initState() {
    super.initState();
    print("DeadlineWidget initialized with equipment: ${widget.equipment}, OCR: ${widget.ocrText}");
  }

  void _handleDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
      print("Selected date updated: $selectedDate");
    });
  }

  void _confirmReservation() {
    try {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('예약 확인'),
            content: Text('선택한 날짜로 예약을 진행하시겠습니까?\n날짜: $selectedDate\n예상 시간: ${widget.ocrText}시간'), // ocrText 포함
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  try {
                    int duration = int.parse(widget.ocrText.split(':')[0]);
                    List<String> times = List.generate(
                      duration,
                          (index) => '${9 + index}:00 - ${10 + index}:00', // 시간 계산 로직
                    );
                    print("Reserving times: $times on $selectedDate");
                    _reserveController.reserveTime(widget.equipment, selectedDate.toString(), times);
                    Navigator.of(context).pop();
                    print("Reservation confirmed successfully");
                  } catch (e) {
                    print("Error while confirming reservation: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('예약 중 오류가 발생했습니다: $e')),
                    );
                  }
                },
                child: const Text('확인'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print("Error displaying reservation dialog: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('예약 확인 중 오류가 발생했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('마감일 선택')),
      body: Column(
        children: [
          CalendarWidget(
            selectedDate: selectedDate,
            onDateSelected: _handleDateSelected,
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
