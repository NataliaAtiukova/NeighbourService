const List<String> kCategories = [
  'Cleaning',
  'Repair',
  'Plumbing',
  'Water/Gas Delivery',
  'Babysitting',
  'Pet-sitting',
];

const List<String> kSuburbs = [
  'Sea Point',
  'Green Point',
  'Camps Bay',
  'Gardens',
  'Woodstock',
  'Observatory',
  'CBD',
  'Claremont',
  'Rondebosch',
  'Tamboerskloof',
  'Kenilworth',
];

enum SortOption { recent, rating, priceLowHigh }

const Map<SortOption, String> kSortLabels = {
  SortOption.recent: 'Recent',
  SortOption.rating: 'Rating',
  SortOption.priceLowHigh: 'Price low-high',
};
