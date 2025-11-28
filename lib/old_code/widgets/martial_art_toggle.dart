import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class MartialArtToggle extends StatelessWidget {
  const MartialArtToggle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final arts = appState.user?.martialArts ?? [];
    final active = appState.activeArt ?? (arts.isNotEmpty ? arts.first : null);

    return DropdownButton<String>(
      value: active,
      hint: const Text('Select art'),
      items: arts
          .map(
            (art) => DropdownMenuItem(
              value: art,
              child: Text(art[0].toUpperCase() + art.substring(1)),
            ),
          )
          .toList(),
      onChanged: (val) {
        if (val != null) {
          appState.setActiveArt(val);
        }
      },
    );
  }
}
