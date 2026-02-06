import 'package:cloud_firestore/cloud_firestore.dart';
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
  Future<UserProfile?> getProfile(String uid) async {
    final snapshot = await _usersCollection.doc(uid).get();
    if (!snapshot.exists) return null;
    return UserProfile.fromMap(snapshot.id, snapshot.data()!);
  }

  @override
  Future<void> createProfile({
    required String uid,
    required String displayName,
    required String phoneNumber,
    required String suburb,
    required bool isPhoneVerified,
  }) async {
    final docRef = _usersCollection.doc(uid);
    final snapshot = await docRef.get();
    final data = <String, dynamic>{
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'suburb': suburb,
      'isPhoneVerified': isPhoneVerified,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (!snapshot.exists) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }
    await docRef.set(data, SetOptions(merge: true));
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
    await _usersCollection.doc(uid).set(updates, SetOptions(merge: true));
  }
}
