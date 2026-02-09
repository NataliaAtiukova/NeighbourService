import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app_providers.dart';

class PhoneAuthScreen extends ConsumerStatefulWidget {
  const PhoneAuthScreen({super.key, this.redirectTo});

  final String? redirectTo;

  @override
  ConsumerState<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends ConsumerState<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  String? _verificationId;
  bool _isLoading = false;
  _AuthStep _step = _AuthStep.phone;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(firebaseAuthProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Phone verification')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Verify your phone to post listings.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeOutCubic,
              child: _step == _AuthStep.phone
                  ? Column(
                      key: const ValueKey('phoneStep'),
                      children: [
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Phone number',
                            hintText: '+27...',
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: _isLoading
                              ? null
                              : () => _sendCode(
                                    auth,
                                    _phoneController.text.trim(),
                                  ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child:
                                        CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Send code'),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      key: const ValueKey('codeStep'),
                      children: [
                        TextField(
                          controller: _codeController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Verification code',
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: _isLoading
                              ? null
                              : () => _verifyCode(
                                    auth,
                                    _codeController.text.trim(),
                                  ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child:
                                        CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Verify & continue'),
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 16),
            if (_step == _AuthStep.code)
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () => setState(() => _step = _AuthStep.phone),
                child: const Text('Edit phone number'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendCode(FirebaseAuth auth, String phone) async {
    if (phone.isEmpty) {
      _showSnack('Enter your phone number');
      return;
    }
    setState(() => _isLoading = true);
    await auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (credential) async {
        await auth.signInWithCredential(credential);
        if (!mounted) return;
        _handleSignedIn();
      },
      verificationFailed: (error) {
        _showSnack(error.message ?? 'Verification failed');
      },
      codeSent: (verificationId, _) {
        setState(() {
          _verificationId = verificationId;
          _step = _AuthStep.code;
        });
        _showSnack('Code sent');
      },
      codeAutoRetrievalTimeout: (verificationId) {
        _verificationId = verificationId;
      },
    );
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyCode(FirebaseAuth auth, String code) async {
    if (_verificationId == null || code.isEmpty) {
      _showSnack('Enter the verification code');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: code,
      );
      await auth.signInWithCredential(credential);
      if (!mounted) return;
      _handleSignedIn();
    } on FirebaseAuthException catch (error) {
      _showSnack(error.message ?? 'Invalid code');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSignedIn() async {
    try {
      await ref.read(profileBootstrapProvider.future);
    } catch (_) {}
    final target = widget.redirectTo == null
        ? '/home'
        : Uri.decodeComponent(widget.redirectTo!);
    if (!mounted) return;
    context.go(target);
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

enum _AuthStep { phone, code }
