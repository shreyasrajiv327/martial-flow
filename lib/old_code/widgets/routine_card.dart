import 'package:flutter/material.dart';
import '../models/routine.dart';

class RoutineCard extends StatelessWidget {
  final Routine routine;
  const RoutineCard({required this.routine, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(Icons.fitness_center),
        title: Text(
          routine.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "${routine.exercises.length} exercise${routine.exercises.length == 1 ? '' : 's'} • ${routine.art}",
        ),
        trailing: routine.isDefault
            ? const Icon(Icons.star, color: Colors.amber)
            : null,
        onTap: () {
          // Callback if needed later
        },
      ),
    );
  }
}
