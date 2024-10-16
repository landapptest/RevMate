import 'package:flutter/material.dart';
import 'calendarwidget.dart';
import 'mainpage.dart';
import 'styles.dart';
import 'reservation_service.dart';

class RevisedPage extends StatefulWidget {
  final String? equipment;

  const RevisedPage({super.key, this.equipment});

  @override
  _RevisedPageState createState() => _RevisedPageState();
}

class _RevisedPageState extends State<RevisedPage> {
  late DateTime _selectedDate;
  int? selectedDay;
  List<String> selectedTimes = [];
  Map<String, bool> reservedTimes = {};
  final ReservationService _reservationService = ReservationService();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    fetchReservedTimes();
  }

  void updateSelectedDay(DateTime newDate, int day) {
    setState(() {
      _selectedDate = newDate;
      selectedDay = day;
      fetchReservedTimes();
    });
  }

  void fetchReservedTimes() async {
    if (selectedDay == null) return;
    String reservationDate = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${selectedDay.toString().padLeft(2, '0')}";
    reservedTimes = await _reservationService.fetchReservedTimes(widget.equipment!, reservationDate);
    setState(() {});
  }

  void toggleTime(String time) {
    if(reservedTimes[time] == true) return;
    setState(() {
      if (selectedTimes.contains(time)) {
        selectedTimes.remove(time);
      } else {
        selectedTimes.add(time);
        selectedTimes.sort(); // 시간 순서대로 정렬
      }
    });
  }

  void reserve() {
    if (selectedDay != null && selectedTimes.isNotEmpty) {
      String reservationDate = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${selectedDay.toString().padLeft(2, '0')}";
      _reservationService.reserveTimes(widget.equipment!, reservationDate, selectedTimes).then((_) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('알림'),
              content: const Text('예약되었습니다.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const MainPage()),
                          (Route<dynamic> route) => false,
                    );
                  },
                  child: const Text('확인'),
                ),
              ],
            );
          },
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('예약 실패: $error')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('날짜와 시간을 선택해주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('자율'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              CalendarWidget(
                selectedDate: _selectedDate,
                selectedDay: selectedDay,
                onDaySelected: updateSelectedDay,
              ),
              const SizedBox(height: 20.0),
              Text(
                '선택된 날짜: ${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${selectedDay?.toString().padLeft(2, '0') ?? ''}',
                style: const TextStyle(fontSize: 18.0),
              ),
              const SizedBox(height: 20.0),
              const Text(
                '시간 선택:',
                style: TextStyle(fontSize: 18.0),
              ),
              const SizedBox(height: 10.0),
              TimeSelectWidget(
                selectedTimes: selectedTimes,
                reservedTimes: reservedTimes,
                toggleTime: toggleTime,
                selectedDate: DateTime(_selectedDate.year, _selectedDate.month, selectedDay ?? _selectedDate.day),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: reserve,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  child: Text(
                    '예약',
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
    final startTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, int.parse(timeParts[0]), int.parse(timeParts[1]));
    final isPast = selectedDate.isBefore(DateTime(now.year, now.month, now.day)) || (selectedDate.isAtSameMomentAs(DateTime(now.year, now.month, now.day)) && startTime.isBefore(now));

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
