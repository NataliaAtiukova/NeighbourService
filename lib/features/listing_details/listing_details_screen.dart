import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_providers.dart';
import '../../shared/utils/formatters.dart';
import '../../shared/utils/launchers.dart';
import '../../shared/widgets/skeletons.dart';

class ListingDetailsScreen extends ConsumerWidget {
  const ListingDetailsScreen({super.key, required this.listingId});

  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingAsync = ref.watch(listingDetailsProvider(listingId));
    final reviewsAsync = ref.watch(reviewsProvider(listingId));
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Listing details')),
      bottomNavigationBar: listingAsync.when(
        data: (listing) {
          if (listing == null) {
            return const SizedBox.shrink();
          }
          final isFavorite = favorites.contains(listingId);
          return SafeArea(
            minimum: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => launchWhatsApp(listing.whatsappNumber),
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('WhatsApp'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        ref.read(favoritesProvider.notifier).toggle(listingId),
                    icon: Icon(
                        isFavorite ? Icons.bookmark : Icons.bookmark_border),
                    label: Text(isFavorite ? 'Saved' : 'Save'),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
      body: listingAsync.when(
        loading: () => const DetailsSkeleton(),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 12),
                const Text('Unable to load listing details'),
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
        data: (listing) {
          if (listing == null) {
            return const Center(child: Text('Listing not found'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(listing.title,
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(label: Text(listing.category)),
                  Chip(
                    avatar: const Icon(Icons.place_outlined, size: 16),
                    label: Text(listing.suburb),
                  ),
                  if (listing.isPhoneVerified)
                    Chip(
                      avatar: const Icon(Icons.verified, size: 16),
                      label: const Text('Verified'),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber.shade700, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    formatRating(listing.rating, listing.reviewsCount),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Details', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(listing.description),
              const SizedBox(height: 12),
              Text(
                formatPrice(listing.priceFrom),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text('Availability',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(extractAvailability(listing.description)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    label: Text(listing.worksDuringLoadShedding
                        ? 'Works during load-shedding'
                        : 'Not load-shedding ready'),
                  ),
                  Chip(
                    label: Text(listing.needsElectricity
                        ? 'Needs electricity'
                        : 'No power needed'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Reviews', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              reviewsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: LinearProgressIndicator(),
                ),
                error: (error, _) => const Text('Unable to load reviews'),
                data: (reviews) {
                  if (reviews.isEmpty) {
                    return const Text('No reviews yet.');
                  }
                  final topReviews = reviews.take(3).toList();
                  return Column(
                    children: topReviews
                        .map(
                          (review) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(review.authorName),
                            subtitle: Text(review.text),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star,
                                    size: 16,
                                    color: Colors.amber.shade700),
                                const SizedBox(width: 4),
                                Text(review.rating.toString()),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }
}
