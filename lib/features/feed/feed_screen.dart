import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app_providers.dart';
import '../../shared/utils/constants.dart';
import '../../shared/utils/launchers.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/skeletons.dart';
import 'filters_bottom_sheet.dart';
import 'listing_card.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsState = ref.watch(listingsControllerProvider);
    final listings = ref.watch(filteredListingsProvider);
    final suburb = ref.watch(settingsProvider).suburb;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Neighbour Services'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(suburb),
              avatar: const Icon(Icons.place_outlined),
              onPressed: () {
                context.go('/profile');
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                showDragHandle: true,
                builder: (_) => const FiltersBottomSheet(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _FilterRow(onOpenFilters: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              showDragHandle: true,
              builder: (_) => const FiltersBottomSheet(),
            );
          }),
          Expanded(
            child: listingsState.when(
              loading: () => ListView.separated(
                padding: const EdgeInsets.all(16),
                itemBuilder: (_, __) => const ListingCardSkeleton(),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: 6,
              ),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.wifi_off, size: 48),
                      const SizedBox(height: 12),
                      const Text('Unable to load listings'),
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
              data: (_) {
                if (listings.isEmpty) {
                  return EmptyState(
                    title: 'No listings yet',
                    message:
                        'Be the first to post a service in your area.',
                    buttonLabel: 'Create first post',
                    onPressed: () => context.go('/post'),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    await ref
                        .read(listingsControllerProvider.notifier)
                        .refresh();
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: listings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final listing = listings[index];
                      return ListingCard(
                        listing: listing,
                        onTap: () =>
                            context.push('/home/listing/${listing.id}'),
                        onWhatsApp: () => launchWhatsApp(listing.whatsappNumber),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends ConsumerWidget {
  const _FilterRow({required this.onOpenFilters});

  final VoidCallback onOpenFilters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(filtersProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final category in kCategories)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category),
                  selected: filters.categories.contains(category),
                  onSelected: (selected) {
                    final next = Set<String>.from(filters.categories);
                    if (selected) {
                      next.add(category);
                    } else {
                      next.remove(category);
                    }
                    ref.read(filtersProvider.notifier).update(
                          filters.copyWith(categories: next),
                        );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: const Text('Works during load-shedding'),
                selected: filters.worksDuringLoadSheddingOnly,
                onSelected: (selected) {
                  ref.read(filtersProvider.notifier).update(
                        filters.copyWith(worksDuringLoadSheddingOnly: selected),
                      );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: const Text('No power needed'),
                selected: filters.noPowerNeededOnly,
                onSelected: (selected) {
                  ref.read(filtersProvider.notifier).update(
                        filters.copyWith(noPowerNeededOnly: selected),
                      );
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.tune),
              onPressed: onOpenFilters,
            ),
          ],
        ),
      ),
    );
  }
}
