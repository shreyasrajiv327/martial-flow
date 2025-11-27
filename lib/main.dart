// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import 'services/auth_service.dart';
import 'providers/app_state.dart';
import 'screens/auth_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'firebase_options.dart'; // auto-generated

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // REQUIRED for Web
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.deepPurple, useMaterial3: true),
        home: const AuthWrapper(),
        routes: {
          '/home': (_) => const HomeScreen(),
          '/onboarding': (_) => const OnboardingScreen(),
        },
      ),
    );
  }
}

// AuthWrapper decides which page to show
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

    return StreamBuilder<fb.User?>(
      stream: auth.authStateChanges(),
      builder: (context, snapshot) {
        // Loading while waiting for Firebase auth
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        // If not signed in, show Auth screen
        if (user == null) return const AuthScreen();

        // Signed in → check Firestore onboarding
        final appState = Provider.of<AppState>(context, listen: false);
        return FutureBuilder<bool>(
          future: appState.checkOnboardingStatus(user.uid),
          builder: (context, onboardSnap) {
            if (onboardSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // If onboarding completed → Home, else Onboarding
            if (onboardSnap.hasData && onboardSnap.data == true) {
              return const HomeScreen();
            } else {
              return const OnboardingScreen();
            }
          },
        );
      },
    );
  }
}
