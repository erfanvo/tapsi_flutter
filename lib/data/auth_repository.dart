import 'package:dio/dio.dart';

import '../models/profile.dart';
import 'secure_session_store.dart';

class AuthRepository {
  AuthRepository({
    required SecureSessionStore sessionStore,
    required Dio licenseClient,
  })  : _sessionStore = sessionStore,
        _licenseClient = licenseClient;

  final SecureSessionStore _sessionStore;
  final Dio _licenseClient;

  Future<Profile?> login(String license) async {
    final response = await _licenseClient.get(
      '/get-license/${Uri.encodeComponent(license)}',
    );
    final body = _asMap(response.data);

    if (body['success'] != true) {
      throw const AuthException('لایسنس معتبر نیست یا دسترسی آن فعال نیست.');
    }

    final data = _asMap(body['data']);
    final cookies = data['cookies']?.toString().trim() ?? '';
    if (cookies.isEmpty) {
      throw const AuthException('نشست معتبری از سرویس لایسنس دریافت نشد.');
    }

    await _sessionStore.saveCookie(cookies);

    final profile = _asMap(body['user'] ?? data['user']);
    return profile.isEmpty ? null : Profile.fromJson(profile);
  }

  Future<void> logout() => _sessionStore.clear();

  Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map(
        (key, item) => MapEntry(key.toString(), item),
      );
    }
    return <String, dynamic>{};
  }
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}