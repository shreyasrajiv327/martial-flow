import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.user;
    if (user == null) {
      return Scaffold(
        body: Center(child: Text('No user found. Please complete onboarding.')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Name: ${user.name}', style: const TextStyle(fontSize: 18)),
          Text('Email: ${user.email}', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 32),
          const Text(
            'Martial Arts:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ...user.martialArts.map((art) {
            final details = user.arts[art];
            return Card(
              child: ListTile(
                title: Text(art[0].toUpperCase() + art.substring(1)),
                subtitle: details == null
                    ? const Text('No details')
                    : Text(
                        'Belt: ${details.belt}\nExperience: ${details.experienceLevel}\nGoals: ${details.goals.join(", ")}',
                      ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {},
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
