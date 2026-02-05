import 'dart:async';

import '../../models/listing.dart';
import '../../models/review.dart';
import '../listings_repository.dart';
import '../../../shared/utils/constants.dart';

class MockListingsRepository implements ListingsRepository {
  MockListingsRepository() {
    _listings = _seedListings();
    _reviews = _seedReviews();
  }

  late List<Listing> _listings;
  late List<Review> _reviews;

  @override
  Future<List<Listing>> getAll() async {
    return List<Listing>.from(_listings);
  }

  @override
  Future<ListingsPage> fetchListings({
    required ListingsQuery query,
    String? cursor,
    int limit = 10,
  }) async {
    final filtered = _applyQuery(_listings, query);
    int startIndex = 0;
    if (cursor != null) {
      final index = filtered.indexWhere((listing) => listing.id == cursor);
      if (index != -1) {
        startIndex = index + 1;
      }
    }
    final pageItems = filtered.skip(startIndex).take(limit).toList();
    final nextCursor = pageItems.length == limit ? pageItems.last.id : null;
    return ListingsPage(items: pageItems, nextCursor: nextCursor);
  }

  @override
  Future<Listing?> getById(String id) async {
    return _listings.where((listing) => listing.id == id).firstOrNull;
  }

  @override
  Future<List<Listing>> getByOwner(String ownerUid) async {
    return _listings
        .where((listing) => listing.ownerUid == ownerUid)
        .toList();
  }

  @override
  Future<List<Review>> getReviews(String listingId) async {
    return _reviews
        .where((review) => review.listingId == listingId)
        .toList();
  }

  @override
  Future<List<Review>> getAllReviews() async {
    return List<Review>.from(_reviews);
  }

  @override
  Future<void> addReview(String listingId, Review review) async {
    _reviews.add(review);
  }

  @override
  Future<String> add(Listing listing) async {
    _listings.insert(0, listing);
    return listing.id;
  }

  @override
  Future<void> update(Listing listing) async {
    _listings = _listings
        .map((item) => item.id == listing.id ? listing : item)
        .toList();
  }

  @override
  Future<void> delete(String id) async {
    _listings.removeWhere((listing) => listing.id == id);
    _reviews.removeWhere((review) => review.listingId == id);
  }

  List<Listing> _seedListings() {
    final now = DateTime.now();
    return [
      Listing(
        id: '1',
        type: ListingType.provider,
        ownerUid: 'user_1',
        category: 'Cleaning',
        title: 'Reliable home cleaning service',
        description:
            'Deep cleaning for apartments and houses. Eco-friendly products.',
        priceFrom: 250,
        suburb: 'Sea Point',
        worksDuringLoadShedding: true,
        needsElectricity: false,
        rating: 4.7,
        reviewsCount: 24,
        isPhoneVerified: true,
        whatsappNumber: '+27821234567',
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
      Listing(
        id: '2',
        type: ListingType.provider,
        ownerUid: 'user_2',
        category: 'Repair',
        title: 'Handyman for quick fixes',
        description: 'Doors, cupboards, shelves, and small repairs.',
        priceFrom: 180,
        suburb: 'Green Point',
        worksDuringLoadShedding: true,
        needsElectricity: true,
        rating: 4.3,
        reviewsCount: 12,
        isPhoneVerified: true,
        whatsappNumber: '+27829876543',
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
      ),
      Listing(
        id: '3',
        type: ListingType.looking,
        ownerUid: 'user_3',
        category: 'Plumbing',
        title: 'Need urgent leak repair',
        description: 'Burst pipe in kitchen, need help today.',
        priceFrom: null,
        suburb: 'Woodstock',
        worksDuringLoadShedding: true,
        needsElectricity: false,
        rating: 0,
        reviewsCount: 0,
        isPhoneVerified: false,
        whatsappNumber: '+27823334455',
        createdAt: now.subtract(const Duration(hours: 6)),
      ),
      Listing(
        id: '4',
        type: ListingType.provider,
        ownerUid: 'user_4',
        category: 'Water/Gas Delivery',
        title: 'Water delivery in 2 hours',
        description: '20L water delivery across Atlantic seaboard.',
        priceFrom: 80,
        suburb: 'Camps Bay',
        worksDuringLoadShedding: true,
        needsElectricity: false,
        rating: 4.9,
        reviewsCount: 38,
        isPhoneVerified: true,
        whatsappNumber: '+27821112233',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      Listing(
        id: '5',
        type: ListingType.provider,
        ownerUid: 'user_5',
        category: 'Babysitting',
        title: 'Evening babysitter available',
        description: 'Certified nanny, available weekdays after 5pm.',
        priceFrom: 150,
        suburb: 'Sea Point',
        worksDuringLoadShedding: false,
        needsElectricity: false,
        rating: 4.8,
        reviewsCount: 17,
        isPhoneVerified: true,
        whatsappNumber: '+27827778899',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      Listing(
        id: '6',
        type: ListingType.provider,
        ownerUid: 'user_6',
        category: 'Pet-sitting',
        title: 'Dog walking and pet care',
        description: 'Daily walks and feeding while you are away.',
        priceFrom: 120,
        suburb: 'Gardens',
        worksDuringLoadShedding: true,
        needsElectricity: false,
        rating: 4.5,
        reviewsCount: 9,
        isPhoneVerified: true,
        whatsappNumber: '+27820001122',
        createdAt: now.subtract(const Duration(hours: 18)),
      ),
      Listing(
        id: '7',
        type: ListingType.looking,
        ownerUid: 'user_7',
        category: 'Cleaning',
        title: 'Looking for weekly cleaner',
        description: 'Two-bedroom apartment, need Friday mornings.',
        priceFrom: 200,
        suburb: 'Tamboerskloof',
        worksDuringLoadShedding: false,
        needsElectricity: false,
        rating: 0,
        reviewsCount: 0,
        isPhoneVerified: false,
        whatsappNumber: '+27824445566',
        createdAt: now.subtract(const Duration(days: 1, hours: 6)),
      ),
      Listing(
        id: '8',
        type: ListingType.provider,
        ownerUid: 'user_8',
        category: 'Plumbing',
        title: 'Qualified plumber on call',
        description: 'Geysers, leaks, and installations.',
        priceFrom: 350,
        suburb: 'Observatory',
        worksDuringLoadShedding: true,
        needsElectricity: true,
        rating: 4.6,
        reviewsCount: 21,
        isPhoneVerified: true,
        whatsappNumber: '+27821119988',
        createdAt: now.subtract(const Duration(hours: 12)),
      ),
      Listing(
        id: '9',
        type: ListingType.provider,
        ownerUid: 'user_9',
        category: 'Repair',
        title: 'Mobile phone screen repair',
        description: 'Same-day screen replacement for most models.',
        priceFrom: 500,
        suburb: 'CBD',
        worksDuringLoadShedding: false,
        needsElectricity: true,
        rating: 4.2,
        reviewsCount: 6,
        isPhoneVerified: true,
        whatsappNumber: '+27826667777',
        createdAt: now.subtract(const Duration(days: 2, hours: 5)),
      ),
      Listing(
        id: '10',
        type: ListingType.provider,
        ownerUid: 'user_10',
        category: 'Water/Gas Delivery',
        title: 'Gas cylinder refill & swap',
        description: '9kg and 19kg refills, delivery included.',
        priceFrom: 240,
        suburb: 'Claremont',
        worksDuringLoadShedding: true,
        needsElectricity: false,
        rating: 4.4,
        reviewsCount: 14,
        isPhoneVerified: true,
        whatsappNumber: '+27823330011',
        createdAt: now.subtract(const Duration(days: 4)),
      ),
      Listing(
        id: '11',
        type: ListingType.looking,
        ownerUid: 'user_11',
        category: 'Babysitting',
        title: 'Need sitter for Saturday night',
        description: 'Two kids, ages 5 and 8. 6pm - 11pm.',
        priceFrom: 180,
        suburb: 'Kenilworth',
        worksDuringLoadShedding: false,
        needsElectricity: false,
        rating: 0,
        reviewsCount: 0,
        isPhoneVerified: false,
        whatsappNumber: '+27825556677',
        createdAt: now.subtract(const Duration(hours: 20)),
      ),
      Listing(
        id: '12',
        type: ListingType.provider,
        ownerUid: 'user_12',
        category: 'Pet-sitting',
        title: 'Overnight pet sitting',
        description: 'Experienced sitter for dogs and cats.',
        priceFrom: 220,
        suburb: 'Rondebosch',
        worksDuringLoadShedding: true,
        needsElectricity: false,
        rating: 4.9,
        reviewsCount: 31,
        isPhoneVerified: true,
        whatsappNumber: '+27829998877',
        createdAt: now.subtract(const Duration(hours: 30)),
      ),
    ];
  }

  List<Review> _seedReviews() {
    final now = DateTime.now();
    return [
      Review(
        id: 'r1',
        listingId: '1',
        rating: 5,
        text: 'Spotless clean and right on time.',
        authorName: 'Ayanda',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      Review(
        id: 'r2',
        listingId: '1',
        rating: 4.5,
        text: 'Great attention to detail.',
        authorName: 'Dylan',
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      Review(
        id: 'r3',
        listingId: '4',
        rating: 5,
        text: 'Fast delivery, friendly driver.',
        authorName: 'Kim',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      Review(
        id: 'r4',
        listingId: '8',
        rating: 4,
        text: 'Fixed the geyser quickly.',
        authorName: 'Raj',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Review(
        id: 'r5',
        listingId: '12',
        rating: 5,
        text: 'Pets loved the overnight care.',
        authorName: 'Maya',
        createdAt: now.subtract(const Duration(days: 4)),
      ),
    ];
  }

  List<Listing> _applyQuery(List<Listing> listings, ListingsQuery query) {
    Iterable<Listing> result = listings;
    if (query.search != null && query.search!.trim().isNotEmpty) {
      final term = query.search!.toLowerCase();
      result = result.where((listing) {
        return listing.title.toLowerCase().contains(term) ||
            listing.description.toLowerCase().contains(term) ||
            listing.category.toLowerCase().contains(term) ||
            listing.suburb.toLowerCase().contains(term);
      });
    }
    if (query.suburb != null && query.suburb!.isNotEmpty) {
      result = result.where((listing) => listing.suburb == query.suburb);
    }
    if (query.categories.isNotEmpty) {
      result = result.where((listing) => query.categories.contains(
            listing.category,
          ));
    }
    if (query.worksDuringLoadShedding == true) {
      result = result.where((listing) => listing.worksDuringLoadShedding);
    }
    if (query.needsElectricity == false) {
      result = result.where((listing) => !listing.needsElectricity);
    }
    if (query.minPrice != null) {
      result = result.where((listing) {
        if (listing.priceFrom == null) return false;
        return listing.priceFrom! >= query.minPrice!;
      });
    }
    if (query.maxPrice != null) {
      result = result.where((listing) {
        if (listing.priceFrom == null) return false;
        return listing.priceFrom! <= query.maxPrice!;
      });
    }
    final list = result.toList();
    switch (query.sort) {
      case SortOption.recent:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.rating:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortOption.priceLowHigh:
        list.sort((a, b) {
          final aPrice = a.priceFrom ?? 999999;
          final bPrice = b.priceFrom ?? 999999;
          return aPrice.compareTo(bPrice);
        });
        break;
    }
    return list;
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
