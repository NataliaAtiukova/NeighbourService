import '../models/listing.dart';
import '../models/review.dart';

abstract class ListingsRepository {
  Future<List<Listing>> getAll();
  Future<ListingsPage> getPage({String? cursor, int limit});
  Future<Listing?> getById(String id);
  Future<List<Review>> getReviews(String listingId);
  Future<List<Review>> getAllReviews();
  Future<void> add(Listing listing);
  Future<void> update(Listing listing);
  Future<void> delete(String id);
}

class ListingsPage {
  const ListingsPage({required this.items, required this.nextCursor});

  final List<Listing> items;
  final String? nextCursor;
}
