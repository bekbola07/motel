
import 'package:flutter/material.dart';
import 'package:motel/services/auth_service.dart';
import '../../models/models.dart';
import '../../services/student_service.dart';
import '../../widgets/app_drawer.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({Key? key}) : super(key: key);

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final StudentService _studentService = StudentService();
  late final User _currentUser;

  Future<Student?>? _profileFuture;
  Future<Assignment?>? _assignmentFuture;
  Future<List<Request>>? _requestsFuture;

  @override
  void initState() {
    super.initState();
    // In a real app, you would get the current user from your auth provider
    _currentUser = AuthService.instance.currentUser!;
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _profileFuture = _studentService.getStudentProfile(_currentUser.linkedStudentId!);
      _assignmentFuture = _studentService.getActiveAssignment(_currentUser.linkedStudentId!);
      _requestsFuture = _studentService.getMyRequests(_currentUser.linkedStudentId!);
    });
  }

  void _onItemTapped(int index) {
    // For student, there is only one view, so we just close the drawer.
    Navigator.of(context).pop();
  }

  Future<void> _createRequest() async {
    final result = await _showCreateRequestDialog();

    if (result != null) {
      try {
        await _studentService.createRequest(
          _currentUser.linkedStudentId!,
          result['capacity'],
          result['note'],
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request submitted!'), backgroundColor: Colors.green),
        );
        _refreshData(); // Refresh the list of requests
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit request: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<Map<String, dynamic>?> _showCreateRequestDialog() {
    final capacityController = TextEditingController();
    final noteController = TextEditingController();

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Room Request'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: capacityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Preferred Capacity'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(labelText: 'Notes (optional)'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop({
                  'capacity': int.tryParse(capacityController.text) ?? 1,
                  'note': noteController.text.trim(),
                });
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Dashboard'),
      ),
      drawer: AppDrawer(onItemTapped: _onItemTapped),
      body: RefreshIndicator(
        onRefresh: () async => _refreshData(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileSection(),
              const SizedBox(height: 24),
              _buildAssignmentSection(),
              const SizedBox(height: 24),
              _buildRequestsSection(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createRequest,
        label: const Text('New Request'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProfileSection() {
    return FutureBuilder<Student?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return const Text('Could not load profile.');
        }
        final profile = snapshot.data!;
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('My Profile', style: Theme.of(context).textTheme.titleLarge),
                const Divider(),
                Text('Name: ${profile.fullName}', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text('Student ID: ${profile.studentId}', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text('Email: ${profile.email}', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text('Faculty: ${profile.faculty}', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAssignmentSection() {
    return FutureBuilder<Assignment?>(
      future: _assignmentFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Text('Could not load assignment.');
        }

        final assignment = snapshot.data;
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Assignment Status', style: Theme.of(context).textTheme.titleLarge),
                const Divider(),
                if (assignment != null)
                  Text('You are assigned to Bed Space: ${assignment.bedSpaceId}', style: Theme.of(context).textTheme.bodyMedium)
                else
                  Text('You do not have an active assignment.', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRequestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('My Requests', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        FutureBuilder<List<Request>>(
          future: _requestsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('You have no requests. Tap the + button to create one.'),
              ));
            }

            final requests = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: Text('Request from ${request.createdAt.toLocal().toString().substring(0, 10)}'),
                    subtitle: Text('Note: ${request.note ?? 'N/A'}'),
                    trailing: Chip(
                      label: Text(request.status.name),
                      backgroundColor: _getStatusColor(request.status),
                      labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Color _getStatusColor(RequestStatus status) {
    switch (status) {
      case RequestStatus.APPROVED:
        return Colors.green;
      case RequestStatus.PENDING:
        return Colors.orange;
      case RequestStatus.REJECTED:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
