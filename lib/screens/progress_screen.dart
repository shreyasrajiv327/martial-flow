// screens/progress_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/app_state.dart';
import '../models/log.dart';
import '../widgets/progress_indicator_widget.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String? userId =
        "current_user_id"; // TODO: Replace with real auth later
    final String? activeArt = Provider.of<AppState>(context).activeArt;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view progress')),
      );
    }

    Query query = FirebaseFirestore.instance
        .collection('exercise_logs')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true);

    // Newest first

    // Optional: filter by selected art
    if (activeArt != null && activeArt.isNotEmpty) {
      query = query.where('art', isEqualTo: activeArt);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Training Log'),
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 90, color: Colors.grey[400]),
                  const SizedBox(height: 20),
                  const Text(
                    'No training logged yet',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    activeArt == null
                        ? 'Complete a routine to see your history'
                        : 'No logs for $activeArt yet',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          // Parse logs
          final List<ExerciseLog> logs = docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return ExerciseLog.fromMap(doc.id, data);
          }).toList();

          // Group by date
          final Map<String, List<ExerciseLog>> groupedByDate = {};
          for (var log in logs) {
            final date = DateTime.fromMillisecondsSinceEpoch(
              log.timestamp * 1000,
            );
            final key = DateFormat('yyyy-MM-dd').format(date);
            groupedByDate.putIfAbsent(key, () => []).add(log);
          }

          final totalSessions = groupedByDate.length;
          final totalSets = logs.fold<int>(0, (sum, log) => sum + log.setsDone);
          final uniqueTechs = logs.map((e) => e.techId).toSet().length;

          return Column(
            children: [
              // Stats Card with your ProgressIndicatorWidget
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.shade600,
                      Colors.deepPurple.shade800,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'This Week',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    ProgressIndicatorWidget(
                      completed: totalSets,
                      total: totalSets + 30, // Example goal: 30 sets/week
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatItem(
                          label: "Sessions",
                          value: totalSessions.toString(),
                        ),
                        _StatItem(label: "Sets", value: totalSets.toString()),
                        _StatItem(
                          label: "Techniques",
                          value: uniqueTechs.toString(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Daily Log List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: groupedByDate.keys.length,
                  itemBuilder: (context, index) {
                    final dateKey = groupedByDate.keys.elementAt(index);
                    final dayLogs = groupedByDate[dateKey]!;

                    final date = DateTime.parse(dateKey);
                    final isToday =
                        dateKey ==
                        DateFormat('yyyy-MM-dd').format(DateTime.now());

                    final formattedDate = isToday
                        ? "Today"
                        : DateFormat('EEEE, MMM d').format(date);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                          child: Text(
                            formattedDate,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                        ...dayLogs.map((log) => _LogTile(log: log)).toList(),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Small reusable stat item
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.white70),
        ),
      ],
    );
  }
}

// Individual log entry tile
class _LogTile extends StatelessWidget {
  final ExerciseLog log;
  const _LogTile({required this.log});

  @override
  Widget build(BuildContext context) {
    final time = DateFormat(
      'h:mm a',
    ).format(DateTime.fromMillisecondsSinceEpoch(log.timestamp * 1000));

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('techniques')
          .doc(log.art)
          .collection('items')
          .doc(log.techId)
          .get(),
      builder: (context, snapshot) {
        String techName = log.techId;
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          techName = data['name'] ?? techName;
        }

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.deepPurple.shade100,
              child: Text(
                techName[0].toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            title: Text(
              techName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              "${log.setsDone} sets • ${log.repsDone.join(' + ')} reps",
            ),
            trailing: Text(time, style: const TextStyle(color: Colors.grey)),
            onTap: () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text(techName),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Sets completed: ${log.setsDone}"),
                    Text("Reps: ${log.repsDone.join(', ')}"),
                    Text("Time per rep: ${log.timeSec.join(', ')} sec"),
                    if (log.notes.isNotEmpty) ...[
                      const Divider(height: 20),
                      Text(
                        "Notes: ${log.notes}",
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
