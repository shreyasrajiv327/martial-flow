import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class ArtPageScreen extends StatelessWidget {
  final String art;
  const ArtPageScreen({required this.art, Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final artInfo = appState.user?.arts[art];
    return Scaffold(
      appBar: AppBar(title: Text('${art[0].toUpperCase()}${art.substring(1)}')),
      body: artInfo == null
          ? const Center(child: Text('No data for this martial art.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: ListTile(
                    title: Text('Belt: ${artInfo.belt}'),
                    subtitle: Text('Experience: ${artInfo.experienceLevel}'),
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  child: ListTile(
                    title: const Text('Goals'),
                    subtitle: Text(
                      artInfo.goals.isEmpty
                          ? 'No goals added yet.'
                          : artInfo.goals.join(', '),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  child: const Text('Routines'),
                  onPressed: () =>
                      Navigator.pushNamed(context, '/routines', arguments: art),
                ),
                ElevatedButton(
                  child: const Text('Technique Library'),
                  onPressed: () => Navigator.pushNamed(
                    context,
                    '/techniques',
                    arguments: art,
                  ),
                ),
              ],
            ),
    );
  }
}
