
import 'package:flutter/material.dart';
import '../models/models.dart';

class PendingRequestList extends StatelessWidget {
  final List<Request> requests;
  final Function(Request) onApprove;

  const PendingRequestList({
    Key? key,
    required this.requests,
    required this.onApprove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return const Center(child: Text('No pending requests.'));
    }

    return ListView.builder(
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text('Student ID: ${request.studentId}'),
            subtitle: Text('Wants room with capacity: ${request.preferredCapacity}\nNote: ${request.note}'),
            trailing: ElevatedButton(
              onPressed: () => onApprove(request),
              child: const Text('Approve'),
            ),
          ),
        );
      },
    );
  }
}
