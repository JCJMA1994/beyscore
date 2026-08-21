import 'dart:convert';
import 'dart:io';

import 'package:bey_domain/bey_domain.dart';
import 'package:path_provider/path_provider.dart';

abstract interface class IdentityLocalDataSource {
  Future<UserProfile?> getActiveProfile();
  Future<void> saveActiveProfile(UserProfile profile);
  Future<void> clearActiveProfile();
}

class IdentityLocalDataSourceImpl implements IdentityLocalDataSource {
  IdentityLocalDataSourceImpl({Directory? baseDirectory}) : _baseDirectory = baseDirectory;

  final Directory? _baseDirectory;
  UserProfile? _cachedProfile;

  Future<File> _getProfileFile() async {
    final dir = _baseDirectory ?? await getApplicationDocumentsDirectory();
    return File('${dir.path}/bey_user_identity.json');
  }

  @override
  Future<UserProfile?> getActiveProfile() async {
    if (_cachedProfile != null) return _cachedProfile;
    try {
      final file = await _getProfileFile();
      if (!file.existsSync()) return null;
      final content = await file.readAsString();
      if (content.trim().isEmpty) return null;
      final json = jsonDecode(content) as Map<String, dynamic>;
      return _cachedProfile = UserProfile.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveActiveProfile(UserProfile profile) async {
    _cachedProfile = profile;
    final file = await _getProfileFile();
    final jsonString = jsonEncode(profile.toJson());
    await file.writeAsString(jsonString, flush: true);
  }

  @override
  Future<void> clearActiveProfile() async {
    _cachedProfile = null;
    final file = await _getProfileFile();
    if (file.existsSync()) {
      await file.delete();
    }
  }
}
