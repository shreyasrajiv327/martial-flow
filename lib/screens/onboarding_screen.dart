import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();

  // User info
  int? age;
  String? gender;
  double? height;
  double? weight;

  // Martial arts
  final List<String> martialArtsOptions = ["Taekwondo", "Karate"];
  List<String> selectedArts = [];

  // Belt levels
  Map<String, String?> beltLevel = {};

  // Base goals (always shown)
  final List<String> commonGoals = [
    "Belt Progression",
    "Championships",
    "Skill Enhancement",
  ];

  // Art-specific goals
  final String poomsaeGoal = "Poomsae (Taekwondo)";
  final String kataGoal = "Kata (Karate)";

  List<String> selectedGoals = [];

  bool _loading = false;
  String? errorMsg;

  // Dynamically build the visible goals list
  List<String> get visibleGoalsOptions {
    List<String> options = [...commonGoals];

    if (selectedArts.contains("Taekwondo")) {
      options.add(poomsaeGoal);
    }
    if (selectedArts.contains("Karate")) {
      options.add(kataGoal);
    }

    return options;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Complete Your Profile"),
          automaticallyImplyLeading: false,
        ),
        body: _loading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // === Personal Info ===
                      Text("Personal Info", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 12),
                      TextFormField(
                        decoration: InputDecoration(labelText: "Age *"),
                        keyboardType: TextInputType.number,
                        validator: (val) => val?.isEmpty ?? true ? "Enter your age" : null,
                        onSaved: (val) => age = int.tryParse(val ?? ''),
                      ),
                      SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: "Gender *"),
                        items: ["Male", "Female", "Other"]
                            .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                            .toList(),
                        validator: (val) => val == null ? "Select gender" : null,
                        onChanged: (val) => setState(() => gender = val),
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        decoration: InputDecoration(labelText: "Height (cm) *"),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        validator: (val) => val?.isEmpty ?? true ? "Enter height" : null,
                        onSaved: (val) => height = double.tryParse(val ?? ''),
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        decoration: InputDecoration(labelText: "Weight (kg) *"),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        validator: (val) => val?.isEmpty ?? true ? "Enter weight" : null,
                        onSaved: (val) => weight = double.tryParse(val ?? ''),
                      ),

                      SizedBox(height: 30),

                      // === Martial Arts (MANDATORY) ===
                      Text("Martial Arts Practiced *", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("Select at least one", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                      SizedBox(height: 8),

                      ...martialArtsOptions.map((art) => CheckboxListTile(
                        title: Text(art),
                        value: selectedArts.contains(art),
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              selectedArts.add(art);
                              beltLevel[art] = null;
                            } else {
                              selectedArts.remove(art);
                              beltLevel.remove(art);
                              // Remove art-specific goals if deselecting the art
                              if (art == "Taekwondo") selectedGoals.remove(poomsaeGoal);
                              if (art == "Karate") selectedGoals.remove(kataGoal);
                            }
                          });
                        },
                      )),

                      if (selectedArts.isEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 8, left: 12),
                          child: Text(
                            "Please select at least one martial art",
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),

                      SizedBox(height: 12),

                      // Belt levels
                      ...selectedArts.map((art) {
                        final levels = art == "Taekwondo"
                            ? ["White", "Yellow", "Green", "Blue", "Red", "Black"]
                            : ["White", "Yellow", "Orange", "Green", "Blue", "Brown", "Black"];

                        return Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: "$art Belt Level *",
                              border: OutlineInputBorder(),
                            ),
                            items: levels.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                            value: beltLevel[art],
                            validator: (_) => beltLevel[art] == null ? "Select your belt level" : null,
                            onChanged: (val) => setState(() => beltLevel[art] = val),
                          ),
                        );
                      }),

                      SizedBox(height: 30),

                      // === Goals (MANDATORY) ===
                      Text("Your Goals *", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("Select all that apply", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                      SizedBox(height: 8),

                      ...visibleGoalsOptions.map((goal) => CheckboxListTile(
                        title: Text(goal),
                        value: selectedGoals.contains(goal),
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              selectedGoals.add(goal);
                            } else {
                              selectedGoals.remove(goal);
                            }
                          });
                        },
                      )),

                      if (selectedGoals.isEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 8, left: 12),
                          child: Text(
                            "Please select at least one goal",
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),

                      if (errorMsg != null)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(errorMsg!, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          ),
                        ),

                      SizedBox(height: 30),

                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16)),
                          child: Text("Save & Continue", style: TextStyle(fontSize: 16)),
                          onPressed: _saveOnboarding,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _saveOnboarding() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedArts.isEmpty) {
      setState(() => errorMsg = "Select at least one martial art");
      return;
    }
    if (selectedGoals.isEmpty) {
      setState(() => errorMsg = "Select at least one goal");
      return;
    }

    setState(() {
      _loading = true;
      errorMsg = null;
    });

    _formKey.currentState!.save();

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final Map<String, String> cleanBeltLevel = {};
      beltLevel.forEach((key, value) {
        if (value != null) cleanBeltLevel[key] = value.toLowerCase();
      });

      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        "age": age,
        "gender": gender,
        "height": height,
        "weight": weight,
        "martialArts": selectedArts,
        "beltLevel": cleanBeltLevel,
        "goals": selectedGoals,
        "onboarded": true,
      }, SetOptions(merge: true));

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      setState(() {
        errorMsg = "Failed to save profile. Please try again.";
        _loading = false;
      });
      print("Onboarding save error: $e");
    }
  }
}