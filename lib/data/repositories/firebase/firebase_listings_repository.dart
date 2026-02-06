import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../models/listing.dart';
import '../../models/review.dart';
import '../listings_repository.dart';
import '../../../shared/utils/constants.dart';

class FirebaseListingsRepository implements ListingsRepository {
  FirebaseListingsRepository(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _listingsCollection =>
      _firestore.collection('listings');
  CollectionReference<Map<String, dynamic>> _listingReviewsCollection(
    String listingId,
  ) =>
      _listingsCollection.doc(listingId).collection('reviews');

  @override
  Future<List<Listing>> getAll() async {
    final snapshot = await _listingsCollection
        .orderBy('clientCreatedAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => Listing.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<ListingsPage> fetchListings({
    required ListingsQuery query,
    String? cursor,
    int limit = 10,
  }) async {
    if (kDebugMode) {
      debugPrint(
        '[FeedQuery] suburb=${query.suburb}, categories=${query.categories}, '
        'worksDuringLoadShedding=${query.worksDuringLoadShedding}, '
        'needsElectricity=${query.needsElectricity}, '
        'search=${query.search}, sort=${query.sort}',
      );
    }

    Query<Map<String, dynamic>> firestoreQuery = _listingsCollection;

    if (query.suburb != null && query.suburb!.isNotEmpty) {
      firestoreQuery = firestoreQuery.where('suburb', isEqualTo: query.suburb);
    }
    if (query.categories.length == 1) {
      firestoreQuery = firestoreQuery.where(
        'category',
        isEqualTo: query.categories.first,
      );
    }

    firestoreQuery = firestoreQuery
        .orderBy('clientCreatedAt', descending: true)
        .limit(limit);

    if (cursor != null) {
      final cursorDoc = await _listingsCollection.doc(cursor).get();
      if (cursorDoc.exists) {
        firestoreQuery = firestoreQuery.startAfterDocument(cursorDoc);
      }
    }

    try {
      final snapshot = await firestoreQuery.get();
      var items = snapshot.docs
          .map((doc) => Listing.fromMap(doc.id, doc.data()))
          .toList();

      items = _applyClientFilters(items, query);

      final nextCursor = snapshot.docs.length == limit
          ? snapshot.docs.last.id
          : null;
      return ListingsPage(items: items, nextCursor: nextCursor);
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        debugPrint('[FeedQuery] fallback due to ${error.code}: ${error.message}');
      }
      final fallbackSnapshot = await _listingsCollection
          .orderBy('clientCreatedAt', descending: true)
          .limit(limit)
          .get();
      var items = fallbackSnapshot.docs
          .map((doc) => Listing.fromMap(doc.id, doc.data()))
          .toList();
      items = _applyClientFilters(items, query);
      final nextCursor = fallbackSnapshot.docs.length == limit
          ? fallbackSnapshot.docs.last.id
          : null;
      return ListingsPage(items: items, nextCursor: nextCursor);
    }
  }

  @override
  Future<Listing?> getById(String id) async {
    final doc = await _listingsCollection.doc(id).get();
    if (!doc.exists) return null;
    return Listing.fromMap(doc.id, doc.data()!);
  }

  @override
  Future<List<Listing>> getByOwner(String ownerUid) async {
    try {
      final snapshot = await _listingsCollection
          .where('ownerUid', isEqualTo: ownerUid)
          .orderBy('clientCreatedAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => Listing.fromMap(doc.id, doc.data()))
          .toList();
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        debugPrint(
          '[MyListings] fallback due to ${error.code}: ${error.message}',
        );
      }
      final snapshot = await _listingsCollection
          .where('ownerUid', isEqualTo: ownerUid)
          .get();
      return snapshot.docs
          .map((doc) => Listing.fromMap(doc.id, doc.data()))
          .toList();
    }
  }

  @override
  Future<List<Review>> getReviews(String listingId) async {
    final snapshot = await _listingReviewsCollection(listingId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Review(
        id: doc.id,
        listingId: data['listingId'] as String? ?? listingId,
        rating: (data['rating'] as num?)?.toDouble() ?? 0,
        text: data['text'] as String? ?? '',
        authorName: data['authorName'] as String? ?? 'Anonymous',
        createdAt:
            (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }).toList();
  }

  @override
  Future<List<Review>> getAllReviews() async {
    final snapshot = await _firestore
        .collectionGroup('reviews')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Review(
        id: doc.id,
        listingId: data['listingId'] as String? ?? '',
        rating: (data['rating'] as num?)?.toDouble() ?? 0,
        text: data['text'] as String? ?? '',
        authorName: data['authorName'] as String? ?? 'Anonymous',
        createdAt:
            (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }).toList();
  }

  @override
  Future<void> addReview(String listingId, Review review) async {
    await _listingReviewsCollection(listingId).add({
      'listingId': listingId,
      'rating': review.rating,
      'text': review.text,
      'authorName': review.authorName,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<String> add(Listing listing) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('User must be signed in to create listing.');
    }
    final docRef = await _listingsCollection.add({
      ...listing.toMap(),
      'ownerUid': user.uid,
      'isPhoneVerified': user.phoneNumber != null,
      'whatsappNumber': user.phoneNumber ?? listing.whatsappNumber,
      'createdAt': FieldValue.serverTimestamp(),
      'clientCreatedAt': Timestamp.now(),
    });
    return docRef.id;
  }

  @override
  Future<void> update(Listing listing) async {
    final data = Map<String, dynamic>.from(listing.toMap());
    data.remove('createdAt');
    await _listingsCollection.doc(listing.id).update({
      ...data,
      'ownerUid': listing.ownerUid,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> delete(String id) async {
    await _listingsCollection.doc(id).delete();
  }

  List<Listing> _applyClientFilters(
    List<Listing> listings,
    ListingsQuery query,
  ) {
    Iterable<Listing> result = listings;
    if (query.suburb != null && query.suburb!.isNotEmpty) {
      result = result.where((listing) => listing.suburb == query.suburb);
    }
    if (query.categories.isNotEmpty) {
      result = result.where(
        (listing) => query.categories.contains(listing.category),
      );
    }
    if (query.worksDuringLoadShedding != null) {
      result = result.where(
        (listing) =>
            listing.worksDuringLoadShedding == query.worksDuringLoadShedding,
      );
    }
    if (query.needsElectricity != null) {
      result = result.where(
        (listing) => listing.needsElectricity == query.needsElectricity,
      );
    }
    if (query.search != null && query.search!.trim().isNotEmpty) {
      final term = query.search!.toLowerCase();
      result = result.where((listing) {
        return listing.title.toLowerCase().contains(term) ||
            listing.description.toLowerCase().contains(term) ||
            listing.category.toLowerCase().contains(term) ||
            listing.suburb.toLowerCase().contains(term);
      });
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
