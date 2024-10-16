import 'package:RevMate/models/reservation_service.dart';

class AvailableTimesController {
  final ReservationService _reservationService;

  AvailableTimesController(this._reservationService);

  Future<List<String>> fetchAvailableTimes(String equipment, int duration) async {
    DateTime currentDate = DateTime.now();
    List<String> foundTimes = [];

    while (foundTimes.length < 3) {
      String dateString = _formatDate(currentDate);
      Map<String, bool> reservedTimes = await _reservationService.fetchReservedTimes(equipment, dateString);

      List<String> possibleTimes = _getPossibleTimes(currentDate, reservedTimes, duration);
      if (possibleTimes.isNotEmpty) {
        foundTimes.addAll(possibleTimes.take(3 - foundTimes.length));
      }

      currentDate = currentDate.add(Duration(days: 1));  // 다음 날로 이동
    }

    return foundTimes;
  }

  // 필요한 유틸리티 함수들
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
