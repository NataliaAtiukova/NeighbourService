import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app_providers.dart';
import '../../data/models/listing.dart';
import '../../shared/utils/app_flags.dart';
import '../../shared/utils/constants.dart';
import '../../shared/utils/formatters.dart';
import '../../shared/widgets/fade_slide_in.dart';

class PostScreen extends ConsumerStatefulWidget {
  const PostScreen({super.key, this.listingId});

  final String? listingId;

  @override
  ConsumerState<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends ConsumerState<PostScreen> {
  final _formKey = GlobalKey<FormState>();
  late ListingType _type;
  String? _selectedCategory;
  String? _selectedSuburb;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _availabilityController = TextEditingController();
  final _priceController = TextEditingController();
  late bool _worksDuringLoadShedding;
  late bool _needsElectricity;
  late bool _isEditing;
  bool _initialized = false;
  Listing? _editingListing;
  bool _isSubmitting = false;
  bool _animateSections = true;

  @override
  void initState() {
    super.initState();
    _type = ListingType.provider;
    _worksDuringLoadShedding = false;
    _needsElectricity = false;
    _isEditing = widget.listingId != null;
    _selectedSuburb = ref.read(currentSuburbProvider);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _availabilityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _populateForEdit(Listing listing) {
    if (_initialized) return;
    _editingListing = listing;
    _type = listing.type;
    _selectedCategory = listing.category;
    _selectedSuburb = listing.suburb;
    _titleController.text = listing.title;
    _descriptionController.text = stripAvailability(listing.description);
    final availability = extractAvailability(listing.description);
    _availabilityController.text =
        availability == 'Flexible' ? '' : availability;
    _priceController.text = listing.priceFrom?.toString() ?? '';
    _worksDuringLoadShedding = listing.worksDuringLoadShedding;
    _needsElectricity = listing.needsElectricity;
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final firebaseUser = authState.asData?.value;
    final profile = ref.watch(userProfileProvider).asData?.value;
    final settings = ref.watch(settingsProvider);
    final listingAsync = widget.listingId == null
        ? const AsyncValue<Listing?>.data(null)
        : ref.watch(listingDetailsProvider(widget.listingId!));
    final whatsappNumber =
        firebaseUser?.phoneNumber ??
            profile?.phoneNumber ??
            settings.phoneNumber;

    if (_animateSections) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _animateSections = false);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Listing' : 'Create Listing'),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: _isSubmitting ? null : () => _submit(whatsappNumber),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: _isSubmitting
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_isEditing ? 'Update' : 'Publish'),
          ),
        ),
      ),
      body: listingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 12),
                const Text('Unable to load listing'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref
                      .read(listingsControllerProvider.notifier)
                      .load(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (listing) {
          if (listing != null) {
            _populateForEdit(listing);
          }
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                FadeSlideIn(
                  index: 0,
                  animate: _animateSections,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('I am',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      SegmentedButton<ListingType>(
                        segments: const [
                          ButtonSegment(
                            value: ListingType.provider,
                            label: Text('Provider'),
                          ),
                          ButtonSegment(
                            value: ListingType.looking,
                            label: Text('Looking for service'),
                          ),
                        ],
                        selected: {_type},
                        onSelectionChanged: (selection) {
                          setState(() {
                            _type = selection.first;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                FadeSlideIn(
                  index: 1,
                  animate: _animateSections,
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: kCategories
                        .map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() {
                      _selectedCategory = value;
                    }),
                    validator: (value) =>
                        value == null ? 'Select a category' : null,
                  ),
                ),
                const SizedBox(height: 16),
                FadeSlideIn(
                  index: 2,
                  animate: _animateSections,
                  child: TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Enter a title'
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                FadeSlideIn(
                  index: 3,
                  animate: _animateSections,
                  child: TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Enter a description'
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                FadeSlideIn(
                  index: 4,
                  animate: _animateSections,
                  child: TextFormField(
                    controller: _availabilityController,
                    decoration: const InputDecoration(
                      labelText: 'Availability (days/time)',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FadeSlideIn(
                  index: 5,
                  animate: _animateSections,
                  child: TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Price (optional)',
                      prefixText: 'R ',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FadeSlideIn(
                  index: 6,
                  animate: _animateSections,
                  child: DropdownButtonFormField<String>(
                    value: _selectedSuburb,
                    decoration: const InputDecoration(labelText: 'Suburb'),
                    items: kSuburbs
                        .map(
                          (suburb) => DropdownMenuItem(
                            value: suburb,
                            child: Text(suburb),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() {
                      _selectedSuburb = value;
                    }),
                    validator: (value) =>
                        value == null ? 'Select a suburb' : null,
                  ),
                ),
                const SizedBox(height: 16),
                FadeSlideIn(
                  index: 7,
                  animate: _animateSections,
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Works during load-shedding'),
                        value: _worksDuringLoadShedding,
                        onChanged: (value) => setState(() {
                          _worksDuringLoadShedding = value;
                        }),
                      ),
                      SwitchListTile(
                        title: const Text('Needs electricity'),
                        value: _needsElectricity,
                        onChanged: (value) => setState(() {
                          _needsElectricity = value;
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                FadeSlideIn(
                  index: 8,
                  animate: _animateSections,
                  child: TextFormField(
                    initialValue: whatsappNumber,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'WhatsApp number',
                    ),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _submit(String whatsappNumber) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isSubmitting) return;
    final firebaseUser = ref.read(authStateProvider).asData?.value;
    if (firebaseUser == null && !kBypassSmsAuth) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to publish a listing.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final price = int.tryParse(_priceController.text.trim());
    final availability = _availabilityController.text.trim();
    final baseDescription = stripAvailability(_descriptionController.text);
    final description = availability.isEmpty
        ? baseDescription
        : '$baseDescription\n\nAvailability: $availability';

    final baseListing = _editingListing;
    final ownerUid = firebaseUser?.uid ??
        ref.read(settingsProvider.notifier).ensureLocalUserId();
    if (ownerUid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to create listing.')),
      );
      setState(() => _isSubmitting = false);
      return;
    }
    final listing = Listing(
      id: widget.listingId ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      type: _type,
      ownerUid: baseListing?.ownerUid ?? ownerUid,
      category: _selectedCategory!,
      title: _titleController.text.trim(),
      description: description,
      priceFrom: price,
      suburb: _selectedSuburb!,
      worksDuringLoadShedding: _worksDuringLoadShedding,
      needsElectricity: _needsElectricity,
      rating: baseListing?.rating ?? 0,
      reviewsCount: baseListing?.reviewsCount ?? 0,
      isPhoneVerified: baseListing?.isPhoneVerified ?? firebaseUser != null,
      whatsappNumber: whatsappNumber.isNotEmpty ? whatsappNumber : 'N/A',
      createdAt: baseListing?.createdAt ?? DateTime.now(),
    );

    try {
      if (_isEditing) {
        await ref.read(listingsControllerProvider.notifier).update(listing);
      } else {
        await ref.read(listingsControllerProvider.notifier).add(listing);
      }
      if (firebaseUser != null) {
        ref.invalidate(myListingsProvider(firebaseUser.uid));
      } else {
        final localUserId =
            ref.read(settingsProvider.notifier).ensureLocalUserId();
        ref.invalidate(myListingsProvider(localUserId));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEditing
            ? 'Listing updated successfully'
            : 'Listing published'),
      ),
    );
    if (!_isEditing) {
      _resetForm();
      context.go('/home');
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _titleController.clear();
    _descriptionController.clear();
    _availabilityController.clear();
    _priceController.clear();
    setState(() {
      _type = ListingType.provider;
      _selectedCategory = null;
      _selectedSuburb = ref.read(currentSuburbProvider);
      _worksDuringLoadShedding = false;
      _needsElectricity = false;
    });
  }
}
