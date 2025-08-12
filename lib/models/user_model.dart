class UserModel {
  final String uid;
  final String email;
  final String name;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.createdAt,
  });

  // Convert UserModel to Map for Firebase Realtime Database
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  // Create UserModel from Map (Firebase Realtime Database retrieval)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }

  // Create a copy of UserModel with updated fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'UserModel{uid: $uid, email: $email, name: $name, createdAt: $createdAt}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.uid == uid &&
        other.email == email &&
        other.name == name &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return uid.hashCode ^ email.hashCode ^ name.hashCode ^ createdAt.hashCode;
  }
}
