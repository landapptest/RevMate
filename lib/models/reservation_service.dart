import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
}
