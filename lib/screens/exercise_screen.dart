// exercise_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'routine_detail_screen.dart';
import 'create_routine_screen.dart';
import '../utils/string_extension.dart';

class ExerciseScreen extends StatefulWidget {
  @override
  _ExerciseScreenState createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  String? selectedArt;
  String? currentBelt;
  Map<String, dynamic>? userData;

  final List<String> arts = ["taekwondo", "karate"];
  final uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      setState(() {
        userData = doc.data();
        selectedArt = userData?['martialArts']?.contains('taekwondo') == true
            ? 'taekwondo'
            : 'karate';
        currentBelt = userData?['beltLevel']?[selectedArt];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (selectedArt == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Routines"),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: DropdownButton<String>(
              value: selectedArt,
              underline: SizedBox(),
              icon: Icon(Icons.arrow_drop_down, color: Colors.white),
              items: arts.map((art) => DropdownMenuItem(
                value: art,
                child: Text(art.titleCase(), style: TextStyle(color: Colors.black)),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  selectedArt = value;
                  currentBelt = userData?['beltLevel']?[value];
                });
              },
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('routines')
            .where('art', isEqualTo: selectedArt)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final routines = snapshot.data!.docs;

          // Group routines
          final currentBeltRoutines = routines.where((r) => r['belt'] == currentBelt).toList();
          final nextBeltRoutines = routines.where((r) => _isNextBelt(r['belt'], currentBelt)).toList();
          final focusRoutines = routines.where((r) => r['focus'] != null && r['focus'] != 'full_cumulative').toList();
          final userRoutines = routines.where((r) => r['userId'] == uid).toList();
          final otherRoutines = routines.where((r) =>
              r['belt'] != currentBelt &&
              !_isNextBelt(r['belt'], currentBelt) &&
              r['focus'] == 'full_cumulative' &&
              r['userId'] == 'system').toList();

          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              _buildSection("Your Current Belt: ${currentBelt?.titleCase()} Belt", currentBeltRoutines),
              _buildSection("Next Belt Level", nextBeltRoutines),
              _buildSection("Focus Routines", focusRoutines),
              _buildSection("Your Custom Routines", userRoutines),
              _buildSection("Other System Routines", otherRoutines),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CreateRoutineScreen(art: selectedArt!)),
                ),
                icon: Icon(Icons.add),
                label: Text("Create New Routine"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List<QueryDocumentSnapshot> routines) {
    if (routines.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        ...routines.map((doc) => Card(
          margin: EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            leading: Icon(
              doc['focus']?.toString().contains('kick') == true ? Icons.directions_run :
              doc['focus']?.toString().contains('block') == true ? Icons.shield :
              doc['focus']?.toString().contains('hand') == true ? Icons.front_hand :
              Icons.fitness_center,
              size: 32,
            ),
            title: Text(doc['name']),
            subtitle: Text(
              doc['is_default'] == true ? "Official Routine" : "Your Routine",
              style: TextStyle(color: doc['is_default'] == true ? Colors.green : Colors.blue),
            ),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RoutineDetailScreen(routineDoc: doc),
                ),
              );
            },
          ),
        )).toList(),
        SizedBox(height: 16),
      ],
    );
  }

  bool _isNextBelt(String? belt, String? current) {
    if (current == null || belt == null) return false;
    final order = ['white', 'yellow', 'orange', 'green', 'blue', 'red', 'black'];
    final currIdx = order.indexOf(current.toLowerCase());
    final targetIdx = order.indexOf(belt.toLowerCase());
    return targetIdx == currIdx + 1;
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}