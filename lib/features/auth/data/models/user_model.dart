import '../../domain/entities/app_user.dart';

class UserModel extends AppUser {
  const UserModel({
    required super.uid,
    required super.name,
    required super.email,
    required super.role,
    required super.language,
    required super.createdAt,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: data['role'] as String? ?? 'user',
      language: data['language'] as String? ?? 'en',
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (data['createdAt'] as dynamic).millisecondsSinceEpoch)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'language': language,
      'createdAt': createdAt,
    };
  }

  factory UserModel.fromEntity(AppUser user) {
    return UserModel(
      uid: user.uid,
      name: user.name,
      email: user.email,
      role: user.role,
      language: user.language,
      createdAt: user.createdAt,
    );
  }
}
