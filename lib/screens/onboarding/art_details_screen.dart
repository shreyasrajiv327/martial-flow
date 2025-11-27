import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../models/user.dart';
import '../profile_screen.dart';

class ArtDetailsScreen extends StatefulWidget {
  final List<String> arts;
  final int index;
  const ArtDetailsScreen({required this.arts, this.index = 0, Key? key})
    : super(key: key);
  @override
  State<ArtDetailsScreen> createState() => _ArtDetailsScreenState();
}

class _ArtDetailsScreenState extends State<ArtDetailsScreen> {
  final _beltController = TextEditingController();
  final _expController = TextEditingController();
  final _goalsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final currentArt = widget.arts[widget.index];
    final isLast = widget.index == widget.arts.length - 1;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${currentArt[0].toUpperCase()}${currentArt.substring(1)} details',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _beltController,
              decoration: const InputDecoration(labelText: 'Belt color'),
            ),
            TextField(
              controller: _expController,
              decoration: const InputDecoration(labelText: 'Experience level'),
            ),
            TextField(
              controller: _goalsController,
              decoration: const InputDecoration(
                labelText: 'Goals (comma separated)',
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              child: Text(isLast ? 'Finish' : 'Next'),
              onPressed: () {
                final goalsList = _goalsController.text
                    .split(',')
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty)
                    .toList();
                Provider.of<AppState>(
                  context,
                  listen: false,
                ).draftSetArtDetails(
                  currentArt,
                  UserArtInfo(
                    belt: _beltController.text,
                    experienceLevel: _expController.text,
                    goals: goalsList,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
                );
                if (isLast) {
                  Provider.of<AppState>(
                    context,
                    listen: false,
                  ).completeOnboarding();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    (_) => false,
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ArtDetailsScreen(
                        arts: widget.arts,
                        index: widget.index + 1,
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
