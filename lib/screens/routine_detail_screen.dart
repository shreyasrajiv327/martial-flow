// lib/screens/routine_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RoutineDetailScreen extends StatefulWidget {
  final QueryDocumentSnapshot routineDoc;

  const RoutineDetailScreen({required this.routineDoc});

  @override
  _RoutineDetailScreenState createState() => _RoutineDetailScreenState();
}

class _RoutineDetailScreenState extends State<RoutineDetailScreen> {
  late List<Map<String, dynamic>> plannedExercises;
  late List<List<TextEditingController>> repsControllers;
  late List<List<TextEditingController>> timeControllers;
  bool isLogging = false;

  @override
  void initState() {
    super.initState();
    final data = widget.routineDoc.data() as Map<String, dynamic>;

    // Safe casting from dynamic Firestore data
    final List<dynamic> rawExercises = data['exercises'] ?? [];
    plannedExercises = rawExercises.map((e) => Map<String, dynamic>.from(e)).toList();

    // Initialize controllers
    repsControllers = [];
    timeControllers = [];
    for (var ex in plannedExercises) {
      int sets = (ex['sets'] as num?)?.toInt() ?? 1;
      int defaultReps = (ex['reps'] as num?)?.toInt() ?? 10;

      repsControllers.add(
        List.generate(sets, (_) => TextEditingController(text: defaultReps.toString())),
      );
      timeControllers.add(
        List.generate(sets, (_) => TextEditingController(text: "")),
      );
    }
  }

  Future<void> _logWorkout() async {
    if (isLogging) return;
    setState(() => isLogging = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final data = widget.routineDoc.data() as Map<String, dynamic>;

    List<Map<String, dynamic>> loggedExercises = [];

    for (int i = 0; i < plannedExercises.length; i++) {
      var ex = plannedExercises[i];
      int sets = (ex['sets'] as num?)?.toInt() ?? 1;

      // Parse reps and time safely
      List<int> repsDone = repsControllers[i]
          .map((c) => int.tryParse(c.text) ?? (ex['reps'] as num?)?.toInt() ?? 10)
          .toList();

      List<int> timeDone = timeControllers[i]
          .map((c) => int.tryParse(c.text) ?? 0)
          .toList();

      loggedExercises.add({
        "id": ex['id'],
        "sets_done": sets,
        "reps_done": repsDone,
        "time_sec": timeDone,
      });
    }

    await FirebaseFirestore.instance.collection('exercise_logs').add({
      "userId": uid,
      "date": DateTime.now().toIso8601String().split('T').first,
      "createdAt": FieldValue.serverTimestamp(),
      "arts": [data['art']],
      "activities": [
        {
          "type": "routine",
          "art": data['art'],
          "id": widget.routineDoc.id,
          "name": data['name'],
          "completed": true,
          "timestamp": DateTime.now().millisecondsSinceEpoch,
          "notes": "",
          "exercises_done": loggedExercises,
        }
      ]
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${data['name']} logged!")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.routineDoc.data() as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(title: Text(data['name']), centerTitle: true),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: plannedExercises.length,
        itemBuilder: (context, i) {
          final ex = plannedExercises[i];
          final int sets = (ex['sets'] as num?)?.toInt() ?? 1;

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('techniques')
                .doc(data['art'])
                .collection('items')
                .doc(ex['id'])
                .get(),
            builder: (context, snap) {
              final String name = snap.hasData ? snap.data!['name'] ?? ex['id'] : ex['id'];

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 8),
                      Text("Target: $sets sets × ${ex['reps']} reps"),
                      
                      // Properly handle optional timing_sec display
                      () {
                        final int? timingSec = (ex['timing_sec'] as num?)?.toInt();
                        if (timingSec != null && timingSec > 0) {
                          return Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Text(
                              "Time per rep: $timingSec sec",
                              style: TextStyle(color: Colors.blueGrey, fontStyle: FontStyle.italic),
                            ),
                          );
                        }
                        return SizedBox.shrink(); // returns nothing if no timing
                      }(),

                      SizedBox(height: 16),
                      Text(
                        "Log performed:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),

                      // Generate set input rows
                      ...List.generate(sets, (s) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 60,
                                child: Text(
                                  "Set ${s + 1}:",
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  controller: repsControllers[i][s],
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: "Reps",
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: timeControllers[i][s],
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: "Time (sec)",
                                    hintText: "optional",
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isLogging ? null : _logWorkout,
        icon: isLogging ? CircularProgressIndicator(color: Colors.white) : Icon(Icons.check),
        label: Text(isLogging ? "Saving..." : "Log Workout"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  @override
  void dispose() {
    for (var list in repsControllers) {
      for (var c in list) c.dispose();
    }
    for (var list in timeControllers) {
      for (var c in list) c.dispose();
    }
    super.dispose();
  }
}