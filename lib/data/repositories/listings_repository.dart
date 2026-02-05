import '../../shared/utils/constants.dart';
import '../models/listing.dart';
import '../models/review.dart';

abstract class ListingsRepository {
  Future<List<Listing>> getAll();
  Future<ListingsPage> fetchListings({
    required ListingsQuery query,
    String? cursor,
    int limit,
  });
  Future<Listing?> getById(String id);
  Future<List<Listing>> getByOwner(String ownerUid);
  Future<List<Review>> getReviews(String listingId);
  Future<List<Review>> getAllReviews();
  Future<void> addReview(String listingId, Review review);
  Future<String> add(Listing listing);
  Future<void> update(Listing listing);
  Future<void> delete(String id);
}

class ListingsPage {
  const ListingsPage({required this.items, required this.nextCursor});

  final List<Listing> items;
  final String? nextCursor;
}

class ListingsQuery {
  const ListingsQuery({
    this.search,
    this.categories = const {},
    this.suburb,
    this.worksDuringLoadShedding,
    this.needsElectricity,
    this.minPrice,
    this.maxPrice,
    this.sort = SortOption.recent,
  });

  final String? search;
  final Set<String> categories;
  final String? suburb;
  final bool? worksDuringLoadShedding;
  final bool? needsElectricity;
  final int? minPrice;
  final int? maxPrice;
  final SortOption sort;
}
