import 'package:flutter/material.dart';
import '../models/technique.dart';

class TechniqueCard extends StatelessWidget {
  final Technique technique;
  const TechniqueCard({required this.technique, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: const Icon(Icons.sports_martial_arts),
        title: Text(
          technique.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("${technique.category} • ${technique.level}"),
        trailing: Text(
          "${technique.steps.length} step${technique.steps.length == 1 ? '' : 's'}",
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ),
    );
  }
}
