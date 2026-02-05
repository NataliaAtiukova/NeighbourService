import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/user_profile.dart';
import '../user_profile_repository.dart';

class FirebaseUserProfileRepository implements UserProfileRepository {
  FirebaseUserProfileRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  @override
  Stream<UserProfile?> watchProfile(String uid) {
    return _usersCollection.doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return UserProfile.fromMap(snapshot.id, snapshot.data()!);
    });
  }

  @override
  Future<UserProfile> ensureProfile({
    required User user,
    required String defaultSuburb,
  }) async {
    final docRef = _usersCollection.doc(user.uid);
    final snapshot = await docRef.get();
    if (!snapshot.exists) {
      final profile = UserProfile(
        uid: user.uid,
        displayName: 'You',
        phoneNumber: user.phoneNumber ?? '',
        suburb: defaultSuburb,
        isPhoneVerified: user.phoneNumber != null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await docRef.set({
        'displayName': profile.displayName,
        'phoneNumber': profile.phoneNumber,
        'suburb': profile.suburb,
        'isPhoneVerified': profile.isPhoneVerified,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return profile;
    }

    final data = snapshot.data()!;
    final needsUpdate = (data['phoneNumber'] as String? ?? '') !=
            (user.phoneNumber ?? '') ||
        (data['isPhoneVerified'] as bool? ?? false) !=
            (user.phoneNumber != null);
    if (needsUpdate) {
      await docRef.update({
        'phoneNumber': user.phoneNumber ?? '',
        'isPhoneVerified': user.phoneNumber != null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    return UserProfile.fromMap(user.uid, data);
  }

  @override
  Future<void> updateProfile({
    required String uid,
    String? displayName,
    String? suburb,
  }) async {
    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (displayName != null) {
      updates['displayName'] = displayName;
    }
    if (suburb != null) {
      updates['suburb'] = suburb;
    }
    await _usersCollection.doc(uid).update(updates);
  }
}
