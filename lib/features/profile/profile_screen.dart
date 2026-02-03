import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app_providers.dart';
import '../../shared/utils/constants.dart';
import '../../shared/utils/formatters.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider);
    final listingsState = ref.watch(listingsControllerProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: listingsState.when(
        data: (listings) {
          if (!user.isAuthenticated) {
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
                      onPressed: () {},
                      child: const Text('Sign in'),
                    ),
                  ],
                ),
              ),
            );
          }
          final myListings = listings
              .where((listing) => listing.whatsappNumber == user.whatsappNumber)
              .toList();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                title: Text(user.name),
                subtitle: Text(user.whatsappNumber),
                trailing: user.isPhoneVerified
                    ? const Chip(
                        label: Text('Phone verified'),
                        avatar: Icon(Icons.verified, size: 16),
                      )
                    : const Chip(label: Text('Unverified')),
              ),
              const SizedBox(height: 16),
              Text('My listings',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (myListings.isEmpty)
                Card(
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
                )
              else
                ...myListings.map(
                  (listing) => Card(
                    child: ListTile(
                      title: Text(listing.title),
                      subtitle: Text(formatPrice(listing.priceFrom)),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () =>
                                context.go('/post/edit/${listing.id}'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              await ref
                                  .read(listingsControllerProvider.notifier)
                                  .delete(listing.id);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Listing deleted')),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              Text('Reviews received',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _ReviewsSection(listingIds: myListings.map((e) => e.id).toList()),
              const SizedBox(height: 24),
              Text('Settings',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: settings.suburb,
                decoration: const InputDecoration(labelText: 'Suburb'),
                items: kSuburbs
                    .map(
                      (suburb) => DropdownMenuItem(
                        value: suburb,
                        child: Text(suburb),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  ref.read(settingsProvider.notifier).updateSuburb(value);
                },
              ),
              const SizedBox(height: 12),
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
                  onPressed: () =>
                      ref.read(listingsControllerProvider.notifier).load(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
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
