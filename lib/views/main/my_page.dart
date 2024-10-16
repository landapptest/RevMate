import 'package:flutter/material.dart';
import 'package:RevMate/controllers/reserve_controller.dart';
import 'package:RevMate/models/reservation_service.dart';

class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final ReservationService _reservationService = ReservationService();
  final ReserveController _controller = ReserveController(ReservationService());
  final Map<String, Set<String>> _selectedReservations = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('마이페이지'),
      ),
      body: FutureBuilder<Map<String, Map<String, String>>>(
        future: _reservationService.fetchUserReservations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('예약 내역이 없습니다.'));
          } else {
            final reservations = snapshot.data!;
            return ListView.builder(
              itemCount: reservations.length,
              itemBuilder: (context, index) {
                final date = reservations.keys.elementAt(index);
                final machines = reservations[date]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        date,
                        style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...machines.entries.map((entry) {
                      final machine = entry.key;
                      final time = entry.value;
                      final isSelected = _selectedReservations.containsKey(date) && _selectedReservations[date]!.contains(time);

                      return ListTile(
                        title: Text('$machine: $time'),
                        trailing: Checkbox(
                          value: isSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              _toggleReservation(date, machine, time);
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ],
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _controller.cancelReservations(_selectedReservations),
        child: const Icon(Icons.delete),
      ),
    );
  }

  void _toggleReservation(String date, String machine, String time) {
    setState(() {
      final key = '$date|$machine';
      if (_selectedReservations.containsKey(key)) {
        if (_selectedReservations[key]!.contains(time)) {
          _selectedReservations[key]!.remove(time);
        } else {
          _selectedReservations[key]!.add(time);
        }
      } else {
        _selectedReservations[key] = {time};
      }
    });
  }
}
