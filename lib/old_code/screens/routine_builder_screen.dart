// screens/routine_builder_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../models/routine.dart';
import '../widgets/routine_card.dart'; // Your beautiful card

class RoutineBuilderScreen extends StatelessWidget {
  const RoutineBuilderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String? activeArt = Provider.of<AppState>(context).activeArt;

    // Guard: No martial art selected
    if (activeArt == null || activeArt.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Routines')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning_amber_rounded, size: 80, color: Colors.orange),
              SizedBox(height: 16),
              Text(
                'Please select a martial art first',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // Firestore query: all routines for current art, newest first
    final Query routinesQuery = FirebaseFirestore.instance
        .collection('routines')
        .where('art', isEqualTo: activeArt)
        .orderBy('created_at', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: Text('$activeArt Routines'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: routinesQuery.snapshots(),
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off, size: 70, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Failed to load routines'),
                  Text('${snapshot.error}', style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const RoutineBuilderScreen()),
                    ),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          // Empty state
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fitness_center, size: 90, color: Colors.grey[400]),
                  const SizedBox(height: 20),
                  Text(
                    'No routines yet for $activeArt',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  const Text('Tap + to create your first one!'),
                ],
              ),
            );
          }

          // Success: Convert docs → Routine objects using your fromMap
          final List<Routine> routines = docs.map((doc) {
            final data = doc.data()! as Map<String, dynamic>;
            return Routine.fromMap(doc.id, data);
          }).toList();

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 100),
            itemCount: routines.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final routine = routines[index];

              return RoutineCard(
                routine: routine,
                key: ValueKey(routine.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createNewRoutine(context, activeArt),
        child: const Icon(Icons.add),
        tooltip: 'New Routine',
      ),
    );
  }

  Future<void> _createNewRoutine(BuildContext context, String art) async {
    final TextEditingController controller = TextEditingController();

    final String? name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Routine'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'e.g., Morning Warm-up, Power Kicks',
            labelText: 'Routine Name',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(ctx, text);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (name == null || name.isEmpty) return;

    try {
      // Replace with real user ID when auth is added
      final String userId = 'current_user_id';

      final newRoutine = Routine(
        id: '', // Firestore generates
        art: art,
        name: name,
        userId: userId,
        isDefault: false,
        createdAt: DateTime.now(),
        exercises: [],
      );

      await FirebaseFirestore.instance
          .collection('routines')
          .add(newRoutine.toMap());

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"$name" created!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create routine')),
        );
      }
    }
  }
}