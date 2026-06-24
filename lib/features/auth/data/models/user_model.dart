import '../../domain/entities/user.dart';

/// Data-layer representation of [User] with JSON (de)serialization for Hive.
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
      };

  factory UserModel.fromEntity(User user) =>
      UserModel(id: user.id, name: user.name, email: user.email);
}
