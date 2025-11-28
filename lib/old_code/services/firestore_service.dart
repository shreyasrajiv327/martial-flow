import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/technique.dart';
import '../models/routine.dart';
import '../models/progress.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  // Techniques
  Future<List<Technique>> getTechniques() async {
    final snapshot = await _db.collection('techniques').get();
    return snapshot.docs.map((doc) => Technique.fromMap(doc.id, doc.data())).toList();
  }

  // Routines
  Future<List<Routine>> getRoutines({String? userId}) async {
    final snapshot = userId == null
      ? await _db.collection('routines').get()
      : await _db.collection('routines').where('ownerId', isEqualTo: userId).get();
    return snapshot.docs.map((doc) => Routine.fromMap(doc.id, doc.data())).toList();
  }
  Future<void> createRoutine(Routine routine, String userId) async {
    await _db.collection('routines').add({
      ...routine.toMap(),
      'ownerId': userId
    });
  }
  Future<void> updateRoutine(Routine routine) async {
    await _db.collection('routines').doc(routine.id).update(routine.toMap());
  }
  Future<void> deleteRoutine(String routineId) async {
    await _db.collection('routines').doc(routineId).delete();
  }

  // Progress Tracking
  Future<List<ProgressEntry>> getProgress(String userId) async {
    final snapshot = await _db.collection('progress').where('userId', isEqualTo: userId).orderBy('timestamp', descending: true).get();
    return snapshot.docs.map((doc) => ProgressEntry.fromMap(doc.id, doc.data())).toList();
  }

  Future<void> addProgressEntry(String userId, String routineId) async {
    await _db.collection('progress').add({
      'userId': userId,
      'routineId': routineId,
      'completed': true,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
