
import 'package:flutter/material.dart';
import '../models/models.dart';

class DormitoryList extends StatelessWidget {
  final List<Dormitory> dormitories;

  const DormitoryList({Key? key, required this.dormitories}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: dormitories.length,
      itemBuilder: (context, index) {
        final dormitory = dormitories[index];
        return ListTile(
          title: Text(dormitory.name),
          subtitle: Text(dormitory.address),
        );
      },
    );
  }
}
