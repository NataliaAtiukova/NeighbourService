enum ListingType { provider, looking }

class Listing {
  const Listing({
    required this.id,
    required this.type,
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

  Listing copyWith({
    String? id,
    ListingType? type,
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
