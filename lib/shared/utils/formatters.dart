String formatPrice(int? price, {String currency = 'ZAR'}) {
  if (price == null) {
    return 'Price on request';
  }
  return 'From R$price';
}

String formatRating(double rating, int count) {
  if (count == 0) {
    return 'New';
  }
  return '$rating ($count)';
}

String extractAvailability(String description) {
  final marker = 'Availability:';
  final index = description.indexOf(marker);
  if (index == -1) {
    return 'Flexible';
  }
  return description.substring(index + marker.length).trim();
}

String stripAvailability(String description) {
  final marker = 'Availability:';
  final index = description.indexOf(marker);
  if (index == -1) {
    return description.trim();
  }
  return description.substring(0, index).trim();
}
