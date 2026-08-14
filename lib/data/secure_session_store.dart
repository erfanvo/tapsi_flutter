import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureSessionStore {
  SecureSessionStore({
    FlutterSecureStorage? storage,
  }) : _storage = storage ?? const FlutterSecureStorage();

  static const _cookieKey = 'tapsi_cookie';
  final FlutterSecureStorage _storage;

  Future<void> saveCookie(String cookie) {
    return _storage.write(key: _cookieKey, value: cookie);
  }

  Future<String?> readCookie() {
    return _storage.read(key: _cookieKey);
  }

  Future<void> clear() {
    return _storage.delete(key: _cookieKey);
  }
}