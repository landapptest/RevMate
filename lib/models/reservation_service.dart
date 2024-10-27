import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:image/image.dart' as img;

class ReservationService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final User? _user = FirebaseAuth.instance.currentUser;

  // 장비 경로를 얻는 메서드
  String _getEquipmentPath(String equipment, {bool isRequest = false}) {
    if (equipment.startsWith('S') ||
        equipment.startsWith('ender') ||
        equipment.startsWith('sin') ||
        equipment.startsWith('cubstyle')) {
      return isRequest ? 'reservation_request/3D Printer/$equipment' : 'reservation/3D Printer/$equipment';
    } else if (equipment.startsWith('12*9') || equipment.startsWith('9*6')) {
      return isRequest ? 'reservation_request/laser cutter/$equipment' : 'reservation/laser cutter/$equipment';
    } else {
      throw Exception('Unknown equipment type');
    }
  }

  // 예약 요청 경로 참조
  DatabaseReference getReservationRequestReference(String equipment, String date, String timeSlot) {
    final path = _getEquipmentPath(equipment, isRequest: true);
    return _database.child(path).child(date).child(timeSlot);
  }

  // 승인된 예약 경로 참조
  DatabaseReference getReservationReference(String equipment, String date, String timeSlot) {
    final path = _getEquipmentPath(equipment, isRequest: false);
    return _database.child(path).child(date).child(timeSlot);
  }

  // 예약 요청 메서드
  Future<void> reserveTimes(String equipment, String date, List<String> times, {bool isRequest = true}) async {
    if (times.isEmpty) {
      throw Exception("시간대를 지정해야 합니다.");
    }

    times.sort();
    String startTime = times.first.split(' - ')[0];
    String endTime = times.last.split(' - ')[1];
    String mergedTime = "$startTime - $endTime";

    DatabaseReference reservationRef = isRequest
        ? getReservationRequestReference(equipment, date, mergedTime)
        : getReservationReference(equipment, date, mergedTime);

    await reservationRef.set({
      'uid': _user!.uid,
      'times': times,
    });
  }

  // 승인된 예약된 시간들을 가져오는 메서드
  Future<Map<String, bool>> fetchReservedTimes(String equipment, String date, {bool isRequest = false}) async {
    DatabaseReference dateRef = _database.child(_getEquipmentPath(equipment, isRequest: isRequest)).child(date);
    DataSnapshot snapshot = await dateRef.get();
    Map<String, bool> reservedTimes = {};

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      for (var entry in data.entries) {
        String timeSlot = entry.key;
        reservedTimes[timeSlot] = true;
      }
    }

    return reservedTimes;
  }

  // 유저 예약 데이터 가져오기 (승인된 예약만)
  Future<Map<String, Map<String, String>>> fetchUserReservations() async {
    final String uid = _user!.uid;
    final DataSnapshot snapshot = await _database.child('reservation_request').get();
    final Map<String, Map<String, String>> userReservations = {};

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      data.forEach((equipmentType, equipmentData) {
        if (equipmentData is Map) {
          equipmentData.forEach((equipment, equipmentDetails) {
            if (equipmentDetails is Map) {
              equipmentDetails.forEach((date, timeSlots) {
                if (timeSlots is Map) {
                  timeSlots.forEach((timeSlot, reservationDetails) {
                    if (reservationDetails is Map &&
                        reservationDetails['uid'] == uid) {
                      if (!userReservations.containsKey(date)) {
                        userReservations[date] = {};
                      }
                      userReservations[date]![equipment] = timeSlot;
                    }
                  });
                }
              });
            }
          });
        }
      });
    }

    return userReservations;
  }

  // 예약 요청 삭제 (예약 요청 취소)
  Future<void> deleteUserReservationRequest(String uid, String date, String equipment, String timeSlot) async {
    final DatabaseReference ref = getReservationRequestReference(equipment, date, timeSlot);

    final DataSnapshot snapshot = await ref.get();

    if (snapshot.exists && snapshot.child('uid').value == uid) {
      await ref.remove();
      print("Reservation request deleted for $timeSlot on $date");
    }
  }

  // OCR 처리 로직 추가
  Future<String?> runOCR(String imagePath) async {
    try {
      String text = await FlutterTesseractOcr.extractText(
        imagePath,
        language: 'kor',
        args: {
          "psm": "6",
          "preserve_interword_spaces": "1",
          "tessedit_char_whitelist": "0123456789:;",
          "ocr_engine_mode": "1",
        },
      );
      return text;
    } catch (e) {
      throw Exception('OCR 처리에 실패했습니다: $e');
    }
  }

  // 이미지 처리 로직 추가
  Future<File?> processImage(File imageFile) async {
    try {
      final image = img.decodeImage(imageFile.readAsBytesSync());
      if (image != null) {
        final scaledImage = img.copyResize(image, width: image.width * 2, height: image.height * 2);
        final croppedImage = img.copyCrop(scaledImage, x: 0, y: 1500, width: 690, height: 74);
        final bwImage = img.grayscale(croppedImage);
        img.adjustColor(bwImage, contrast: 1.5);

        final processedFile = File('${imageFile.path}_processed.jpg')..writeAsBytesSync(img.encodeJpg(bwImage));
        return processedFile;
      }
    } catch (e) {
      throw Exception('이미지 처리에 실패했습니다: $e');
    }
    return null;
  }
}
