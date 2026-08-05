import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app_watchhub/core/constants/app_colors.dart';
import 'package:app_watchhub/core/router/app_router.dart';
import 'package:app_watchhub/shared/providers/firebase_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUpMode = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login(String email, String password) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final auth = ref.read(firebaseAuthProvider);
      await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      // Success - router will auto-redirect when auth state updates
    } catch (e) {
      setState(() {
        _errorMessage =
            'Boutique authentication failed: ${e.toString().split(']').last.trim()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signUp(String email, String password) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final auth = ref.read(firebaseAuthProvider);
      await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      // Success - router will auto-redirect when auth state updates
    } catch (e) {
      setState(() {
        _errorMessage =
            'Account creation failed: ${e.toString().split(']').last.trim()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _submitCredentials() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text;
    final password = _passwordController.text;

    if (_isSignUpMode) {
      await _signUp(email, password);
    } else {
      await _login(email, password);
    }
  }

  Future<void> _loginAnonymously() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final auth = ref.read(firebaseAuthProvider);
      await auth.signInAnonymously();
      // Success - router will auto-redirect when auth state updates
    } catch (e) {
      setState(() {
        _errorMessage = 'Guest bypass authentication failed: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _loginAsDemo() async {
    _emailController.text = 'demo@watchhub.com';
    _passwordController.text = 'password123';
    await _login('demo@watchhub.com', 'password123');
  }

  Future<void> _showPasswordResetDialog() async {
    final resetEmailController = TextEditingController();
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your email address and we\'ll send you a link to reset your password.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: resetEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = resetEmailController.text.trim();
              if (email.isEmpty || !email.contains('@')) {
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid email address.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
                return;
              }

              try {
                await ref
                    .read(firebaseAuthProvider)
                    .sendPasswordResetEmail(email: email);
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Password reset email sent. Check your inbox.',
                      ),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error: ${e.toString().split(']').last.trim()}',
                      ),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text('Send Reset Email'),
          ),
        ],
      ),
    );
    resetEmailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ref
        .watch(authStateProvider)
        .when(
          loading: () => Scaffold(
            backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppColors.goldAccent),
                  const SizedBox(height: 16),
                  Text(
                    'Connecting to server...',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: isDark ? Colors.white : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          error: (err, stack) => Scaffold(
            backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Connection failed: $err',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: isDark ? Colors.white : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(authStateProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          data: (user) {
            return Scaffold(
              backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
              body: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (firebaseInitFailed) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.error.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Firebase initialization failed',
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.error,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    firebaseInitError ??
                                        'Please check your Firebase configuration.',
                                    style: GoogleFonts.outfit(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          // --- LUXURY LOGO / CREST ---
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkSurface
                                  : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.goldAccent.withValues(
                                  alpha: 0.3,
                                ),
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.watch_rounded,
                              size: 64,
                              color: AppColors.goldAccent,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // --- LUXURY BRAND NAME ---
                          Text(
                            'WATCHHUB',
                            style: GoogleFonts.outfit(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 6.0,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'HORLOGERIE D\'EXCEPTION',
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 2.0,
                              color: AppColors.goldAccent,
                            ),
                          ),
                          const SizedBox(height: 48),

                          // --- AUTH INPUTS ---
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email Address',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (v) => v == null || !v.contains('@')
                                ? 'Please enter a valid email'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock_outline_rounded),
                            ),
                            validator: (v) => v == null || v.length < 6
                                ? 'Password must be at least 6 characters'
                                : null,
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _showPasswordResetDialog,
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.goldAccent,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // --- ERROR STATE ALERT ---
                          if (_errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.error.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    color: AppColors.error,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: const TextStyle(
                                        color: AppColors.error,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // --- ACTION BUTTONS ---
                          if (_isLoading)
                            const CircularProgressIndicator(
                              color: AppColors.goldAccent,
                            )
                          else ...[
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _submitCredentials,
                                child: Text(
                                  _isSignUpMode ? 'CREATE ACCOUNT' : 'SIGN IN',
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isSignUpMode = !_isSignUpMode;
                                  _errorMessage = null;
                                });
                              },
                              child: Text(
                                _isSignUpMode
                                    ? 'Already have an account? Sign in'
                                    : 'New collector? Create an account',
                                style: GoogleFonts.outfit(fontSize: 13),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => context.go(AppRoutes.catalog),
                              child: Text(
                                'CONTINUE BROWSING',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  color: AppColors.goldAccent,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Expanded(child: Divider()),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Text(
                                    'OR QUICK OPTIONS',
                                    style: GoogleFonts.outfit(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                      color: AppColors.neutral,
                                    ),
                                  ),
                                ),
                                const Expanded(child: Divider()),
                              ],
                            ),
                            const SizedBox(height: 16),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final double gap = 12.0;
                                final double buttonWidth =
                                    (constraints.maxWidth - gap) / 2;

                                return Row(
                                  children: [
                                    SizedBox(
                                      width: buttonWidth,
                                      child: OutlinedButton(
                                        onPressed: _loginAsDemo,
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          side: BorderSide(
                                            color: AppColors.goldAccent
                                                .withValues(alpha: 0.5),
                                          ),
                                        ),
                                        child: Text(
                                          'DEMO VIP',
                                          style: GoogleFonts.outfit(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    SizedBox(
                                      width: buttonWidth,
                                      child: OutlinedButton(
                                        onPressed: _loginAnonymously,
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          side: BorderSide(
                                            color: isDark
                                                ? Colors.white24
                                                : Colors.black26,
                                          ),
                                          foregroundColor: isDark
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                        child: Text(
                                          'GUEST MODE',
                                          style: GoogleFonts.outfit(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
  }
}
