import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app_providers.dart';
import '../../shared/utils/constants.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _nameController = TextEditingController(text: 'You');
  String? _selectedSuburb;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedSuburb = ref.read(currentSuburbProvider);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.asData?.value;

    return Scaffold(
      appBar: AppBar(title: const Text('Complete Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Finish setup to continue.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Display name'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
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
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving || user == null ? null : () => _save(user),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: _saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save & continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(User user) async {
    final name = _nameController.text.trim().isEmpty
        ? 'You'
        : _nameController.text.trim();
    final suburb = _selectedSuburb ?? 'Sea Point';

    setState(() => _saving = true);
    try {
      await ref.read(userProfileRepositoryProvider).createProfile(
            uid: user.uid,
            displayName: name,
            phoneNumber: user.phoneNumber ?? '',
            suburb: suburb,
            isPhoneVerified: true,
          );
      ref.read(settingsProvider.notifier).updateSuburb(suburb);
      if (!mounted) return;
      context.go('/home');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}
