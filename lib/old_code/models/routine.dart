import 'package:cloud_firestore/cloud_firestore.dart';
class RoutineExercise {
  final String techId;
  final int sets;
  final int reps;
  final int timingSec;

  RoutineExercise({
    required this.techId,
    required this.sets,
    required this.reps,
    required this.timingSec,
  });
  factory RoutineExercise.fromMap(Map<String, dynamic> map) => RoutineExercise(
    techId: map['id'] ?? '',
    sets: map['sets'] ?? 0,
    reps: map['reps'] ?? 0,
    timingSec: map['timing_sec'] ?? 0,
  );
  Map<String, dynamic> toMap() => {
    'id': techId,
    'sets': sets,
    'reps': reps,
    'timing_sec': timingSec,
  };
}

class Routine {
  final String id;
  final String art;
  final String name;
  final String userId;
  final bool isDefault;
  final DateTime createdAt;
  final List<RoutineExercise> exercises;

  Routine({
    required this.id,
    required this.art,
    required this.name,
    required this.userId,
    required this.isDefault,
    required this.createdAt,
    required this.exercises,
  });

  factory Routine.fromMap(String id, Map<String, dynamic> map) => Routine(
    id: id,
    art: map['art'] ?? '',
    name: map['name'] ?? '',
    userId: map['userId'] ?? '',
    isDefault: map['is_default'] ?? false,
    createdAt: (map['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    exercises: List<Map<String, dynamic>>.from(
      map['exercises'] ?? [],
    ).map((e) => RoutineExercise.fromMap(e)).toList(),
  );
  Map<String, dynamic> toMap() => {
    'art': art,
    'name': name,
    'userId': userId,
    'is_default': isDefault,
    'created_at': createdAt,
    'exercises': exercises.map((e) => e.toMap()).toList(),
  };
}
