
import 'package:flutter/material.dart';
import '../models/models.dart';

class ActiveAssignmentList extends StatelessWidget {
  final List<Assignment> assignments;

  const ActiveAssignmentList({Key? key, required this.assignments}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (assignments.isEmpty) {
      return const Center(child: Text('No active assignments.'));
    }

    return ListView.builder(
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        final assignment = assignments[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text('Student ID: ${assignment.studentId}'),
            subtitle: Text('Bed Space ID: ${assignment.bedSpaceId}'),
            trailing: const Chip(
              label: Text('ACTIVE'),
              backgroundColor: Colors.green,
              labelStyle: TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}
