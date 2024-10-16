import 'package:RevMate/models/reservation_service.dart';
import 'dart:io';

class ReserveController {
  final ReservationService _reservationService;

  ReserveController(this._reservationService);

  List<String> get equipmentList => [
    '싱글플러스_04',
    '싱글플러스_05',
    '싱글플러스_06',
    '싱글플러스_07',
    '스타일_01',
    '스타일_02',
    '스타일_03',
    '엔더5_01',
    '엔더5_02',
    '신도리코_01',
    '신도리코_02',
    '신도리코_03',
    '신도리코_04',
    '레이저커터12*9',
    '레이저커터9*6',
  ];


  // 예약 처리 로직
  Future<void> reserveTime(String equipment, String date, List<String> times) async {
    try {
      await _reservationService.reserveTimes(equipment, date, times);
    } catch (e) {
      throw Exception('예약에 실패했습니다: $e');
    }
  }

  // 예약 취소 처리 로직
  Future<void> cancelReservation(String equipment, String date, List<String> times) async {
    try {
      await _reservationService.cancelReservation(equipment, date, times);
    } catch (e) {
      throw Exception('예약 취소에 실패했습니다: $e');
    }
  }

  // OCR 처리 요청
  Future<String?> runOCR(String imagePath) async {
    return await _reservationService.runOCR(imagePath);
  }

  // 이미지 처리 요청
  Future<File?> processImage(File imageFile) async {
    return await _reservationService.processImage(imageFile);
  }

  // 다중 예약 취소 처리 로직
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
