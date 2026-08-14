import 'package:flutter/material.dart';

import 'data/auth_repository.dart';
import 'data/profile_repository.dart';
import 'data/secure_session_store.dart';
import 'pages/dashboard_page.dart';
import 'pages/license_login_page.dart';

class TapsiClientApp extends StatelessWidget {
  const TapsiClientApp({
    super.key,
    required this.authRepository,
    required this.profileRepository,
    required this.sessionStore,
  });

  final AuthRepository authRepository;
  final ProfileRepository profileRepository;
  final SecureSessionStore sessionStore;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'کلاینت تپسی',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF5A623),
          brightness: Brightness.light,
        ),
        fontFamily: 'sans',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF7F7F8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFF5A623), width: 1.5),
          ),
        ),
      ),
      locale: const Locale('fa'),
      home: FutureBuilder<String?>(
        future: sessionStore.readCookie(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const _SplashPage();
          }

          if ((snapshot.data ?? '').trim().isNotEmpty) {
            return DashboardPage(
              profileRepository: profileRepository,
              onLogout: () async {
                await authRepository.logout();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => LicenseLoginPage(
                      authRepository: authRepository,
                      onLoginSuccess: (profile) {
                        _openDashboard(context, profile);
                      },
                    ),
                  ),
                  (_) => false,
                );
              },
            );
          }

          return LicenseLoginPage(
            authRepository: authRepository,
            onLoginSuccess: (profile) {
              _openDashboard(context, profile);
            },
          );
        },
      ),
    );
  }

  void _openDashboard(BuildContext context, Object? _) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => DashboardPage(
          profileRepository: profileRepository,
          onLogout: () async {
            await authRepository.logout();
            if (!context.mounted) return;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => LicenseLoginPage(
                  authRepository: authRepository,
                  onLoginSuccess: (nextProfile) {
                    _openDashboard(context, nextProfile);
                  },
                ),
              ),
              (_) => false,
            );
          },
        ),
      ),
      (_) => false,
    );
  }
}

class _SplashPage extends StatelessWidget {
  const _SplashPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}