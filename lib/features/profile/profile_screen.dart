import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app_providers.dart';
import '../../shared/utils/constants.dart';
import '../../shared/utils/formatters.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  bool _didInitName = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final authState = ref.watch(authStateProvider);
    final firebaseUser = authState.asData?.value;
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Builder(
        builder: (context) {
          if (firebaseUser == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline, size: 48),
                    const SizedBox(height: 12),
                    const Text('Sign in to manage your profile'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => context.go('/auth/phone'),
                      child: const Text('Sign in'),
                    ),
                  ],
                ),
              ),
            );
          }

          return profileAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 12),
                    const Text('Unable to load profile data'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => ref.invalidate(userProfileProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
            data: (profile) {
              if (profile == null) {
                return const Center(child: Text('Profile not available'));
              }
              if (!_didInitName) {
                _nameController.text = profile.displayName;
                _didInitName = true;
              }
              final myListingsAsync =
                  ref.watch(myListingsProvider(firebaseUser.uid));
              final displayNumber =
                  firebaseUser.phoneNumber ?? profile.phoneNumber;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ListTile(
                    leading:
                        const CircleAvatar(child: Icon(Icons.person_outline)),
                    title: Text(profile.displayName),
                    subtitle: Text(displayNumber),
                    trailing: profile.isPhoneVerified
                        ? const Chip(
                            label: Text('Phone verified'),
                            avatar: Icon(Icons.verified, size: 16),
                          )
                        : const Chip(label: Text('Unverified')),
                  ),
                  const SizedBox(height: 12),
                  Text('Display name',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: () async {
                          final name = _nameController.text.trim();
                          if (name.isEmpty) return;
                          final messenger = ScaffoldMessenger.of(context);
                          await ref
                              .read(userProfileRepositoryProvider)
                              .updateProfile(
                                uid: profile.uid,
                                displayName: name,
                              );
                          if (!mounted) return;
                          messenger.showSnackBar(
                            const SnackBar(
                                content: Text('Name updated successfully')),
                          );
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Suburb',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: profile.suburb,
                    decoration: const InputDecoration(labelText: 'Suburb'),
                    items: kSuburbs
                        .map(
                          (suburb) => DropdownMenuItem(
                            value: suburb,
                            child: Text(suburb),
                          ),
                        )
                        .toList(),
                    onChanged: (value) async {
                      if (value == null) return;
                      final messenger = ScaffoldMessenger.of(context);
                      await ref
                          .read(userProfileRepositoryProvider)
                          .updateProfile(uid: profile.uid, suburb: value);
                      ref.read(settingsProvider.notifier).updateSuburb(value);
                      if (!mounted) return;
                      messenger.showSnackBar(
                        const SnackBar(
                            content: Text('Suburb updated successfully')),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('My listings',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  myListingsAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (error, _) => const Text('Unable to load listings'),
                    data: (myListings) {
                      if (myListings.isEmpty) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('No listings yet'),
                                const SizedBox(height: 8),
                                FilledButton(
                                  onPressed: () => context.go('/post'),
                                  child: const Text('Create listing'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: myListings
                            .map(
                              (listing) => Card(
                                child: ListTile(
                                  title: Text(listing.title),
                                  subtitle: Text(formatPrice(listing.priceFrom)),
                                  trailing: Wrap(
                                    spacing: 8,
                                    children: [
                                      IconButton(
                                        icon:
                                            const Icon(Icons.edit_outlined),
                                        onPressed: () => context
                                            .go('/post/edit/${listing.id}'),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline),
                                        onPressed: () async {
                                          final confirmed = await showDialog<
                                              bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Delete listing'),
                                              content: const Text(
                                                  'Are you sure you want to delete this listing?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(false),
                                                  child: const Text('Cancel'),
                                                ),
                                                FilledButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(true),
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirmed != true) return;
                                          await ref
                                              .read(listingsControllerProvider
                                                  .notifier)
                                              .delete(listing.id);
                                          ref.invalidate(myListingsProvider(
                                              firebaseUser.uid));
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content:
                                                    Text('Listing deleted')),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text('Reviews received',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  _ReviewsSection(
                    listingIds: myListingsAsync.maybeWhen(
                      data: (items) => items.map((e) => e.id).toList(),
                      orElse: () => const [],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Settings',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Dark mode'),
                    value: settings.themeMode == ThemeMode.dark,
                    onChanged: (value) {
                      ref
                          .read(settingsProvider.notifier)
                          .updateTheme(value ? ThemeMode.dark : ThemeMode.light);
                    },
                  ),
                  const SizedBox(height: 80),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _ReviewsSection extends ConsumerWidget {
  const _ReviewsSection({required this.listingIds});

  final List<String> listingIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (listingIds.isEmpty) {
      return const Text('No reviews yet.');
    }
    final reviewsAsync = ref.watch(allReviewsProvider);
    return reviewsAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (error, _) => const Text('Unable to load reviews'),
      data: (reviews) {
        final myReviews = reviews
            .where((review) => listingIds.contains(review.listingId))
            .toList();
        if (myReviews.isEmpty) {
          return const Text('No reviews yet.');
        }
        return Column(
          children: myReviews
              .take(3)
              .map(
                (review) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(review.authorName),
                  subtitle: Text(review.text),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber.shade700),
                      const SizedBox(width: 4),
                      Text(review.rating.toString()),
                    ],
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}
