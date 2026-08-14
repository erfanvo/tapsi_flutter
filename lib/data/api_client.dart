import 'package:dio/dio.dart';

import '../config/api_config.dart';
import 'secure_session_store.dart';

class TapsiApiClient {
  TapsiApiClient(this.sessionStore)
      : licenseClient = Dio(
          BaseOptions(
            baseUrl: ApiConfig.licenseBaseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 20),
            headers: const {
              'Accept': 'application/json',
            },
          ),
        ),
        client = Dio(
          BaseOptions(
            baseUrl: ApiConfig.tapsiBaseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 20),
            headers: const {
              'Accept': 'application/json, text/plain, */*',
              'User-Agent': ApiConfig.browserUserAgent,
              'x-agent': 'pwa',
              'x-app-version': '1.0.0',
            },
          ),
        ) {
    client.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final cookie = await sessionStore.readCookie();
          if (cookie != null && cookie.trim().isNotEmpty) {
            options.headers['Cookie'] = cookie;
          }

          options.headers['User-Agent'] = ApiConfig.browserUserAgent;
          options.headers['Accept'] = 'application/json, text/plain, */*';
          options.headers['x-agent'] = 'pwa';
          options.headers['x-app-version'] = '1.0.0';
          handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401 ||
              error.response?.statusCode == 403) {
            error = error.copyWith(
              message: 'نشست منقضی شده یا مجوز دسترسی معتبر نیست.',
            );
          }
          handler.next(error);
        },
      ),
    );
  }

  final SecureSessionStore sessionStore;
  final Dio licenseClient;
  final Dio client;
}