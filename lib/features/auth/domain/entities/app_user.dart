import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String role; // 'user' | 'restaurant'
  final String language; // 'en' | 'ar'
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.language,
    required this.createdAt,
  });

  bool get isRestaurant => role == 'restaurant';
  bool get isUser => role == 'user';

  AppUser copyWith({
    String? name,
    String? email,
    String? role,
    String? language,
  }) {
    return AppUser(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      language: language ?? this.language,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [uid, name, email, role, language];
}
