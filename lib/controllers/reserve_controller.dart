import 'package:RevMate/models/reservation_service.dart';

class ReserveController {
  final ReservationService _reservationService;

  ReserveController(this._reservationService);

  Future<void> reserveTime(String equipment, String date, List<String> times) async {
    try {
      await _reservationService.reserveTimes(equipment, date, times);
      // 성공 시 처리 로직
    } catch (e) {
      // 오류 처리 로직
      throw Exception('예약에 실패했습니다: $e');
    }
  }

  Future<void> cancelReservation(String equipment, String date, List<String> times) async {
    try {
      await _reservationService.cancelReservation(equipment, date, times);
    } catch (e) {
      throw Exception('예약 취소에 실패했습니다: $e');
    }
  }

  Future<void> cancelReservations(Map<String, Set<String>> selectedReservations) async {
    for (var entry in selectedReservations.entries) {
      final key = entry.key.split('|');
      final date = key[0];
      final equipment = key[1];

      for (var time in entry.value) {
        await cancelReservation(equipment, date, [time]);
      }
    }
  }
}
