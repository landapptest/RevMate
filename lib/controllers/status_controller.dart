import 'package:RevMate/models/reservation_service.dart';

class StatusController {
  final ReservationService _reservationService;

  StatusController(this._reservationService);

  Future<bool> isEquipmentAvailable(String equipment) async {
    try {
      DateTime now = DateTime.now();
      String today = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      Map<String, bool> reservedTimes = await _reservationService.fetchReservedTimes(equipment, today, isRequest: false);

      bool isAvailable = true;
      for (var timeRange in reservedTimes.keys) {
        if (_isTimeInRange(timeRange, now)) {
          isAvailable = false;
          break;
        }
      }
      return isAvailable;
    } catch (e) {
      print('Error fetching equipment status: $e');
      return false;
    }
  }

  bool _isTimeInRange(String timeRange, DateTime now) {
    try {
      final times = timeRange.split(' - ');
      final startTime = DateTime(now.year, now.month, now.day, int.parse(times[0].split(':')[0]), int.parse(times[0].split(':')[1]));
      final endTime = DateTime(now.year, now.month, now.day, int.parse(times[1].split(':')[0]), int.parse(times[1].split(':')[1]));

      return now.isAfter(startTime) && now.isBefore(endTime);
    } catch (e) {
      print('Error parsing time range: $e');
      return false;
    }
  }
}
