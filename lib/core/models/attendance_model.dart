import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  final String id;
  final String sessionId;
  final String userId;
  final DateTime timestamp;
  final String status;
  final String courseCode;

  AttendanceModel({
    required this.id,
    required this.sessionId,
    required this.userId,
    required this.timestamp,
    required this.status,
    required this.courseCode,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json, String id) {
    Timestamp ts = json['timestamp'] as Timestamp;

    return AttendanceModel(
      id: id,
      sessionId: json['sessionId'] ?? 'N/A',
      userId: json['userId'] ?? 'N/A',
      timestamp: ts.toDate(),
      status: json['status'] ?? 'N/A',
      courseCode: json['courseCode'] ?? 'N/A',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'userId': userId,
      'timestamp': FieldValue.serverTimestamp(),
      'status': status,
      'courseCode': courseCode,
    };
  }
}
