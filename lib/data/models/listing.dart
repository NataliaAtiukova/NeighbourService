import 'package:cloud_firestore/cloud_firestore.dart';

enum ListingType { provider, looking }

class Listing {
  const Listing({
    required this.id,
    required this.type,
    required this.ownerUid,
    required this.category,
    required this.title,
    required this.description,
    required this.priceFrom,
    this.currency = 'ZAR',
    required this.suburb,
    required this.worksDuringLoadShedding,
    required this.needsElectricity,
    required this.rating,
    required this.reviewsCount,
    required this.isPhoneVerified,
    required this.whatsappNumber,
    required this.createdAt,
  });

  final String id;
  final ListingType type;
  final String ownerUid;
  final String category;
  final String title;
  final String description;
  final int? priceFrom;
  final String currency;
  final String suburb;
  final bool worksDuringLoadShedding;
  final bool needsElectricity;
  final double rating;
  final int reviewsCount;
  final bool isPhoneVerified;
  final String whatsappNumber;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'ownerUid': ownerUid,
      'category': category,
      'title': title,
      'description': description,
      'priceFrom': priceFrom,
      'currency': currency,
      'suburb': suburb,
      'worksDuringLoadShedding': worksDuringLoadShedding,
      'needsElectricity': needsElectricity,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'isPhoneVerified': isPhoneVerified,
      'whatsappNumber': whatsappNumber,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Listing.fromMap(String id, Map<String, dynamic> data) {
    final createdAtValue = data['createdAt'];
    final clientCreatedAtValue = data['clientCreatedAt'];
    DateTime createdAt;
    if (createdAtValue is DateTime) {
      createdAt = createdAtValue;
    } else if (createdAtValue is String) {
      createdAt = DateTime.tryParse(createdAtValue) ?? DateTime.now();
    } else if (createdAtValue is Timestamp) {
      createdAt = createdAtValue.toDate();
    } else if (clientCreatedAtValue is Timestamp) {
      createdAt = clientCreatedAtValue.toDate();
    } else if (clientCreatedAtValue is int) {
      createdAt = DateTime.fromMillisecondsSinceEpoch(clientCreatedAtValue);
    } else {
      createdAt = DateTime.now();
    }

    return Listing(
      id: id,
      type: ListingType.values.firstWhere(
        (value) => value.name == data['type'],
        orElse: () => ListingType.provider,
      ),
      ownerUid: data['ownerUid'] as String? ?? '',
      category: data['category'] as String? ?? 'Cleaning',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      priceFrom: data['priceFrom'] as int?,
      currency: data['currency'] as String? ?? 'ZAR',
      suburb: data['suburb'] as String? ?? '',
      worksDuringLoadShedding:
          data['worksDuringLoadShedding'] as bool? ?? false,
      needsElectricity: data['needsElectricity'] as bool? ?? false,
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
      reviewsCount: data['reviewsCount'] as int? ?? 0,
      isPhoneVerified: data['isPhoneVerified'] as bool? ?? false,
      whatsappNumber: data['whatsappNumber'] as String? ?? '',
      createdAt: createdAt,
    );
  }

  Listing copyWith({
    String? id,
    ListingType? type,
    String? ownerUid,
    String? category,
    String? title,
    String? description,
    int? priceFrom,
    String? currency,
    String? suburb,
    bool? worksDuringLoadShedding,
    bool? needsElectricity,
    double? rating,
    int? reviewsCount,
    bool? isPhoneVerified,
    String? whatsappNumber,
    DateTime? createdAt,
  }) {
    return Listing(
      id: id ?? this.id,
      type: type ?? this.type,
      ownerUid: ownerUid ?? this.ownerUid,
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      priceFrom: priceFrom ?? this.priceFrom,
      currency: currency ?? this.currency,
      suburb: suburb ?? this.suburb,
      worksDuringLoadShedding:
          worksDuringLoadShedding ?? this.worksDuringLoadShedding,
      needsElectricity: needsElectricity ?? this.needsElectricity,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
