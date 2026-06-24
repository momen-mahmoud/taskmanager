import 'package:equatable/equatable.dart';

/// A registered application user (no credentials — those never leave the data
/// layer).
class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    required this.email,
  });

  final int id;
  final String name;
  final String email;

  @override
  List<Object?> get props => [id, name, email];
}
