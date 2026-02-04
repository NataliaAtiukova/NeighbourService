import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/listing.dart';
import '../../models/review.dart';
import '../listings_repository.dart';

class FirebaseListingsRepository implements ListingsRepository {
  FirebaseListingsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _listingsCollection =>
      _firestore.collection('listings');
  CollectionReference<Map<String, dynamic>> get _reviewsCollection =>
      _firestore.collection('reviews');

  @override
  Future<List<Listing>> getAll() async {
    final snapshot = await _listingsCollection
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => Listing.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<ListingsPage> getPage({String? cursor, int limit = 10}) async {
    Query<Map<String, dynamic>> query = _listingsCollection
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (cursor != null) {
      final cursorDoc = await _listingsCollection.doc(cursor).get();
      if (cursorDoc.exists) {
        query = query.startAfterDocument(cursorDoc);
      }
    }

    final snapshot = await query.get();
    final items = snapshot.docs
        .map((doc) => Listing.fromMap(doc.id, doc.data()))
        .toList();
    final nextCursor = snapshot.docs.length == limit
        ? snapshot.docs.last.id
        : null;
    return ListingsPage(items: items, nextCursor: nextCursor);
  }

  @override
  Future<Listing?> getById(String id) async {
    final doc = await _listingsCollection.doc(id).get();
    if (!doc.exists) return null;
    return Listing.fromMap(doc.id, doc.data()!);
  }

  @override
  Future<List<Review>> getReviews(String listingId) async {
    final snapshot = await _reviewsCollection
        .where('listingId', isEqualTo: listingId)
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
    final snapshot = await _reviewsCollection
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
  Future<void> add(Listing listing) async {
    await _listingsCollection.add({
      ...listing.toMap(),
      'createdAt': Timestamp.fromDate(listing.createdAt),
    });
  }

  @override
  Future<void> update(Listing listing) async {
    await _listingsCollection.doc(listing.id).update({
      ...listing.toMap(),
      'createdAt': Timestamp.fromDate(listing.createdAt),
    });
  }

  @override
  Future<void> delete(String id) async {
    await _listingsCollection.doc(id).delete();
  }
}
