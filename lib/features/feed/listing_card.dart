import 'package:flutter/material.dart';

import '../../data/models/listing.dart';
import '../../shared/utils/formatters.dart';

class ListingCard extends StatelessWidget {
  const ListingCard({
    super.key,
    required this.listing,
    required this.onTap,
    required this.onWhatsApp,
  });

  final Listing listing;
  final VoidCallback onTap;
  final VoidCallback onWhatsApp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final availabilityLabel = listing.type == ListingType.provider
        ? 'Available now'
        : 'Requesting help';
    return Card(
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(_iconForCategory(listing.category)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      listing.title,
                      style: theme.textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                formatPrice(listing.priceFrom),
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.place_outlined, size: 16, color: theme.hintColor),
                  const SizedBox(width: 4),
                  Text(listing.suburb, style: theme.textTheme.bodySmall),
                  const SizedBox(width: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      availabilityLabel,
                      style: theme.textTheme.labelSmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.star, size: 16, color: Colors.amber.shade700),
                  const SizedBox(width: 4),
                  Text(
                    formatRating(listing.rating, listing.reviewsCount),
                    style: theme.textTheme.bodySmall,
                  ),
                  const Spacer(),
                  FilledButton.tonalIcon(
                    onPressed: onWhatsApp,
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('WhatsApp'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'Cleaning':
        return Icons.cleaning_services_outlined;
      case 'Repair':
        return Icons.handyman_outlined;
      case 'Plumbing':
        return Icons.plumbing_outlined;
      case 'Water/Gas Delivery':
        return Icons.local_shipping_outlined;
      case 'Babysitting':
        return Icons.child_friendly_outlined;
      case 'Pet-sitting':
        return Icons.pets_outlined;
      default:
        return Icons.storefront_outlined;
    }
  }
}
