import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/models/listing.dart';
import 'data/models/review.dart';
import 'data/models/user_profile.dart';
import 'data/repositories/listings_repository.dart';
import 'data/repositories/firebase/firebase_listings_repository.dart';
import 'data/repositories/mock/mock_listings_repository.dart';
import 'data/repositories/firebase/firebase_user_profile_repository.dart';
import 'data/repositories/user_profile_repository.dart';
import 'shared/utils/constants.dart';

final listingsRepositoryProvider = Provider<ListingsRepository>((ref) {
  final useFirebase = Firebase.apps.isNotEmpty;
  if (useFirebase) {
    return FirebaseListingsRepository(
      FirebaseFirestore.instance,
      FirebaseAuth.instance,
    );
  }
  return MockListingsRepository();
});

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return FirebaseUserProfileRepository(FirebaseFirestore.instance);
});

class ListingsController extends StateNotifier<AsyncValue<List<Listing>>> {
  ListingsController(this._ref, this._repository)
      : super(const AsyncLoading()) {
    load();
  }

  final Ref _ref;
  final ListingsRepository _repository;
  String? _cursor;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  Future<void> load() async {
    state = const AsyncLoading();
    try {
      _cursor = null;
      _hasMore = true;
      final page = await _repository.fetchListings(
        query: _currentQuery(),
        limit: 10,
      );
      _cursor = page.nextCursor;
      _hasMore = _cursor != null;
      state = AsyncData(page.items);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    await load();
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    try {
      final page = await _repository.fetchListings(
        query: _currentQuery(),
        cursor: _cursor,
        limit: 10,
      );
      _cursor = page.nextCursor;
      _hasMore = _cursor != null;
      state = state.whenData((items) => [...items, ...page.items]);
    } finally {
      _isLoadingMore = false;
    }
  }

  ListingsQuery _currentQuery() {
    final filters = _ref.read(filtersProvider);
    final suburb = _ref.read(currentSuburbProvider);
    return ListingsQuery(
      search: filters.search,
      categories: filters.categories,
      suburb: suburb,
      worksDuringLoadShedding: filters.worksDuringLoadSheddingOnly ? true : null,
      needsElectricity: filters.noPowerNeededOnly ? false : null,
      minPrice: filters.minPrice,
      maxPrice: filters.maxPrice,
      sort: filters.sort,
    );
  }

  Future<String> add(Listing listing) async {
    final id = await _repository.add(listing);
    await load();
    return id;
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
  (ref) {
    final controller =
        ListingsController(ref, ref.watch(listingsRepositoryProvider));
    ref.listen(filtersProvider, (_, __) => controller.load());
    ref.listen(settingsProvider, (_, __) => controller.load());
    ref.listen(userProfileProvider, (_, __) => controller.load());
    return controller;
  },
);

final listingDetailsProvider =
    FutureProvider.family<Listing?, String>((ref, id) {
  return ref.watch(listingsRepositoryProvider).getById(id);
});

final myListingsProvider =
    FutureProvider.family<List<Listing>, String>((ref, ownerUid) {
  return ref.watch(listingsRepositoryProvider).getByOwner(ownerUid);
});

final reviewsProvider =
    FutureProvider.family<List<Review>, String>((ref, id) {
  return ref.watch(listingsRepositoryProvider).getReviews(id);
});

final allReviewsProvider = FutureProvider<List<Review>>((ref) {
  return ref.watch(listingsRepositoryProvider).getAllReviews();
});

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authStateProvider = StreamProvider<User?>((ref) {
  if (Firebase.apps.isEmpty) {
    return Stream<User?>.value(null);
  }
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final user = ref.watch(authStateProvider).asData?.value;
  if (user == null) {
    return Stream<UserProfile?>.value(null);
  }
  return ref.watch(userProfileRepositoryProvider).watchProfile(user.uid);
});

enum ProfileStatus { loading, signedOut, ready }

final profileBootstrapProvider = FutureProvider<void>((ref) async {
  final auth = ref.watch(authStateProvider);
  if (auth.isLoading) return;
  final user = auth.asData?.value;
  if (user == null) return;

  final repo = ref.watch(userProfileRepositoryProvider);
  final existing = await repo.getProfile(user.uid);
  if (existing != null) return;

  final settings = ref.read(settingsProvider);
  await repo.createProfile(
    uid: user.uid,
    displayName: 'You',
    phoneNumber: user.phoneNumber ?? '',
    suburb: settings.suburb,
    isPhoneVerified: true,
  );
});

final profileStatusProvider = Provider<ProfileStatus>((ref) {
  final auth = ref.watch(authStateProvider);
  if (auth.isLoading) return ProfileStatus.loading;
  final user = auth.asData?.value;
  if (user == null) return ProfileStatus.signedOut;
  final bootstrap = ref.watch(profileBootstrapProvider);
  if (bootstrap.isLoading) return ProfileStatus.loading;
  return ProfileStatus.ready;
});

final currentSuburbProvider = Provider<String>((ref) {
  final profile = ref.watch(userProfileProvider).asData?.value;
  return profile?.suburb ?? ref.watch(settingsProvider).suburb;
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
  return listingsState.maybeWhen(
    data: (listings) => listings,
    orElse: () => [],
  );
});

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
    this.themeMode = ThemeMode.dark,
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
