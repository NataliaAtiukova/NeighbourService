import '../models/user_profile.dart';

abstract class UserProfileRepository {
  Stream<UserProfile?> watchProfile(String uid);
  Future<UserProfile?> getProfile(String uid);
  Future<void> createProfile({
    required String uid,
    required String displayName,
    required String phoneNumber,
    required String suburb,
    required bool isPhoneVerified,
  });
  Future<void> updateProfile({
    required String uid,
    String? displayName,
    String? suburb,
  });
}
