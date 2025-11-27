import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/martial_art_toggle.dart';
import 'profile_screen.dart';
import 'art_page_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final art = appState.activeArt ?? appState.user?.martialArts.firstOrNull;
    final welcomes = [
      'Let’s train!',
      'Go hit those goals!',
      'Consistency = Progress!',
      'Small steps, big results!',
    ];
    final suggestion = welcomes[DateTime.now().day % welcomes.length];
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('MartialFlow'),
            const Spacer(),
            MartialArtToggle(),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
        ],
      ),
      body: art == null
          ? const Center(child: Text('No martial art selected.'))
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Today’s art: ${art[0].toUpperCase()}${art.substring(1)}',
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 20),
                  Text(suggestion, style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    child: const Text('Go to Art Page'),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ArtPageScreen(art: art),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
