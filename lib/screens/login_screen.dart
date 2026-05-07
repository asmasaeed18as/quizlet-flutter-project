import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import 'register_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  bool _isLoading = false;

  static final RegExp _emailRegex = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/login_bg.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x6617223B),
                    Color(0x3317223B),
                    Color(0xCCF4F7FF),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.86),
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.55),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x220B1B3F),
                              blurRadius: 18,
                              offset: Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (size.height > 690) ...[
                              const Icon(
                                Icons.auto_awesome_rounded,
                                color: AppTheme.primary,
                                size: 28,
                              ),
                              const SizedBox(height: 10),
                            ],
                            const Text(
                              'Welcome Back',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Log in to continue your quiz streak and track your performance.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF4A5568),
                              ),
                            ),
                            const SizedBox(height: 22),
                            Form(
                              key: _formKey,
                              autovalidateMode: _autovalidateMode,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: const InputDecoration(
                                      labelText: 'Email',
                                      hintText: 'you@example.com',
                                      prefixIcon: Icon(Icons.mail_outline),
                                    ),
                                    validator: (value) {
                                      final email = value?.trim() ?? '';
                                      if (email.isEmpty) {
                                        return 'Email is required.';
                                      }
                                      if (!_emailRegex.hasMatch(email)) {
                                        return 'Enter a valid email address.';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Password',
                                      hintText: 'Minimum 6 characters',
                                      prefixIcon: Icon(Icons.lock_outline),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Password is required.';
                                      }
                                      if (value.length < 6) {
                                        return 'Password must be at least 6 characters.';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _isLoading ? null : _onForgotPassword,
                                child: const Text('Forgot Password?'),
                              ),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _onLoginPressed,
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.4,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : const Text('Login'),
                              ),
                            ),
                            const SizedBox(height: 18),
                            const Row(
                              children: [
                                Expanded(child: Divider()),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    'Or continue with',
                                    style: TextStyle(color: Color(0xFF6B7280)),
                                  ),
                                ),
                                Expanded(child: Divider()),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Center(
                              child: _SocialChip(
                                icon: Icons.g_mobiledata_rounded,
                                color: const Color(0xFFDB4437),
                                onTap: _isLoading ? null : signInWithGoogle,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const RegisterScreen(),
                                    ),
                                  );
                                },
                                child: const Text.rich(
                                  TextSpan(
                                    style: TextStyle(color: Color(0xFF4A5568)),
                                    children: [
                                      TextSpan(text: "Don't have an account? "),
                                      TextSpan(
                                        text: 'Register Now',
                                        style: TextStyle(
                                          color: AppTheme.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onLoginPressed() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      setState(() {
        _autovalidateMode = AutovalidateMode.onUserInteraction;
      });
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
    });

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      final user = credential.user;
      if (user != null) {
        await FirestoreService.instance.ensureUserProfile(user);
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const AuthGate(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 350),
        ),
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      _showMessage(_friendlyLoginError(error));
    } catch (error) {
      if (!mounted) return;
      _showMessage(
        'Login failed after authentication. Check Firestore setup. Error: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> signInWithGoogle() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
    });

    try {
      // Clear any cached Google session so the user is asked to authenticate.
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null) {
        _showMessage(
          'Google authentication did not return an ID token. Check your Firebase and Google Sign-In setup.',
        );
        return;
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      final user = userCredential.user;
      if (user == null) {
        _showMessage('Google sign-in failed. Please try again.');
        return;
      }

      await FirestoreService.instance.ensureUserProfile(user);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthGate()),
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      _showMessage(_friendlyLoginError(error));
    } catch (error) {
      if (!mounted) return;
      _showMessage(
        'Google sign-in failed. Error: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _friendlyLoginError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'That email address is not valid.';
      case 'invalid-credential':
      case 'user-not-found':
      case 'wrong-password':
        return 'Incorrect email or password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again in a moment.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection and try again.';
      default:
        return error.message ?? 'Login failed. Please try again.';
    }
  }

  Future<void> _onForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showMessage('Enter your email address first.');
      return;
    }

    if (!_emailRegex.hasMatch(email)) {
      _showMessage('Enter a valid email address to reset your password.');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      _showMessage('Password reset email sent. Check your inbox.');
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      _showMessage(_friendlyPasswordResetError(error));
    } catch (_) {
      if (!mounted) return;
      _showMessage('Could not send reset email. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _friendlyPasswordResetError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'That email address is not valid.';
      case 'missing-android-pkg-name':
      case 'missing-continue-uri':
      case 'missing-ios-bundle-id':
      case 'invalid-continue-uri':
      case 'unauthorized-continue-uri':
        return 'Password reset is not configured correctly in Firebase.';
      case 'user-not-found':
        return 'No account was found for this email address.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection and try again.';
      default:
        return error.message ?? 'Could not send reset email.';
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
    );
  }
}

class _SocialChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _SocialChip({required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5EAF4)),
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}
