import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressEntry {
  final String id;
  final String userId;
  final String routineId;
  final bool completed;
  final DateTime timestamp;

  ProgressEntry({
    required this.id,
    required this.userId,
    required this.routineId,
    required this.completed,
    required this.timestamp,
  });

  factory ProgressEntry.fromJson(Map<String, dynamic> map) => ProgressEntry(
        id: map['id'] ?? '',
        userId: map['userId'] ?? '',
        routineId: map['routineId'] ?? '',
        completed: map['completed'] ?? false,
        timestamp: DateTime.parse(map['timestamp']),
      );
  factory ProgressEntry.fromMap(String id, Map<String, dynamic> map) => ProgressEntry(
        id: id,
        userId: map['userId'] ?? '',
        routineId: map['routineId'] ?? '',
        completed: map['completed'] ?? false,
        timestamp: DateTime.parse(map['timestamp']),
      );
  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'routineId': routineId,
        'completed': completed,
        'timestamp': timestamp.toIso8601String(),
      };
  Map<String, dynamic> toMap() => toJson();
}

