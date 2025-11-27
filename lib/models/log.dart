class ExerciseLog {
  final String id;
  final String userId;
  final String art;
  final String techId;
  final String routineId;
  final int timestamp;
  final int setsDone;
  final List<int> repsDone;
  final List<int> timeSec;
  final String notes;

  ExerciseLog({
    required this.id,
    required this.userId,
    required this.art,
    required this.techId,
    required this.routineId,
    required this.timestamp,
    required this.setsDone,
    required this.repsDone,
    required this.timeSec,
    required this.notes,
  });

  factory ExerciseLog.fromMap(String id, Map<String, dynamic> map) =>
      ExerciseLog(
        id: id,
        userId: map['userId'] ?? '',
        art: map['art'] ?? '',
        techId: map['techId'] ?? '',
        routineId: map['routineId'] ?? '',
        timestamp: map['timestamp'] ?? 0,
        setsDone: map['sets_done'] ?? 0,
        repsDone: List<int>.from(map['reps_done'] ?? []),
        timeSec: List<int>.from(map['time_sec'] ?? []),
        notes: map['notes'] ?? '',
      );
  Map<String, dynamic> toMap() => {
    'userId': userId,
    'art': art,
    'techId': techId,
    'routineId': routineId,
    'timestamp': timestamp,
    'sets_done': setsDone,
    'reps_done': repsDone,
    'time_sec': timeSec,
    'notes': notes,
  };
}
