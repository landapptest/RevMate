import 'package:RevMate/models/reservation_service.dart';

class AvailableTimesController {
  final ReservationService _reservationService;

  AvailableTimesController(this._reservationService);

  Future<List<String>> fetchAvailableTimes(String equipment, int duration) async {
    DateTime currentDate = DateTime.now();
    List<String> foundTimes = [];

    while (foundTimes.length < 3) {
      String dateString = _formatDate(currentDate);
      Map<String, bool> reservedTimes = await _reservationService.fetchReservedTimes(equipment, dateString, isRequest: true);

      List<String> possibleTimes = _getPossibleTimes(currentDate, reservedTimes, duration);
      if (possibleTimes.isNotEmpty) {
        foundTimes.addAll(possibleTimes.take(3 - foundTimes.length));
      }

      currentDate = currentDate.add(Duration(days: 1));
    }

    return foundTimes;
  }

  Future<void> reserveTimes(String equipment, String selectedTime, int duration) async {
    final DateTime now = DateTime.now();
    final String date = _formatDate(now);

    List<String> times = List.generate(duration, (index) {
      int startHour = int.parse(selectedTime.split(':')[0]) + index;
      return "${startHour.toString().padLeft(2, '0')}:00 - ${(startHour + 1).toString().padLeft(2, '0')}:00";
    });

    await _reservationService.reserveTimes(equipment, date, times, isRequest: true);
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  List<String> _getPossibleTimes(DateTime currentDate, Map<String, bool> reservedTimes, int duration) {
    List<String> possibleTimes = [];
    int startHour = currentDate.hour;

    for (int i = startHour; i <= 21; i++) {
      bool isAvailable = true;
      for (int j = 0; j < duration; j++) {
        int hourSlot = i + j;
        String timeSlot = _formatTimeSlot(hourSlot);

        if (reservedTimes[timeSlot] == true) {
          isAvailable = false;
          break;
        }
      }

      if (isAvailable) {
        String startTime = "$i:00";
        String endTime = "${i + duration}:00";
        possibleTimes.add("$startTime - $endTime");
      }
    }

    return possibleTimes;
  }

  String _formatTimeSlot(int hour) {
    return "${hour.toString().padLeft(2, '0')}:00 - ${(hour + 1).toString().padLeft(2, '0')}:00";
  }
}
