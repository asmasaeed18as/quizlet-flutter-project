import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'models/app_user.dart';
import 'services/firestore_service.dart';
import 'screens/admin_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: const Color(0xFF101729),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'App error',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                details.exceptionAsString(),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  };

  Object? firebaseError;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (error) {
    firebaseError = error;
  }

  runApp(MyApp(firebaseError: firebaseError));
}

class MyApp extends StatelessWidget {
  final Object? firebaseError;

  const MyApp({super.key, this.firebaseError});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system,
      home: firebaseError == null
          ? const SplashScreen()
          : FirebaseSetupErrorScreen(error: firebaseError.toString()),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return _RoleGate(user: snapshot.data!);
        }

        return const LoginScreen();
      },
    );
  }
}

class _RoleGate extends StatelessWidget {
  final User user;

  const _RoleGate({required this.user});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUser?>(
      stream: FirestoreService.instance.userStream(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final appUser = snapshot.data;
        if (appUser == null) {
          return FutureBuilder<void>(
            future: FirestoreService.instance.ensureUserProfile(user),
            builder: (context, ensureSnapshot) {
              if (ensureSnapshot.connectionState != ConnectionState.done) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (ensureSnapshot.hasError) {
                return Scaffold(
                  body: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Could not load your profile: ${ensureSnapshot.error}',
                      ),
                    ),
                  ),
                );
              }

              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            },
          );
        }

        return appUser.isAdmin ? const AdminScreen() : const HomeScreen();
      },
    );
  }
}

class FirebaseSetupErrorScreen extends StatelessWidget {
  final String error;

  const FirebaseSetupErrorScreen({
    super.key,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.screenGradient,
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange,
                            size: 28,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Firebase is not configured yet',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'The app started, but Firebase initialization failed.',
                        style: TextStyle(height: 1.5),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Required setup:',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '1. Add google-services.json (Android)\n'
                        '2. Add GoogleService-Info.plist (iOS)\n'
                        '3. Run flutterfire configure',
                      ),
                      const SizedBox(height: 14),
                      SelectableText(
                        error,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.red,
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
    );
  }
}
