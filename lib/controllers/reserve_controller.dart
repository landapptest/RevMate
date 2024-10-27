import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:RevMate/models/reservation_service.dart';

class ReserveController {
  final ReservationService _reservationService;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
      String uid = FirebaseAuth.instance.currentUser!.uid;
      for (var timeSlot in times) {
        await _reservationService.deleteUserReservationRequest(uid, date, equipment, timeSlot);
      }
    } catch (e) {
      throw Exception('예약 취소에 실패했습니다: $e');
    }
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

  // OCR 처리 요청
  Future<String?> runOCR(String imagePath) async {
    return await _reservationService.runOCR(imagePath);
  }

  // 이미지 처리 요청
  Future<File?> processImage(File imageFile) async {
    return await _reservationService.processImage(imageFile);
  }

  // Firebase Storage에 이미지 업로드
  Future<void> uploadImage(File imageFile) async {
    try {
      // 로그인된 사용자의 uid 가져오기
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('로그인된 사용자가 없습니다.');
      }

      // 기존 업로드된 파일 수에 따라 파일 명 결정
      String uid = user.uid;
      ListResult result = await _storage.ref('images/$uid').listAll();
      int uploadCount = result.items.length + 1; // 이전 파일 개수 + 1

      // 파일 이름을 uid_1, uid_2 형식으로 설정
      String fileName = 'reservation_request/$uid/${uid}_$uploadCount.jpg';

      // 파일 업로드
      await _storage.ref(fileName).putFile(imageFile);
      print("이미지 업로드 성공: $fileName");
    } catch (e) {
      throw Exception('이미지 업로드 실패: $e');
    }
  }
}
