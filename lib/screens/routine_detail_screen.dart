// routine_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoutineDetailScreen extends StatelessWidget {
  final QueryDocumentSnapshot routineDoc;

  const RoutineDetailScreen({required this.routineDoc});

  @override
  Widget build(BuildContext context) {
    final data = routineDoc.data() as Map<String, dynamic>;
    final exercises = data['exercises'] as List<dynamic>;

    return Scaffold(
      appBar: AppBar(title: Text(data['name'])),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: exercises.length,
        itemBuilder: (context, i) {
          final ex = exercises[i];
          return Card(
            child: ListTile(
              title: FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('techniques')
                    .doc(data['art'])
                    .collection('items')
                    .doc(ex['id'])
                    .get(),
                builder: (context, snap) {
                  if (!snap.hasData) return Text("Loading...");
                  return Text(snap.data?['name'] ?? ex['id']);
                },
              ),
              subtitle: Text("${ex['sets']} sets × ${ex['reps']} reps"),
              trailing: ex['timing_sec'] > 0
                  ? Text("${ex['timing_sec']} sec")
                  : null,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Start workout logic here
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Starting ${data['name']}...")),
          );
        },
        label: Text("Start Routine"),
        icon: Icon(Icons.play_arrow),
      ),
    );
  }
}