import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/models/listing.dart';
import 'data/models/review.dart';
import 'data/repositories/listings_repository.dart';
import 'data/repositories/mock/mock_listings_repository.dart';
import 'shared/utils/constants.dart';

final listingsRepositoryProvider = Provider<ListingsRepository>((ref) {
  return MockListingsRepository();
});

class ListingsController extends StateNotifier<AsyncValue<List<Listing>>> {
  ListingsController(this._repository) : super(const AsyncLoading()) {
    load();
  }

  final ListingsRepository _repository;

  Future<void> load() async {
    state = const AsyncLoading();
    try {
      final listings = await _repository.getAll();
      state = AsyncData(listings);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    await load();
  }

  Future<void> add(Listing listing) async {
    await _repository.add(listing);
    await load();
  }

  Future<void> update(Listing listing) async {
    await _repository.update(listing);
    await load();
  }

  Future<void> delete(String id) async {
    await _repository.delete(id);
    await load();
  }
}

final listingsControllerProvider =
    StateNotifierProvider<ListingsController, AsyncValue<List<Listing>>>(
  (ref) => ListingsController(ref.watch(listingsRepositoryProvider)),
);

final listingDetailsProvider =
    FutureProvider.family<Listing?, String>((ref, id) {
  return ref.watch(listingsRepositoryProvider).getById(id);
});

final reviewsProvider =
    FutureProvider.family<List<Review>, String>((ref, id) {
  return ref.watch(listingsRepositoryProvider).getReviews(id);
});

final allReviewsProvider = FutureProvider<List<Review>>((ref) {
  return ref.watch(listingsRepositoryProvider).getAllReviews();
});

class FiltersState {
  const FiltersState({
    this.search = '',
    this.categories = const {},
    this.worksDuringLoadSheddingOnly = false,
    this.noPowerNeededOnly = false,
    this.minPrice,
    this.maxPrice,
    this.sort = SortOption.recent,
  });

  final String search;
  final Set<String> categories;
  final bool worksDuringLoadSheddingOnly;
  final bool noPowerNeededOnly;
  final int? minPrice;
  final int? maxPrice;
  final SortOption sort;

  FiltersState copyWith({
    String? search,
    Set<String>? categories,
    bool? worksDuringLoadSheddingOnly,
    bool? noPowerNeededOnly,
    int? minPrice,
    int? maxPrice,
    SortOption? sort,
  }) {
    return FiltersState(
      search: search ?? this.search,
      categories: categories ?? this.categories,
      worksDuringLoadSheddingOnly:
          worksDuringLoadSheddingOnly ?? this.worksDuringLoadSheddingOnly,
      noPowerNeededOnly: noPowerNeededOnly ?? this.noPowerNeededOnly,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      sort: sort ?? this.sort,
    );
  }
}

class FiltersController extends StateNotifier<FiltersState> {
  FiltersController() : super(const FiltersState());

  void update(FiltersState state) => this.state = state;

  void reset() => state = const FiltersState();
}

final filtersProvider =
    StateNotifierProvider<FiltersController, FiltersState>(
  (ref) => FiltersController(),
);

final filteredListingsProvider = Provider<List<Listing>>((ref) {
  final listingsState = ref.watch(listingsControllerProvider);
  final filters = ref.watch(filtersProvider);
  return listingsState.maybeWhen(
    data: (listings) => _applyFilters(listings, filters),
    orElse: () => [],
  );
});

List<Listing> _applyFilters(List<Listing> listings, FiltersState filters) {
  Iterable<Listing> filtered = listings;
  if (filters.search.trim().isNotEmpty) {
    final term = filters.search.toLowerCase();
    filtered = filtered.where((listing) {
      return listing.title.toLowerCase().contains(term) ||
          listing.description.toLowerCase().contains(term) ||
          listing.category.toLowerCase().contains(term) ||
          listing.suburb.toLowerCase().contains(term);
    });
  }
  if (filters.categories.isNotEmpty) {
    filtered = filtered.where((listing) =>
        filters.categories.contains(listing.category));
  }
  if (filters.worksDuringLoadSheddingOnly) {
    filtered = filtered.where((listing) => listing.worksDuringLoadShedding);
  }
  if (filters.noPowerNeededOnly) {
    filtered = filtered.where((listing) => !listing.needsElectricity);
  }
  if (filters.minPrice != null) {
    filtered = filtered.where((listing) {
      if (listing.priceFrom == null) {
        return false;
      }
      return listing.priceFrom! >= filters.minPrice!;
    });
  }
  if (filters.maxPrice != null) {
    filtered = filtered.where((listing) {
      if (listing.priceFrom == null) {
        return false;
      }
      return listing.priceFrom! <= filters.maxPrice!;
    });
  }

  final result = filtered.toList();
  switch (filters.sort) {
    case SortOption.recent:
      result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      break;
    case SortOption.rating:
      result.sort((a, b) => b.rating.compareTo(a.rating));
      break;
    case SortOption.priceLowHigh:
      result.sort((a, b) {
        final aPrice = a.priceFrom ?? 999999;
        final bPrice = b.priceFrom ?? 999999;
        return aPrice.compareTo(bPrice);
      });
      break;
  }
  return result;
}

class FavoritesController extends StateNotifier<Set<String>> {
  FavoritesController() : super({});

  bool isFavorite(String id) => state.contains(id);

  void toggle(String id) {
    final next = Set<String>.from(state);
    if (!next.add(id)) {
      next.remove(id);
    }
    state = next;
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesController, Set<String>>(
  (ref) => FavoritesController(),
);

class SettingsState {
  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.suburb = 'Sea Point',
  });

  final ThemeMode themeMode;
  final String suburb;

  SettingsState copyWith({ThemeMode? themeMode, String? suburb}) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      suburb: suburb ?? this.suburb,
    );
  }
}

class SettingsController extends StateNotifier<SettingsState> {
  SettingsController() : super(const SettingsState());

  void updateTheme(ThemeMode themeMode) {
    state = state.copyWith(themeMode: themeMode);
  }

  void updateSuburb(String suburb) {
    state = state.copyWith(suburb: suburb);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsController, SettingsState>(
  (ref) => SettingsController(),
);

class UserProfileState {
  const UserProfileState({
    this.name = 'You',
    this.whatsappNumber = '+27825550123',
    this.isPhoneVerified = true,
    this.isAuthenticated = true,
  });

  final String name;
  final String whatsappNumber;
  final bool isPhoneVerified;
  final bool isAuthenticated;
}

final userProfileProvider = Provider<UserProfileState>((ref) {
  return const UserProfileState();
});
