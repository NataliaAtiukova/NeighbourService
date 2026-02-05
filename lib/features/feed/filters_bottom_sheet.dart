import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_providers.dart';
import '../../shared/utils/constants.dart';
import '../../shared/widgets/animated_filter_chip.dart';

class FiltersBottomSheet extends ConsumerStatefulWidget {
  const FiltersBottomSheet({super.key});

  @override
  ConsumerState<FiltersBottomSheet> createState() => _FiltersBottomSheetState();
}

class _FiltersBottomSheetState extends ConsumerState<FiltersBottomSheet> {
  late TextEditingController _searchController;
  late Set<String> _selectedCategories;
  late bool _worksDuringLoadShedding;
  late bool _noPowerNeeded;
  late RangeValues _priceRange;
  late SortOption _sortOption;

  @override
  void initState() {
    super.initState();
    final filters = ref.read(filtersProvider);
    _searchController = TextEditingController(text: filters.search);
    _selectedCategories = {...filters.categories};
    _worksDuringLoadShedding = filters.worksDuringLoadSheddingOnly;
    _noPowerNeeded = filters.noPowerNeededOnly;
    final min = (filters.minPrice ?? 0).toDouble();
    final max = (filters.maxPrice ?? 1000).toDouble();
    _priceRange = RangeValues(min, max);
    _sortOption = filters.sort;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('Search & Filters',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 20),
            Text('Categories', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: kCategories.map((category) {
                final selected = _selectedCategories.contains(category);
                return AnimatedFilterChip(
                  label: category,
                  selected: selected,
                  onSelected: (value) {
                    setState(() {
                      if (value) {
                        _selectedCategories.add(category);
                      } else {
                        _selectedCategories.remove(category);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Works during load-shedding'),
              value: _worksDuringLoadShedding,
              onChanged: (value) => setState(() {
                _worksDuringLoadShedding = value;
              }),
            ),
            SwitchListTile(
              title: const Text('No power needed'),
              value: _noPowerNeeded,
              onChanged: (value) => setState(() {
                _noPowerNeeded = value;
              }),
            ),
            const SizedBox(height: 12),
            Text('Price range (ZAR)',
                style: Theme.of(context).textTheme.titleMedium),
            RangeSlider(
              values: _priceRange,
              min: 0,
              max: 1000,
              divisions: 20,
              labels: RangeLabels(
                'R${_priceRange.start.round()}',
                'R${_priceRange.end.round()}',
              ),
              onChanged: (values) => setState(() {
                _priceRange = values;
              }),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<SortOption>(
              value: _sortOption,
              decoration: const InputDecoration(labelText: 'Sort by'),
              items: SortOption.values
                  .map(
                    (option) => DropdownMenuItem(
                      value: option,
                      child: Text(kSortLabels[option]!)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _sortOption = value);
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ref.read(filtersProvider.notifier).reset();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      ref.read(filtersProvider.notifier).update(
                            FiltersState(
                              search: _searchController.text,
                              categories: _selectedCategories,
                              worksDuringLoadSheddingOnly:
                                  _worksDuringLoadShedding,
                              noPowerNeededOnly: _noPowerNeeded,
                              minPrice: _priceRange.start.round() == 0
                                  ? null
                                  : _priceRange.start.round(),
                              maxPrice: _priceRange.end.round() == 1000
                                  ? null
                                  : _priceRange.end.round(),
                              sort: _sortOption,
                            ),
                          );
                      Navigator.of(context).pop();
                    },
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
