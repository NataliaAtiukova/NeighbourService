import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.phoneNumber,
    required this.suburb,
    required this.isPhoneVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  final String uid;
  final String displayName;
  final String phoneNumber;
  final String suburb;
  final bool isPhoneVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'suburb': suburb,
      'isPhoneVerified': isPhoneVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(String uid, Map<String, dynamic> data) {
    DateTime parseTimestamp(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return UserProfile(
      uid: uid,
      displayName: data['displayName'] as String? ?? 'You',
      phoneNumber: data['phoneNumber'] as String? ?? '',
      suburb: data['suburb'] as String? ?? 'Sea Point',
      isPhoneVerified: data['isPhoneVerified'] as bool? ?? false,
      createdAt: parseTimestamp(data['createdAt']),
      updatedAt: parseTimestamp(data['updatedAt']),
    );
  }

  UserProfile copyWith({
    String? displayName,
    String? phoneNumber,
    String? suburb,
    bool? isPhoneVerified,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      uid: uid,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      suburb: suburb ?? this.suburb,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
