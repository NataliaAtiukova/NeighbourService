import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_profile.dart';

abstract class UserProfileRepository {
  Stream<UserProfile?> watchProfile(String uid);
  Future<UserProfile> ensureProfile({
    required User user,
    required String defaultSuburb,
  });
  Future<void> updateProfile({
    required String uid,
    String? displayName,
    String? suburb,
  });
}
