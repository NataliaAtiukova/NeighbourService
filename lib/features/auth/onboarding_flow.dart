import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app_providers.dart';

class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();

  int _stepIndex = 0;
  String? _verificationId;
  bool _isSending = false;
  bool _isVerifying = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeOutCubic,
                  transitionBuilder: (child, animation) {
                    final offset = Tween<Offset>(
                      begin: const Offset(0, 0.04),
                      end: Offset.zero,
                    ).animate(animation);
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: offset,
                        child: child,
                      ),
                    );
                  },
                  child: _buildStep(theme),
                ),
              ),
              const SizedBox(height: 8),
              _StepIndicator(current: _stepIndex, total: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(ThemeData theme) {
    switch (_stepIndex) {
      case 0:
        return _WelcomeStep(
          key: const ValueKey('welcome'),
          onContinue: () => _goToStep(1),
        );
      case 1:
        return _NameStep(
          key: const ValueKey('name'),
          controller: _nameController,
          onContinue: () => _goToStep(2),
          onSkip: () => _goToStep(2),
        );
      case 2:
        return _PhoneStep(
          key: const ValueKey('phone'),
          controller: _phoneController,
          isLoading: _isSending,
          onSend: _sendCode,
        );
      case 3:
      default:
        return _OtpStep(
          key: const ValueKey('otp'),
          controller: _codeController,
          isLoading: _isVerifying,
          onVerify: _verifyCode,
          onEditPhone: () => _goToStep(2),
        );
    }
  }

  void _goToStep(int index) {
    setState(() => _stepIndex = index);
  }

  Future<void> _sendCode() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _showSnack('Enter your phone number');
      return;
    }

    setState(() => _isSending = true);
    final auth = ref.read(firebaseAuthProvider);
    await auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (credential) async {
        await auth.signInWithCredential(credential);
        if (!mounted) return;
        setState(() => _isSending = false);
        await _handleSignedIn();
      },
      verificationFailed: (error) {
        if (!mounted) return;
        setState(() => _isSending = false);
        _showSnack(error.message ?? 'Verification failed');
      },
      codeSent: (verificationId, _) {
        if (!mounted) return;
        setState(() {
          _verificationId = verificationId;
          _isSending = false;
          _stepIndex = 3;
        });
        _showSnack('Code sent');
      },
      codeAutoRetrievalTimeout: (verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();
    if (_verificationId == null || code.isEmpty) {
      _showSnack('Enter the verification code');
      return;
    }

    setState(() => _isVerifying = true);
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: code,
      );
      await ref.read(firebaseAuthProvider).signInWithCredential(credential);
      if (!mounted) return;
      await _handleSignedIn();
    } on FirebaseAuthException catch (error) {
      _showSnack(error.message ?? 'Invalid code');
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  Future<void> _handleSignedIn() async {
    final user = ref.read(firebaseAuthProvider).currentUser;
    if (user == null) {
      _showSnack('Unable to sign in');
      return;
    }

    final repo = ref.read(userProfileRepositoryProvider);
    final existing = await repo.getProfile(user.uid);
    if (existing == null) {
      final displayName = _nameController.text.trim().isEmpty
          ? 'You'
          : _nameController.text.trim();
      final suburb = ref.read(settingsProvider).suburb;
      await repo.createProfile(
        uid: user.uid,
        displayName: displayName,
        phoneNumber: user.phoneNumber ?? _phoneController.text.trim(),
        suburb: suburb,
        isPhoneVerified: true,
      );
    }

    if (!mounted) return;
    context.go('/home');
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        Text(
          'Neighbour Service',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Find trusted local help or post a service in minutes.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: onContinue,
          child: const Text('Get started'),
        ),
        const Spacer(flex: 2),
      ],
    );
  }
}

class _NameStep extends StatelessWidget {
  const _NameStep({
    super.key,
    required this.controller,
    required this.onContinue,
    required this.onSkip,
  });

  final TextEditingController controller;
  final VoidCallback onContinue;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        Text(
          'Your name',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'What should we call you?',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Display name',
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: onContinue,
                child: const Text('Continue'),
              ),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: onSkip,
              child: const Text('Skip'),
            ),
          ],
        ),
        const Spacer(flex: 2),
      ],
    );
  }
}

class _PhoneStep extends StatelessWidget {
  const _PhoneStep({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        Text(
          'Phone verification',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your phone number to continue.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Phone number',
            hintText: '+27...',
          ),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: isLoading ? null : onSend,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: isLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Send code'),
          ),
        ),
        const Spacer(flex: 2),
      ],
    );
  }
}

class _OtpStep extends StatelessWidget {
  const _OtpStep({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.onVerify,
    required this.onEditPhone,
  });

  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onVerify;
  final VoidCallback onEditPhone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        Text(
          'Enter code',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We sent a 6-digit code to your phone.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Verification code',
          ),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: isLoading ? null : onVerify,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: isLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Verify'),
          ),
        ),
        TextButton(
          onPressed: isLoading ? null : onEditPhone,
          child: const Text('Edit phone number'),
        ),
        const Spacer(flex: 2),
      ],
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (index) {
        final isActive = index == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isActive ? 18 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }),
    );
  }
}
