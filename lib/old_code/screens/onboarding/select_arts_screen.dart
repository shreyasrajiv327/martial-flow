import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart'; 
import '../../models/user.dart';
class SelectArtsScreen extends StatefulWidget {
  const SelectArtsScreen({Key? key}) : super(key: key);

  @override
  State<SelectArtsScreen> createState() =>
      _SelectArtsAndBeltsScreenState();
}

class _SelectArtsAndBeltsScreenState extends State<SelectArtsScreen> {
  // List of all martial arts (THIS is where the list comes from)
  final List<String> allArts = [
    'taekwondo',
    'karate',
    'judo',
    'bjj',
    'muay thai',
  ];

  final Set<String> selectedArts = {};
  final Map<String, String> selectedBelts = {};

  // Belt list (Customize if needed)
  final List<String> beltLevels = [
    "White",
    "Yellow",
    "Orange",
    "Green",
    "Blue",
    "Purple",
    "Brown",
    "Red",
    "Black",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select arts & belt level")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Which martial arts do you practice?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView(
                children: allArts.map((art) {
                  return CheckboxListTile(
                    title: Text(art[0].toUpperCase() + art.substring(1)),
                    value: selectedArts.contains(art),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          selectedArts.add(art);
                          selectedBelts[art] = beltLevels.first;
                        } else {
                          selectedArts.remove(art);
                          selectedBelts.remove(art);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),

            if (selectedArts.isNotEmpty)
              const Text(
                "Select your belt level for each art:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

            // belts section
            if (selectedArts.isNotEmpty)
              Expanded(
                child: ListView(
                  children: selectedArts.map((art) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            art[0].toUpperCase() + art.substring(1),
                            style: const TextStyle(fontSize: 16),
                          ),
                          DropdownButton<String>(
                            value: selectedBelts[art],
                            items: beltLevels
                                .map((b) =>
                                    DropdownMenuItem(value: b, child: Text(b)))
                                .toList(),
                            onChanged: (val) {
                              setState(() {
                                selectedBelts[art] = val!;
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

            ElevatedButton(
              onPressed: selectedArts.isEmpty
                  ? null
                  : () {
                      // send to Provider
                      Provider.of<AppState>(context, listen: false)
                          .draftAddArts(selectedArts.toList());

                      for (var art in selectedArts) {
                        Provider.of<AppState>(context, listen: false)
                            .draftSetArtDetails(
                          art,
                          UserArtInfo(
                            belt: selectedBelts[art] ?? "",
                            experienceLevel: "",
                            goals: [],
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now(),
                          ),
                        );
                      }

                      Provider.of<AppState>(context, listen: false)
                          .completeOnboarding();

                      Navigator.pop(context); // or go to profile
                    },
              child: const Text("Finish"),
            ),
          ],
        ),
      ),
    );
  }
}
