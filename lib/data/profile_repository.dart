import 'package:dio/dio.dart';

import '../models/profile.dart';

class ProfileRepository {
  const ProfileRepository(this._client);

  final Dio _client;

  Future<Profile> fetchProfile() async {
    final response = await _client.get('/user');
    return Profile.fromApiResponse(response.data);
  }
}