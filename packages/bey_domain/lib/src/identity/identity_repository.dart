import 'user_profile.dart';

abstract interface class IdentityRepository {
  Future<UserProfile?> getActiveProfile();
  Future<({UserProfile profile, String formattedRecoveryCode})> createProfile(String nickname);
  Future<void> updateProfile(UserProfile profile);
  Future<bool> restoreWithRecoveryCode(String code, {required String nickname});
  Future<void> logoutOrReset();
}
