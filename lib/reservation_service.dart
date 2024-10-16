import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ReservationService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final User? _user = FirebaseAuth.instance.currentUser;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final List<String> _logMessages = [];

  ReservationService() {
    // FCM 토큰 갱신 시, 새 토큰을 저장하는 리스너
    _messaging.onTokenRefresh.listen((newToken) {
      if (_user != null) {
        _database.child('users/${_user!.uid}/token').set(newToken);
        _log('FCM 토큰 갱신됨: $newToken');
      }
    });
  }

  // 로그 메시지 기록
  void _log(String message) {
    _logMessages.add(message);
  }

  // 로그 메시지 가져오기
  List<String> get logMessages => _logMessages;

  // FCM 토큰을 Firebase Realtime Database에 저장하는 메서드
  Future<void> saveFCMToken() async {
    if (_user != null) {
      String? token = await _messaging.getToken();
      if (token != null) {
        DatabaseReference tokenRef = _database.child('users/${_user!.uid}/token');
        await tokenRef.set(token);
        _log('FCM 토큰 저장 완료: $token');
      } else {
        _log('FCM 토큰을 가져오지 못했습니다.');
      }
    } else {
      _log('사용자가 로그인되어 있지 않습니다.');
    }
  }

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
  Future<void> reserveTimes(String equipment, String date, List<String> times, {bool isRequest = false}) async {
    if (times.isEmpty) {
      throw Exception("시간대를 지정해야 합니다.");
    }

    times.sort();
    String startTime = times.first.split(' - ')[0];
    String endTime = times.last.split(' - ')[1];

    // 만약 예약 시간이 21시를 넘어가면, 다음날 시간을 포함하도록 처리
    int endHour = int.parse(endTime.split(':')[0]);
    if (endHour <= 9 && endHour != 0) {
      // 현재 날짜와 다음날로 분할
      List<String> currentDayTimes = times.where((time) {
        int hour = int.parse(time.split(' - ')[0].split(':')[0]);
        return hour < 21;
      }).toList();

      List<String> nextDayTimes = times.where((time) {
        int hour = int.parse(time.split(' - ')[0].split(':')[0]);
        return hour >= 21;
      }).toList();

      // 현재 날짜에 예약
      if (currentDayTimes.isNotEmpty) {
        String mergedTime = "${currentDayTimes.first.split(' - ')[0]} - 21:00";
        DatabaseReference reservationRef = isRequest
            ? getReservationRequestReference(equipment, date, mergedTime)
            : getReservationReference(equipment, date, mergedTime);
        await reservationRef.set({
          'uid': _user!.uid,
          'times': currentDayTimes,
        });
      }

      // 다음날 오전 9시부터 남은 시간 예약
      if (nextDayTimes.isNotEmpty) {
        DateTime nextDay = DateTime.parse(date).add(Duration(days: 1));
        String nextDayString = "${nextDay.year}-${nextDay.month.toString().padLeft(2, '0')}-${nextDay.day.toString().padLeft(2, '0')}";
        String mergedTime = "09:00 - ${nextDayTimes.last.split(' - ')[1]}";
        DatabaseReference reservationRef = isRequest
            ? getReservationRequestReference(equipment, nextDayString, mergedTime)
            : getReservationReference(equipment, nextDayString, mergedTime);
        await reservationRef.set({
          'uid': _user!.uid,
          'times': nextDayTimes,
        });
      }
    } else {
      // 하루 내에 예약
      String mergedTime = "$startTime - $endTime";
      DatabaseReference reservationRef = isRequest
          ? getReservationRequestReference(equipment, date, mergedTime)
          : getReservationReference(equipment, date, mergedTime);
      await reservationRef.set({
        'uid': _user!.uid,
        'times': times,
      });
    }
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
  Future<Map<String, Map<String, String>>> fetchUserReservations(String uid) async {
    final DataSnapshot snapshot = await _database.child('reservation').get();
    final Map<String, Map<String, String>> userReservations = {};

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      data.forEach((machineType, machineData) {
        if (machineData is Map) {
          machineData.forEach((machine, machineDetails) {
            if (machineDetails is Map) {
              machineDetails.forEach((date, timeSlots) {
                if (timeSlots is Map) {
                  timeSlots.forEach((timeSlot, reservationDetails) {
                    if (reservationDetails is Map &&
                        reservationDetails['uid'] == uid) {
                      if (!userReservations.containsKey(date)) {
                        userReservations[date] = {};
                      }
                      userReservations[date]![machine] = timeSlot;
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

  // 유저 예약 요청 삭제 (예약 요청 취소)
  Future<void> deleteUserReservationRequest(String uid, String date, String equipment, String timeSlot) async {
    final DatabaseReference ref = getReservationRequestReference(equipment, date, timeSlot);

    final DataSnapshot snapshot = await ref.get();

    if (snapshot.exists && snapshot.child('uid').value == uid) {
      await ref.remove();
      _log("Reservation request deleted for $timeSlot on $date");
    }
  }

  // 승인된 예약 삭제
  Future<void> deleteUserReservation(String uid, String date, String equipment, String timeSlot) async {
    final DatabaseReference ref = getReservationReference(equipment, date, timeSlot);

    final DataSnapshot snapshot = await ref.get();

    if (snapshot.exists && snapshot.child('uid').value == uid) {
      await ref.remove();
      _log("Reservation deleted for $timeSlot on $date");
    }
  }
}
