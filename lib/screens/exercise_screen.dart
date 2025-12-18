// exercise_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'routine_detail_screen.dart';
import 'create_routine_screen.dart';

class ExerciseScreen extends StatefulWidget {
  @override
  _ExerciseScreenState createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  String? selectedArt;
  String? currentBelt;
  Map<String, dynamic>? userData;

  List<String> userArts = []; // Will be populated from Firestore
  final uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      final List<dynamic> martialArtsDynamic = data['martialArts'] ?? [];

      // Convert to List<String> and normalize to lowercase for consistency
      final List<String> fetchedArts = martialArtsDynamic
          .map((art) => art.toString().toLowerCase())
          .toList();

      setState(() {
        userData = data;
        userArts = fetchedArts;

        // Default selection: prefer taekwondo if available, else first one
        selectedArt = userArts.contains('taekwondo')
            ? 'taekwondo'
            : userArts.isNotEmpty
                ? userArts.first
                : null;

        // Load current belt for selected art
        final beltMap = data['beltLevel'] as Map<String, dynamic>? ?? {};
        currentBelt = beltMap[selectedArt]?.toString().toLowerCase();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading until user data (and arts) are loaded
    if (selectedArt == null || userArts.isEmpty) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
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
              items: userArts.map((art) => DropdownMenuItem<String>(
                value: art,
                child: Text(
                  art,
                  style: TextStyle(color: Colors.black),
                ),
              )).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedArt = value;
                    final beltMap = userData?['beltLevel'] as Map<String, dynamic>? ?? {};
                    currentBelt = beltMap[value]?.toString().toLowerCase();
                  });
                }
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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No routines available for $selectedArt yet."));
          }

          final routines = snapshot.data!.docs;

          // Group routines
          final currentBeltRoutines = routines.where((r) => r['belt']?.toString().toLowerCase() == currentBelt).toList();
          final nextBeltRoutines = routines.where((r) => _isNextBelt(r['belt']?.toString().toLowerCase(), currentBelt)).toList();
          final focusRoutines = routines.where((r) =>
              r['focus'] != null && r['focus'] != 'full_cumulative').toList();
          final userRoutines = routines.where((r) => r['userId'] == uid).toList();
          final otherRoutines = routines.where((r) =>
              r['belt']?.toString().toLowerCase() != currentBelt &&
              !_isNextBelt(r['belt']?.toString().toLowerCase(), currentBelt) &&
              r['focus'] == 'full_cumulative' &&
              r['userId'] == 'system').toList();

          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              _buildSection("Your Current Belt: $currentBelt Belt", currentBeltRoutines),
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
              doc['focus']?.toString().toLowerCase().contains('kick') == true
                  ? Icons.directions_run
                  : doc['focus']?.toString().toLowerCase().contains('block') == true
                      ? Icons.shield
                      : doc['focus']?.toString().toLowerCase().contains('hand') == true
                          ? Icons.front_hand
                          : Icons.fitness_center,
              size: 32,
            ),
            title: Text(doc['name'] ?? 'Unnamed Routine'),
            subtitle: Text(
              doc['is_default'] == true ? "Official Routine" : "Your Routine",
              style: TextStyle(
                color: doc['is_default'] == true ? Colors.green : Colors.blue,
              ),
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
    if (currIdx == -1 || targetIdx == -1) return false;
    return targetIdx == currIdx + 1;
  }
}