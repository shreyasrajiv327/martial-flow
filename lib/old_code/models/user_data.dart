class UserData {
  final String uid;
  final String email;
  final String displayName;
  final String beltLevel;

  UserData({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.beltLevel,
  });

  factory UserData.fromMap(String uid, Map<String, dynamic> map) => UserData(
        uid: uid,
        email: map['email'] ?? '',
        displayName: map['displayName'] ?? '',
        beltLevel: map['beltLevel'] ?? 'White',
      );
  Map<String, dynamic> toMap() => {
        'email': email,
        'displayName': displayName,
        'beltLevel': beltLevel,
      };
}

