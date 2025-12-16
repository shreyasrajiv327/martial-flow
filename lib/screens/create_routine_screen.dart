import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateRoutineScreen extends StatefulWidget {
  final String art; // "taekwondo" or "karate" – passed from ExerciseScreen
  const CreateRoutineScreen({Key? key, required this.art}) : super(key: key);

  @override
  State<CreateRoutineScreen> createState() => _CreateRoutineScreenState();
}

class _CreateRoutineScreenState extends State<CreateRoutineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final List<Map<String, dynamic>> _exercises = [];

  String? _selectedCategory;
  List<DocumentSnapshot> _availableTechniques = [];
  bool _loadingTechniques = true;
  String? _errorMessage;

  final List<String> categories = [
    "kick",
    "block",
    "stance",
    "strike",
    "form",
    "kata",
    "poomsae",
    "other"
  ];


  @override
  void initState() {
    super.initState();
    _selectedCategory = categories.first;
    print("CreateRoutineScreen initialized with art: ${widget.art}");
    _loadTechniques();
  }

  Future<void> _loadTechniques() async {
    setState(() {
      _loadingTechniques = true;
      _errorMessage = null;
    });

    print("Loading techniques for: ${widget.art}");

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('techniques')
          .doc(widget.art)           // ← Must match exact document ID (e.g., "taekwondo")
          .collection('items')
          .get();

      print("Found ${snapshot.docs.length} techniques");

      if (snapshot.docs.isEmpty) {
        _errorMessage = "No techniques found for ${widget.art.capitalize()}.\n\n"
            "Make sure:\n"
            "• Document ID is exactly '${widget.art}' (lowercase)\n"
            "• Subcollection is named 'items'\n"
            "• There are technique documents inside";
      }

      setState(() {
        _availableTechniques = snapshot.docs;
        _loadingTechniques = false;
      });
    } catch (e, stack) {
      print("Error loading techniques: $e");
      print(stack);
      setState(() {
        _errorMessage = "Failed to load techniques:\n$e";
        _loadingTechniques = false;
      });
    }
  }

  void _addExercise(DocumentSnapshot tech) {
    final data = tech.data() as Map<String, dynamic>;
    final newExercise = {
      "id": tech.id,
      "name": data['name'] ?? tech.id,
      "sets": 3,
      "reps": 10,
      "timing_sec": 0,
    };

    setState(() {
      _exercises.add(newExercise);
    });
  }

  void _removeExercise(int index) {
    setState(() {
      _exercises.removeAt(index);
    });
  }

  Future<void> _saveRoutine() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a routine name")),
      );
      return;
    }

    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Add at least one exercise")),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must be logged in")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('routines').add({
        "name": _nameController.text.trim(),
        "art": widget.art,
        "belt": "custom",
        "focus": "custom",
        "is_default": false,
        "userId": user.uid,
        "created_at": FieldValue.serverTimestamp(),
        "exercises": _exercises.map((e) => {
          "id": e["id"],
          "name": e["name"],
          "sets": e["sets"],
          "reps": e["reps"],
          "timing_sec": e["timing_sec"],
        }).toList(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Routine created successfully!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Save failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canSave = _exercises.isNotEmpty && _nameController.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text("Create ${widget.art.capitalize()} Routine"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: canSave ? _saveRoutine : null,
        label: const Text("Save Routine"),
        icon: const Icon(Icons.save),
        backgroundColor: canSave ? Theme.of(context).primaryColor : Colors.grey,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Routine Name *",
                  border: OutlineInputBorder(),
                  hintText: "e.g., My Kicking Combo",
                ),
                validator: (v) => v?.trim().isEmpty ?? true ? "Required" : null,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),

          // Selected Exercises Preview
          if (_exercises.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Exercises (${_exercises.length})",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              flex: 2,
              child: ReorderableListView(
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex--;
                    final item = _exercises.removeAt(oldIndex);
                    _exercises.insert(newIndex, item);
                  });
                },
                children: _exercises.asMap().entries.map((entry) {
                  final index = entry.key;
                  final ex = entry.value;
                  return ListTile(
                    key: ValueKey(ex["id"] + index.toString()),
                    leading: const Icon(Icons.drag_handle),
                    title: Text(ex["name"]),
                    subtitle: Text("${ex["sets"]} sets × ${ex["reps"]} reps"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeExercise(index),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],

          const Divider(height: 32),

          // Category Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: "Filter by Category"),
              items: categories.map((cat) => DropdownMenuItem(
                value: cat,
                child: Text(cat.replaceAll("_", " ").capitalize()),
              )).toList(),
              onChanged: (v) => setState(() => _selectedCategory = v),
            ),
          ),

          // Techniques List
          Expanded(
            flex: 3,
            child: _loadingTechniques
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : _availableTechniques.isEmpty
                        ? const Center(child: Text("No techniques available"))
                        : ListView.builder(
                            itemCount: _availableTechniques.length,
                            itemBuilder: (context, i) {
                              final tech = _availableTechniques[i];
                              final data = tech.data() as Map<String, dynamic>;
                              final category = data['category'] ?? 'other';

                              if (_selectedCategory != null && category != _selectedCategory) {
                                return const SizedBox.shrink();
                              }

                              final bool alreadyAdded = _exercises.any((e) => e["id"] == tech.id);

                              return ListTile(
                                title: Text(data['name'] ?? tech.id),
                                subtitle: Text(
                                  "${(data['category'] ?? '—').toString().capitalize()} • ${data['level'] ?? 'All'} belt",
                                ),
                                trailing: alreadyAdded
                                    ? const Icon(Icons.check_circle, color: Colors.green)
                                    : const Icon(Icons.add_circle_outline),
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

// Safe capitalize extension
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}