// lib/models/user_model.dart
class User {
  final int id;
  final String name;
  final String email;
  final String passwordHash;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'passwordHash': passwordHash,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      passwordHash: json['passwordHash'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
    );
  }

  User copyWithoutPassword() {
    return User(
      id: id,
      name: name,
      email: email,
      passwordHash: '',
      createdAt: createdAt,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, createdAt: $createdAt)';
  }
}