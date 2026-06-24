import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/hive_boxes.dart';
import '../../../../core/storage/secure_storage.dart';
import '../models/user_model.dart';

/// Mock authentication backed entirely by local storage.
///
/// jsonplaceholder exposes no auth endpoint, so we simulate it:
/// - registered users (with a salted SHA-256 password hash) live in a Hive box,
/// - on success we mint a fake JWT (`header.payload.signature`) carrying the
///   user id and an expiry, and persist it via [SecureStorage].
///
/// This keeps the *interface* identical to a real remote auth source, so
/// swapping in a real backend later would only touch this one file.
class AuthLocalDataSource {
  AuthLocalDataSource({
    required SecureStorage secureStorage,
    Box<String>? usersBox,
    Box<String>? cacheBox,
  })  : _secureStorage = secureStorage,
        _usersBox = usersBox ?? HiveBoxes.users,
        _cacheBox = cacheBox ?? HiveBoxes.cache;

  final SecureStorage _secureStorage;
  final Box<String> _usersBox;
  final Box<String> _cacheBox;

  static const Duration _tokenTtl = Duration(days: 7);

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final key = email.trim().toLowerCase();
    if (_usersBox.containsKey(key)) {
      throw const AuthException('An account with this email already exists.');
    }

    final user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      name: name.trim(),
      email: key,
    );

    await _usersBox.put(key, jsonEncode({
      ...user.toJson(),
      'passwordHash': _hash(password),
    }));

    await _startSession(user);
    return user;
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final key = email.trim().toLowerCase();
    final record = _usersBox.get(key);
    if (record == null) {
      throw const AuthException('No account found for this email.');
    }

    final data = jsonDecode(record) as Map<String, dynamic>;
    if (data['passwordHash'] != _hash(password)) {
      throw const AuthException('Incorrect email or password.');
    }

    final user = UserModel.fromJson(data);
    await _startSession(user);
    return user;
  }

  Future<void> logout() async {
    await _secureStorage.deleteToken();
    await _cacheBox.delete(AppConstants.currentUserKey);
  }

  /// Returns the current user if a non-expired token + cached profile exist.
  Future<UserModel?> getCurrentUser() async {
    final token = await _secureStorage.readToken();
    if (token == null || !_isTokenValid(token)) {
      await logout();
      return null;
    }
    final cached = _cacheBox.get(AppConstants.currentUserKey);
    if (cached == null) return null;
    return UserModel.fromJson(jsonDecode(cached) as Map<String, dynamic>);
  }

  // ---- helpers ----

  Future<void> _startSession(UserModel user) async {
    await _secureStorage.writeToken(_mintToken(user.id));
    await _cacheBox.put(AppConstants.currentUserKey, jsonEncode(user.toJson()));
  }

  String _hash(String password) {
    // Static salt is sufficient for a mock; real auth would use a per-user salt.
    return sha256.convert(utf8.encode('electro_pi_salt::$password')).toString();
  }

  String _mintToken(int userId) {
    final now = DateTime.now();
    final header = _b64({'alg': 'HS256', 'typ': 'JWT'});
    final payload = _b64({
      'sub': userId,
      'iat': now.millisecondsSinceEpoch ~/ 1000,
      'exp': now.add(_tokenTtl).millisecondsSinceEpoch ~/ 1000,
    });
    final signature =
        base64Url.encode(utf8.encode('mock-signature-$userId')).replaceAll('=', '');
    return '$header.$payload.$signature';
  }

  bool _isTokenValid(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      ) as Map<String, dynamic>;
      final exp = payload['exp'] as int;
      final nowSecs = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      return exp > nowSecs;
    } catch (_) {
      return false;
    }
  }

  String _b64(Map<String, dynamic> map) =>
      base64Url.encode(utf8.encode(jsonEncode(map))).replaceAll('=', '');
}

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSource(secureStorage: ref.read(secureStorageProvider));
});
