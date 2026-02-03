class Review {
  const Review({
    required this.id,
    required this.listingId,
    required this.rating,
    required this.text,
    required this.authorName,
    required this.createdAt,
  });

  final String id;
  final String listingId;
  final double rating;
  final String text;
  final String authorName;
  final DateTime createdAt;
}
