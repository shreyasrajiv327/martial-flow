// technique_library_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../models/technique.dart';
import '../widgets/technique_card.dart'; // Your TechniqueCard widget

class TechniqueLibraryScreen extends StatelessWidget {
  const TechniqueLibraryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String? activeArt = Provider.of<AppState>(context).activeArt;

    // If no art selected yet
    if (activeArt == null || activeArt.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Technique Library')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.category, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Select a martial art to view techniques',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    final CollectionReference itemsCol = FirebaseFirestore.instance
        .collection('techniques')
        .doc(activeArt)
        .collection('items');

    return Scaffold(
      appBar: AppBar(
        title: Text('$activeArt Techniques'),
        elevation: 2,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: itemsCol.orderBy('name').snapshots(),
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
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Failed to load techniques'),
                  Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const TechniqueLibraryScreen()),
                    ),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Empty state
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No techniques added for $activeArt yet.'),
            );
          }

          // Success: Map documents → Technique objects using your fromMap
          final List<Technique> techniques = snapshot.data!.docs.map((doc) {
            final data = doc.data()! as Map<String, dynamic>;
            return Technique.fromMap(doc.id, data);
          }).toList();

          // Display using your beautiful TechniqueCard
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 80),
            itemCount: techniques.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final technique = techniques[index];

              return TechniqueCard(
                technique: technique,
                key: ValueKey(technique.id), // Good for performance
              );
            },
          );
        },
      ),
    );
  }
}