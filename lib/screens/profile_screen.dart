import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
      final last7days = now.subtract(const Duration(days: 7));

      int sessionCount = 0;
      int minutes = 0;
      int weekCount = 0;

      List<DateTime> sessionDates = [];
      List<String> recent = [];
      Map<String, int> artDist = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        sessionCount++;

        DateTime date = DateTime.tryParse(data["date"] ?? "") ?? data["createdAt"].toDate();
        sessionDates.add(date);

        if (date.isAfter(last7days)) weekCount++;

        final activities = data["activities"] as List<dynamic>? ?? [];
        for (var act in activities.take(2)) {
          recent.add("${act["name"]} (${act["type"]})");
        }

        int sessionTime = 0;
        for (var act in activities) {
          if (act["time_sec"] != null && act["time_sec"] is List) {
            sessionTime += (act["time_sec"] as List).fold(0, (sum, e) => sum + (e as int));
          }
        }
        minutes += (sessionTime ~/ 60);

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
      setState(() => loading = false);
    }
  }

  int _calculateStreak(List<DateTime> dates) {
    if (dates.isEmpty) return 0;

    final uniqueDates = dates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    final todayNormalized = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    if (uniqueDates.isEmpty || uniqueDates.first != todayNormalized) {
      return 0;
    }

    int streak = 1;
    for (int i = 1; i < uniqueDates.length; i++) {
      final expectedPreviousDay = todayNormalized.subtract(Duration(days: streak));
      if (uniqueDates[i] == expectedPreviousDay) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  @override
  Widget build(BuildContext context) {
    final bool hasNoSessions = totalSessions == 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async => await _auth.signOut(),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Welcome Back!",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Stats Cards
                  _statTile(
                    "🔥 Streak",
                    streak > 0 ? "$streak days" : "Start today to begin your streak!",
                    subtitle: streak == 0 ? "Complete a routine today!" : null,
                  ),
                  _statTile("🕒 Total Training Time", "$totalMinutes min"),
                  _statTile("📅 Sessions This Week", "$weeklySessions"),
                  _statTile("🧩 Total Sessions Logged", "$totalSessions"),

                  const SizedBox(height: 25),

                  // Art Distribution
                  const Text("🥋 Art Distribution", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (artDistribution.isEmpty)
                    _emptyStateCard(
                      icon: Icons.auto_awesome,
                      title: "No sessions yet",
                      message: "Your martial art progress will appear here once you complete your first routine.",
                    )
                  else
                    ...artDistribution.entries.map((e) => ListTile(
                          title: Text(e.key.titleCase()),
                          trailing: Text("${e.value} session${e.value == 1 ? '' : 's'}"),
                        )),

                  const SizedBox(height: 25),

                  // Recent Activity
                  const Text("📌 Recent Activity", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (recentActivities.isEmpty)
                    _emptyStateCard(
                      icon: Icons.fitness_center,
                      title: "Ready to train?",
                      message: "Complete a routine to see your recent activities here!",
                    )
                  else
                    ...recentActivities.map((e) => ListTile(
                          leading: const Icon(Icons.check_circle, color: Colors.green),
                          title: Text(e),
                        )),
                ],
              ),
            ),
    );
  }

  Widget _statTile(String label, String value, {String? subtitle}) {
    return Card(
      elevation: 2,
      child: ListTile(
        title: Text(label, style: const TextStyle(fontSize: 16)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            if (subtitle != null)
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _emptyStateCard({required IconData icon, required String title, required String message}) {
    return Card(
      color: Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, size: 48, color: Colors.grey[600]),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper extension for title case
extension StringExtension on String {
  String titleCase() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}