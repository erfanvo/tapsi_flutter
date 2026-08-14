import 'package:flutter/material.dart';

import 'app.dart';
import 'data/api_client.dart';
import 'data/auth_repository.dart';
import 'data/profile_repository.dart';
import 'data/secure_session_store.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final sessionStore = SecureSessionStore();
  final apiClient = TapsiApiClient(sessionStore);

  runApp(
    TapsiClientApp(
      authRepository: AuthRepository(
        sessionStore: sessionStore,
        licenseClient: apiClient.licenseClient,
      ),
      profileRepository: ProfileRepository(apiClient.client),
      sessionStore: sessionStore,
    ),
  );
}