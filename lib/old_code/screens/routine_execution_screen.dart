import 'package:flutter/material.dart';

class RoutineExecutionScreen extends StatelessWidget {
  final String routineName;
  final List<Map<String, dynamic>> exercises; // {name, sets, reps}
  const RoutineExecutionScreen({
    required this.routineName,
    required this.exercises,
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Execute: $routineName')),
      body: ListView(
        children: [
          for (final ex in exercises)
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${ex['name']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Sets: ${ex['sets']}  Reps: ${ex['reps']}'),
                    const SizedBox(height: 10),
                    TextField(decoration: const InputDecoration(labelText: 'Log Reps Done (comma-separated)'),),
                    TextField(decoration: const InputDecoration(labelText: 'Log Timing (sec, comma-separated)'),),
                    TextField(decoration: const InputDecoration(labelText: 'Notes (optional)'),),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      child: const Text('Save Log'),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Log saved (stub)')));
                      },
                    )
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }
}
