import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import 'art_details_screen.dart';

class SelectArtsScreen extends StatefulWidget {
  const SelectArtsScreen({Key? key}) : super(key: key);
  @override
  State<SelectArtsScreen> createState() => _SelectArtsScreenState();
}

class _SelectArtsScreenState extends State<SelectArtsScreen> {
  final List<String> allArts = [
    'taekwondo',
    'karate',
    'judo',
    'bjj',
    'muay thai',
  ];
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Which martial arts do you practice?')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: allArts
                    .map(
                      (art) => CheckboxListTile(
                        title: Text(art[0].toUpperCase() + art.substring(1)),
                        value: _selected.contains(art),
                        onChanged: (val) {
                          setState(() {
                            val! ? _selected.add(art) : _selected.remove(art);
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
            ElevatedButton(
              child: const Text('Continue'),
              onPressed: _selected.isEmpty
                  ? null
                  : () {
                      Provider.of<AppState>(
                        context,
                        listen: false,
                      ).draftAddArts(_selected.toList());
                      // Go to art details for the first selected art
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ArtDetailsScreen(
                            arts: _selected.toList(),
                            index: 0,
                          ),
                        ),
                      );
                    },
            ),
          ],
        ),
      ),
    );
  }
}
