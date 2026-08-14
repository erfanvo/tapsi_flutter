class Profile {
  const Profile({
    this.name,
    this.mobile,
  });

  final String? name;
  final String? mobile;

  factory Profile.fromApiResponse(Object? value) {
    final root = _asMap(value);
    final data = _asMap(root['data']);
    final user = _asMap(
      root['user'] ?? data['user'] ?? data['profile'] ?? data,
    );
    return Profile.fromJson(user.isEmpty ? root : user);
  }

  factory Profile.fromJson(Map<String, dynamic> json) {
    final firstName = _text(json['firstName'] ?? json['first_name']);
    final lastName = _text(json['lastName'] ?? json['last_name']);
    final combinedName = [firstName, lastName]
        .where((part) => part != null && part.isNotEmpty)
        .join(' ');

    return Profile(
      name: _text(
        json['name'] ??
            json['fullName'] ??
            json['full_name'] ??
            (combinedName.isEmpty ? null : combinedName),
      ),
      mobile: _text(
        json['mobile'] ??
            json['mobileNumber'] ??
            json['mobile_number'] ??
            json['phone'] ??
            json['phoneNumber'],
      ),
    );
  }

  static Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map(
        (key, item) => MapEntry(key.toString(), item),
      );
    }
    return <String, dynamic>{};
  }

  static String? _text(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}