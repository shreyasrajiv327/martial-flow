import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import 'select_arts_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome to MartialFlow!')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Let’s get started:', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                child: const Text('Continue'),
                onPressed: () {
                  Provider.of<AppState>(
                    context,
                    listen: false,
                  ).draftNameEmail(nameController.text, emailController.text);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SelectArtsScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
