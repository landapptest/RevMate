import 'package:flutter/material.dart';

class EquipmentListItem extends StatelessWidget {
  final String name;
  final bool isAvailable;

  const EquipmentListItem({
    Key? key,
    required this.name,
    required this.isAvailable,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name),
      trailing: Icon(
        isAvailable ? Icons.check_circle : Icons.cancel,
        color: isAvailable ? Colors.green : Colors.red,
      ),
    );
  }
}
