// providers/app_state.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../models/user.dart';

class AppState extends ChangeNotifier {
  UserProfile? _user;
  String? _activeArt;

  // Onboarding drafts
  String? _draftName;
  String? _draftEmail;
  final List<String> _draftSelectedArts = [];
  final Map<String, UserArtInfo> _draftArtDetails = {};

  UserProfile? get user => _user;
  String? get activeArt => _activeArt;

  void setActiveArt(String? art) {
    _activeArt = art;
    notifyListeners();
  }

  // ------------------- Check Onboarding -------------------
  Future<bool> checkOnboardingStatus(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

    // No Firestore doc → onboarding required
    if (!doc.exists) return false;

    // Firestore doc exists → check onboarding_completed flag
    final completed = doc.data()?['onboarding_completed'] == true;
    if (completed) {
      await _loadUserFromFirestore(uid); // load user into local state
    }
    return completed;
  }

  Future<void> _loadUserFromFirestore(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!doc.exists) return;

    _user = UserProfile.fromMap(uid, doc.data()!);
    notifyListeners();
  }

  // ------------------- Onboarding Drafts -------------------
  void draftNameEmail(String name, String email) {
    _draftName = name;
    _draftEmail = email;
    notifyListeners();
  }

  void draftAddArts(List<String> arts) {
    _draftSelectedArts.clear();
    _draftSelectedArts.addAll(arts);
    notifyListeners();
  }

  void draftSetArtDetails(String art, UserArtInfo info) {
    _draftArtDetails[art] = info;
    notifyListeners();
  }

  // ------------------- Complete Onboarding -------------------
  Future<void> completeOnboarding() async {
    final currentUser = fb.FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final now = DateTime.now();

    // Map arts with updated timestamps
    final artsMap = _draftArtDetails.map((art, info) {
      final data = info.toMap();
      data['created_at'] = Timestamp.fromDate(now);
      data['updated_at'] = Timestamp.fromDate(now);
      return MapEntry(art, data);
    });

    // Write to Firestore
    await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).set({
      'name': _draftName ?? '',
      'email': _draftEmail ?? currentUser.email ?? '',
      'martial_arts': _draftSelectedArts,
      'arts': artsMap,
      'onboarding_completed': true,
      'created_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Update local state
    _user = UserProfile(
      id: currentUser.uid,
      name: _draftName ?? '',
      email: _draftEmail ?? currentUser.email ?? '',
      martialArts: List.from(_draftSelectedArts),
      arts: Map.from(_draftArtDetails),
    );

    // Clear drafts
    _draftName = _draftEmail = null;
    _draftSelectedArts.clear();
    _draftArtDetails.clear();

    notifyListeners();
  }
}
