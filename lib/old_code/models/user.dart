// models/user.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class UserArtInfo {
  final String belt;
  final String experienceLevel;
  final List<String> goals;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserArtInfo({
    required this.belt,
    required this.experienceLevel,
    required this.goals,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserArtInfo.fromMap(Map<String, dynamic> map) {
    return UserArtInfo(
      belt: map['belt'] ?? 'white',
      experienceLevel: map['experience_level'] ?? 'beginner',
      goals: List<String>.from(map['goals'] ?? []),
      createdAt: (map['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'belt': belt,
        'experience_level': experienceLevel,
        'goals': goals,
        'created_at': Timestamp.fromDate(createdAt),
        'updated_at': Timestamp.fromDate(updatedAt),
      };

  // Helper for updating
  UserArtInfo copyWith({String? belt, String? experienceLevel, List<String>? goals}) {
    return UserArtInfo(
      belt: belt ?? this.belt,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      goals: goals ?? this.goals,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

class UserProfile {
  final String id;
  final String name;
  final String email;
  final List<String> martialArts;
  final Map<String, UserArtInfo> arts;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.martialArts,
    required this.arts,
  });

  factory UserProfile.fromMap(String id, Map<String, dynamic> map) {
    final artsMap = Map<String, dynamic>.from(map['arts'] ?? {});

    return UserProfile(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      martialArts: List<String>.from(map['martial_arts'] ?? []),
      arts: artsMap.map((key, value) => MapEntry(key, UserArtInfo.fromMap(value))),
    );
  }
}