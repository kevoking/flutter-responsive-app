// auth/user_model.dart
class User {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final List<String> roles;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    this.roles = const ['user'],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      photoUrl: json['photoUrl'],
      roles: List<String>.from(json['roles'] ?? ['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'roles': roles,
    };
  }

  bool hasRole(String role) {
    return roles.contains(role);
  }
}
