
import 'package:flutter/material.dart';
import '../models/models.dart';

class ActiveAssignmentList extends StatelessWidget {
  final List<Assignment> assignments;

  const ActiveAssignmentList({Key? key, required this.assignments}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (assignments.isEmpty) {
      return const Center(child: Text('Faol biriktirishlar yo\'q.'));
    }

    return ListView.builder(
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        final assignment = assignments[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text('Talaba IDsi: ${assignment.studentId}'),
            subtitle: Text('Joy IDsi: ${assignment.bedSpaceId}'),
            trailing: const Chip(
              label: Text('FAOL'),
              backgroundColor: Colors.green,
              labelStyle: TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}
