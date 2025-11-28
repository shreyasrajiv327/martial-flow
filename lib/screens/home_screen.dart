// import 'package:flutter/material.dart';
// import '../services/auth_service.dart';

// class HomeScreen extends StatelessWidget {
//   final _auth = AuthService.instance;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Home"),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.logout),
//             onPressed: () async {
//               await _auth.signOut();
//               // No manual navigation needed — AuthWrapper will handle redirect
//             },
//           )
//         ],
//       ),
//       body: Center(child: Text("Welcome!")),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = AuthService.instance;
  bool loading = true;

  int totalSessions = 0;
  int totalMinutes = 0;
  int weeklySessions = 0;
  int streak = 0;

  List<String> recentActivities = [];
  Map<String, int> artDistribution = {};

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  /// MAIN STATS FETCHER
  Future<void> _fetchStats() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('exercise_logs')
          .where("userId", isEqualTo: userId)
          .orderBy("createdAt", descending: true)
          .get();

      final now = DateTime.now();
      final last7days = now.subtract(Duration(days: 7));

      int sessionCount = 0;
      int minutes = 0;
      int weekCount = 0;

      List<DateTime> sessionDates = [];
      List<String> recent = [];
      Map<String, int> artDist = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        sessionCount++;

        // Track dates for streak calculation
        DateTime date = DateTime.tryParse(data["date"] ?? "") ?? data["createdAt"].toDate();
        sessionDates.add(date);

        // Weekly count
        if (date.isAfter(last7days)) weekCount++;

        // Activities (extract names)
        final activities = data["activities"] as List<dynamic>? ?? [];
        for (var act in activities.take(2)) {
          recent.add("${act["name"]} (${act["type"]})");
        }

        // Time calculation if available
        int sessionTime = 0;
        for (var act in activities) {
          if (act["time_sec"] != null && act["time_sec"] is List) {
            sessionTime += (act["time_sec"] as List).fold(0, (sum, e) => sum + (e as int));
          }
        }
        minutes += (sessionTime ~/ 60);

        // Martial Art Distribution
        final arts = data["arts"] as List<dynamic>? ?? [];
        for (var art in arts) {
          artDist[art] = (artDist[art] ?? 0) + 1;
        }
      }

      sessionDates.sort((a, b) => b.compareTo(a));

      int streakCount = _calculateStreak(sessionDates);

      setState(() {
        totalSessions = sessionCount;
        totalMinutes = minutes;
        weeklySessions = weekCount;
        streak = streakCount;
        recentActivities = recent.take(5).toList();
        artDistribution = artDist;
        loading = false;
      });
    } catch (e) {
      print("Error fetching stats: $e");
    }
  }

  int _calculateStreak(List<DateTime> dates) {
    if (dates.isEmpty) return 0;

    int count = 1;
    DateTime today = DateTime.now();
    DateTime lastDate = dates.first;

    if (!_isSameDay(today, lastDate)) count = 0;

    for (int i = 0; i < dates.length - 1; i++) {
      final diff = dates[i].difference(dates[i + 1]).inDays;
      if (diff == 1) {
        count++;
      } else {
        break;
      }
    }

    return count;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
            },
          )
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Welcome Back!", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),

                  SizedBox(height: 20),

                  _statTile("🔥 Streak", "$streak days"),
                  _statTile("🕒 Total Training Time", "${totalMinutes} min"),
                  _statTile("📅 Sessions This Week", "$weeklySessions"),
                  _statTile("🧩 Total Sessions Logged", "$totalSessions"),

                  SizedBox(height: 25),
                  Text("🥋 Art Distribution", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ...artDistribution.entries.map((e) => ListTile(
                        title: Text(e.key),
                        trailing: Text("${e.value} sessions"),
                      )),

                  SizedBox(height: 25),
                  Text("📌 Recent Activity", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ...recentActivities.map((e) => ListTile(title: Text(e))),
                ],
              ),
            ),
    );
  }

  Widget _statTile(String label, String value) {
    return Card(
      child: ListTile(
        title: Text(label),
        trailing: Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

