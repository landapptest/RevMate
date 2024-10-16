import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'reservation_service.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final ReservationService _reservationService = ReservationService();
  final Map<String, Set<String>> _selectedReservations = {};

  void _toggleReservation(String date, String machine, String time) {
    setState(() {
      final key = '$date|$machine';
      if (_selectedReservations.containsKey(key)) {
        if (_selectedReservations[key]!.contains(time)) {
          _selectedReservations[key]!.remove(time);
          if (_selectedReservations[key]!.isEmpty) {
            _selectedReservations.remove(key);
          }
        } else {
          _selectedReservations[key]!.add(time);
        }
      } else {
        _selectedReservations[key] = {time};
      }
    });
  }

  void _cancelReservations() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    final uid = user.uid;
    for (var entry in _selectedReservations.entries) {
      final parts = entry.key.split('|');
      final date = parts[0];
      final machine = parts[1];
      for (var time in entry.value) {
        await _reservationService.deleteUserReservation(uid, date, machine, time);
      }
    }

    setState(() {
      _selectedReservations.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('선택한 예약이 취소되었습니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('마이페이지'),
      ),
      body: user != null
          ? FutureBuilder<Map<String, Map<String, String>>>(
        future: _reservationService.fetchUserReservations(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('예약 내역이 없습니다.'));
          } else {
            final reservations = snapshot.data!;
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: reservations.length,
                    itemBuilder: (context, index) {
                      final date = reservations.keys.elementAt(index);
                      final machines = reservations[date]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            child: Text(
                              date,
                              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                          ),
                          ...machines.entries.map((entry) {
                            final machine = entry.key;
                            final time = entry.value;
                            final isSelected = _selectedReservations
                                .containsKey('$date|$machine') &&
                                _selectedReservations['$date|$machine']!
                                    .contains(time);
                            return ListTile(
                              title: Text('$machine: $time'),
                              trailing: Checkbox(
                                value: isSelected,
                                onChanged: (bool? value) {
                                  _toggleReservation(date, machine, time);
                                },
                              ),
                            );
                          }).toList(),
                          const Divider(), // 구분선 추가
                        ],
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: _cancelReservations,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 20.0),
                  ),
                  child: const Text(
                    '선택한 예약 취소',
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
              ],
            );
          }
        },
      )
          : const Center(child: Text('로그인이 필요합니다.')),
    );
  }
}
