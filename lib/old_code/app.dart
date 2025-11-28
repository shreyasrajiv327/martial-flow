import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'screens/splash_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

class MartialFlowApp extends StatelessWidget {
  const MartialFlowApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthService())],
      child: MaterialApp(
        title: 'MartialFlow',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const SplashScreen(),
        routes: {
          '/auth': (_) => const AuthScreen(),
          '/home': (_) => const HomeScreen(),
        },
      ),
    );
  }
}
