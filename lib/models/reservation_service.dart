import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:image/image.dart' as img;

class ReservationService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final User? _user = FirebaseAuth.instance.currentUser;

  Future<void> reserveTimes(String equipment, String date, List<String> times) async {
    String uid = _user!.uid;

    for (var timeSlot in times) {
      await _database.child('reservation/$equipment/$date/$timeSlot').set({
        'uid': uid,
        'reserved': true,
      });
    }
  }

  Future<Map<String, bool>> fetchReservedTimes(String equipment, String date) async {
    DataSnapshot snapshot = await _database.child('reservation/$equipment/$date').get();
    Map<String, bool> reservedTimes = {};

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        reservedTimes[key] = value['reserved'] ?? false;
      });
    }

    return reservedTimes;
  }

  Future<void> cancelReservation(String equipment, String date, List<String> times) async {
    String uid = _user!.uid;
    for (var timeSlot in times) {
      await _database.child('reservation/$equipment/$date/$timeSlot').remove();
    }
  }

  Future<Map<String, Map<String, String>>> fetchUserReservations() async {
    String uid = _user!.uid;
    DataSnapshot snapshot = await _database.child('reservation').get();
    Map<String, Map<String, String>> userReservations = {};

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      data.forEach((equipment, dates) {
        if (dates is Map) {
          dates.forEach((date, times) {
            if (times is Map) {
              times.forEach((timeSlot, reservationData) {
                if (reservationData['uid'] == uid) {
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

    return userReservations;
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
          "tessedit_char_whitelist": "0123456789:",
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
