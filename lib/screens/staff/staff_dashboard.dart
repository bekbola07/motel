
import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/dormitory_service.dart';
import '../../services/room_service.dart';
import '../../services/staff_service.dart';
import '../../widgets/active_assignment_list.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/dormitory_crud_screen.dart';
import '../../widgets/pending_request_list.dart';

class StaffDashboard extends StatefulWidget {
  const StaffDashboard({Key? key}) : super(key: key);

  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  final StaffService _staffService = StaffService();
  final DormitoryService _dormitoryService = DormitoryService();
  final RoomService _roomService = RoomService();

  int _selectedIndex = 0;
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      _buildPendingRequests(),
      _buildActiveAssignments(),
      const DormitoryCrudScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.of(context).pop();
  }

  Widget _buildPendingRequests() {
    return FutureBuilder<List<Request>>(
      future: _staffService.getPendingRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No pending requests.'));
        }
        return PendingRequestList(requests: snapshot.data!, onApprove: _approveRequest);
      },
    );
  }

  Widget _buildActiveAssignments() {
    return FutureBuilder<List<Assignment>>(
      future: _staffService.getActiveAssignments(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No active assignments.'));
        }
        return ActiveAssignmentList(assignments: snapshot.data!);
      },
    );
  }

  Future<void> _approveRequest(Request request) async {
    final dorms = await _dormitoryService.getDormitories();
    if (!mounted || dorms.isEmpty) return;

    final selectedDorm = await _showSelectDialog<Dormitory>(context, 'Select Dormitory', dorms, (d) => d.name);
    if (selectedDorm == null) return;

    final rooms = await _roomService.getRooms(selectedDorm.id);
    if (!mounted || rooms.isEmpty) return;

    final selectedRoom = await _showSelectDialog<Room>(context, 'Select Room', rooms, (r) => r.number);
    if (selectedRoom == null) return;

    final bedSpaces = await _staffService.getAvailableBedSpaces(selectedRoom.id);
    if (!mounted || bedSpaces.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No available bed spaces in this room.')));
      return;
    }

    final selectedBedSpace = await _showSelectDialog<BedSpace>(context, 'Select Bed Space', bedSpaces, (bs) => bs.spaceNumber);
    if (selectedBedSpace == null) return;

    try {
      await _staffService.approveRequest(request, selectedBedSpace.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request approved!'), backgroundColor: Colors.green),
      );
      setState(() {}); // Re-build to refresh the lists
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to approve: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }

  Future<T?> _showSelectDialog<T>(BuildContext context, String title, List<T> items, String Function(T) itemToString) {
    return showDialog<T>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  title: Text(itemToString(item)),
                  onTap: () => Navigator.of(context).pop(item),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['Pending Requests', 'Active Assignments', 'Dormitory Management'];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
      ),
      drawer: AppDrawer(onItemTapped: _onItemTapped),
      body: _widgetOptions.elementAt(_selectedIndex),
    );
  }
}
