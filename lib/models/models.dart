
// User Model
class User {
  final String id;
  final String email;
  final String passwordHash;
  final UserRole role;
  final String? linkedStudentId;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.passwordHash,
    required this.role,
    this.linkedStudentId,
    required this.createdAt,
    required this.updatedAt,
  });

  User copyWith({
    String? id,
    String? email,
    String? passwordHash,
    UserRole? role,
    String? linkedStudentId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      role: role ?? this.role,
      linkedStudentId: linkedStudentId ?? this.linkedStudentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      passwordHash: map['password_hash'],
      role: UserRole.values.firstWhere((e) => e.name == map['role']),
      linkedStudentId: map['linked_student_id'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password_hash': passwordHash,
      'role': role.name,
      'linked_student_id': linkedStudentId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

enum UserRole { ADMIN, STAFF, STUDENT }

// Student Model
class Student {
  final String id;
  final String fullName;
  final String studentId;
  final String faculty;
  final String course;
  final String? phone;
  final String email;
  final String? photoUrl;
  final String? specialNeeds;
  final DateTime createdAt;
  final DateTime updatedAt;

  Student({
    required this.id,
    required this.fullName,
    required this.studentId,
    required this.faculty,
    required this.course,
    this.phone,
    required this.email,
    this.photoUrl,
    this.specialNeeds,
    required this.createdAt,
    required this.updatedAt,
  });

  Student copyWith({
    String? id,
    String? fullName,
    String? studentId,
    String? faculty,
    String? course,
    String? phone,
    String? email,
    String? photoUrl,
    String? specialNeeds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Student(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      studentId: studentId ?? this.studentId,
      faculty: faculty ?? this.faculty,
      course: course ?? this.course,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      specialNeeds: specialNeeds ?? this.specialNeeds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      fullName: map['full_name'],
      studentId: map['student_id'],
      faculty: map['faculty'],
      course: map['course'],
      phone: map['phone'],
      email: map['email'],
      photoUrl: map['photo_url'],
      specialNeeds: map['special_needs'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'student_id': studentId,
      'faculty': faculty,
      'course': course,
      'phone': phone,
      'email': email,
      'photo_url': photoUrl,
      'special_needs': specialNeeds,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

// Dormitory Model
class Dormitory {
  final String id;
  final String name;
  final String address;
  final DateTime createdAt;

  Dormitory({
    required this.id,
    required this.name,
    required this.address,
    required this.createdAt,
  });

  Dormitory copyWith({
    String? id,
    String? name,
    String? address,
    DateTime? createdAt,
  }) {
    return Dormitory(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Dormitory.fromMap(Map<String, dynamic> map) {
    return Dormitory(
      id: map['id'],
      name: map['name'],
      address: map['address'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

// Room Model
class Room {
  final String id;
  final String dormId;
  final String number;
  final int capacity;
  final RoomGender? gender;
  final String? features;
  final DateTime createdAt;

  Room({
    required this.id,
    required this.dormId,
    required this.number,
    required this.capacity,
    this.gender,
    this.features,
    required this.createdAt,
  });

  Room copyWith({
    String? id,
    String? dormId,
    String? number,
    int? capacity,
    RoomGender? gender,
    String? features,
    DateTime? createdAt,
  }) {
    return Room(
      id: id ?? this.id,
      dormId: dormId ?? this.dormId,
      number: number ?? this.number,
      capacity: capacity ?? this.capacity,
      gender: gender ?? this.gender,
      features: features ?? this.features,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Room.fromMap(Map<String, dynamic> map) {
    return Room(
      id: map['id'],
      dormId: map['dorm_id'],
      number: map['number'],
      capacity: map['capacity'],
      gender: map['gender'] != null
          ? RoomGender.values.firstWhere((e) => e.name == map['gender'])
          : null,
      features: map['features'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dorm_id': dormId,
      'number': number,
      'capacity': capacity,
      'gender': gender?.name,
      'features': features,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

enum RoomGender { MALE, FEMALE, MIXED }

// BedSpace Model - NEW
class BedSpace {
  final String id;
  final String roomId;
  final String spaceNumber; // e.g., "A", "B"
  final bool isOccupied;
  final DateTime createdAt;

  BedSpace({
    required this.id,
    required this.roomId,
    required this.spaceNumber,
    required this.isOccupied,
    required this.createdAt,
  });

  BedSpace copyWith({
    String? id,
    String? roomId,
    String? spaceNumber,
    bool? isOccupied,
    DateTime? createdAt,
  }) {
    return BedSpace(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      spaceNumber: spaceNumber ?? this.spaceNumber,
      isOccupied: isOccupied ?? this.isOccupied,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory BedSpace.fromMap(Map<String, dynamic> map) {
    return BedSpace(
      id: map['id'],
      roomId: map['room_id'],
      spaceNumber: map['space_number'],
      isOccupied: map['is_occupied'] == 1,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'room_id': roomId,
      'space_number': spaceNumber,
      'is_occupied': isOccupied ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

// Assignment Model
class Assignment {
  final String id;
  final String studentId;
  final String bedSpaceId; // Changed from roomId
  final DateTime startDate;
  final DateTime? endDate;
  final AssignmentStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Assignment({
    required this.id,
    required this.studentId,
    required this.bedSpaceId,
    required this.startDate,
    this.endDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  Assignment copyWith({
    String? id,
    String? studentId,
    String? bedSpaceId,
    DateTime? startDate,
    DateTime? endDate,
    AssignmentStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Assignment(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      bedSpaceId: bedSpaceId ?? this.bedSpaceId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Assignment.fromMap(Map<String, dynamic> map) {
    return Assignment(
      id: map['id'],
      studentId: map['student_id'],
      bedSpaceId: map['bed_space_id'],
      startDate: DateTime.parse(map['start_date']),
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date']) : null,
      status: AssignmentStatus.values.firstWhere((e) => e.name == map['status']),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'bed_space_id': bedSpaceId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

enum AssignmentStatus { PENDING, ACTIVE, ENDED, CANCELLED }

// Request Model
class Request {
  final String id;
  final String studentId;
  final int? preferredCapacity;
  final String? note;
  final RequestStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Request({
    required this.id,
    required this.studentId,
    this.preferredCapacity,
    this.note,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  Request copyWith({
    String? id,
    String? studentId,
    int? preferredCapacity,
    String? note,
    RequestStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Request(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      preferredCapacity: preferredCapacity ?? this.preferredCapacity,
      note: note ?? this.note,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Request.fromMap(Map<String, dynamic> map) {
    return Request(
      id: map['id'],
      studentId: map['student_id'],
      preferredCapacity: map['preferred_capacity'],
      note: map['note'],
      status: RequestStatus.values.firstWhere((e) => e.name == map['status']),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'preferred_capacity': preferredCapacity,
      'note': note,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

enum RequestStatus { PENDING, APPROVED, REJECTED }

// CheckInLog Model
class CheckInLog {
  final String id;
  final String assignmentId;
  final String userId;
  final CheckInAction action;
  final DateTime timestamp;

  CheckInLog({
    required this.id,
    required this.assignmentId,
    required this.userId,
    required this.action,
    required this.timestamp,
  });

  CheckInLog copyWith({
    String? id,
    String? assignmentId,
    String? userId,
    CheckInAction? action,
    DateTime? timestamp,
  }) {
    return CheckInLog(
      id: id ?? this.id,
      assignmentId: assignmentId ?? this.assignmentId,
      userId: userId ?? this.userId,
      action: action ?? this.action,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  factory CheckInLog.fromMap(Map<String, dynamic> map) {
    return CheckInLog(
      id: map['id'],
      assignmentId: map['assignment_id'],
      userId: map['user_id'],
      action: CheckInAction.values.firstWhere((e) => e.name == map['action']),
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'assignment_id': assignmentId,
      'user_id': userId,
      'action': action.name,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

enum CheckInAction { CHECKIN, CHECKOUT }

// Notification Model
class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  AppNotification copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      message: map['message'],
      isRead: map['is_read'] == 1,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'is_read': isRead ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
