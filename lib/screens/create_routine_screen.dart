// create_routine_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateRoutineScreen extends StatefulWidget {
  final String art; // "taekwondo" or "karate"
  const CreateRoutineScreen({required this.art});

  @override
  _CreateRoutineScreenState createState() => _CreateRoutineScreenState();
}

class _CreateRoutineScreenState extends State<CreateRoutineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final List<Map<String, dynamic>> _exercises = [];

  String? _selectedCategory;
  List<DocumentSnapshot> _availableTechniques = [];
  bool _loading = false;

  final categories = [
    "kick", "block", "hand_technique", "punch", "stance", "kata", "poomsae", "other"
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = categories.first;
    _loadTechniques();
  }

  Future<void> _loadTechniques() async {
    setState(() => _loading = true);

    final snapshot = await FirebaseFirestore.instance
        .collection('techniques')
        .doc(widget.art)
        .collection('items')
        .get();

    setState(() {
      _availableTechniques = snapshot.docs;
      _loading = false;
    });
  }

  void _addExercise(DocumentSnapshot tech) {
    final data = tech.data() as Map<String, dynamic>;
    final newEx = {
      "id": tech.id,
      "name": data['name'] ?? tech.id,
      "sets": 3,
      "reps": 10,
      "timing_sec": 0,
    };
    setState(() {
      _exercises.add(newEx);
    });
  }

  void _removeExercise(int index) {
    setState(() {
      _exercises.removeAt(index);
    });
  }

  Future<void> _saveRoutine() async {
    if (!_formKey.currentState!.validate() || _exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please add a name and at least one exercise")),
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('routines').add({
      "name": _nameController.text.trim(),
      "art": widget.art,
      "belt": "custom", // or leave null
      "focus": "custom",
      "is_default": false,
      "userId": uid,
      "created_at": FieldValue.serverTimestamp(),
      "exercises": _exercises.map((e) => {
            "id": e["id"],
            "sets": e["sets"],
            "reps": e["reps"],
            "timing_sec": e["timing_sec"],
          }).toList(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Routine saved!")),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create New ${widget.art.capitalize()} Routine"),
        actions: [
          TextButton(
            onPressed: _exercises.isNotEmpty
                ? () => _saveRoutine()
                : null,
            child: Text("Save", style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Routine Name",
                  border: OutlineInputBorder(),
                  hintText: "e.g., My Kicking Drill, Red Belt Prep",
                ),
                validator: (v) => v?.trim().isEmpty == true ? "Required" : null,
              ),
            ),
          ),

          // Selected exercises preview
          if (_exercises.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text("Exercises in Routine (${_exercises.length})", style: Theme.of(context).textTheme.titleMedium),
            ),
            SizedBox(height: 8),
            Expanded(
              flex: 2,
              child: ReorderableListView(
                onReorder: (oldIdx, newIdx) {
                  setState(() {
                    if (newIdx > oldIdx) newIdx -= 1;
                    final item = _exercises.removeAt(oldIdx);
                    _exercises.insert(newIdx, item);
                  });
                },
                children: _exercises.asMap().entries.map((entry) {
                  final i = entry.key;
                  final ex = entry.value;
                  return ListTile(
                    key: ValueKey(ex["id"] + i.toString()),
                    leading: Icon(Icons.drag_handle),
                    title: Text(ex["name"]),
                    subtitle: Text("${ex["sets"]} × ${ex["reps"]}"),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeExercise(i),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],

          Divider(),

          // Add exercises section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(labelText: "Filter by Category"),
              items: categories.map((cat) => DropdownMenuItem(
                value: cat,
                child: Text(cat.replaceAll("_", " ").capitalize()),
              )).toList(),
              onChanged: (v) => setState(() => _selectedCategory = v),
            ),
          ),

          Expanded(
            flex: 3,
            child: _loading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _availableTechniques.length,
                    itemBuilder: (context, i) {
                      final tech = _availableTechniques[i];
                      final data = tech.data() as Map<String, dynamic>;
                      final category = data['category'] ?? 'other';

                      if (_selectedCategory != null && category != _selectedCategory) {
                        return SizedBox.shrink();
                      }

                      final alreadyAdded = _exercises.any((e) => e["id"] == tech.id);

                      return ListTile(
                        title: Text(data['name'] ?? tech.id),
                        subtitle: Text("${data['category'] ?? '—'} • ${data['level'] ?? 'All'} belt"),
                        trailing: alreadyAdded
                            ? Icon(Icons.check, color: Colors.green)
                            : Icon(Icons.add_circle_outline),
                        onTap: alreadyAdded ? null : () => _addExercise(tech),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() => "${this[0].toUpperCase()}${substring(1)}";
}