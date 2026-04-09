import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/app_state.dart';
import '../fretboard/fretboard_painter.dart';

class DisplayModeToggle extends StatelessWidget {
  const DisplayModeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return SegmentedButton<DisplayMode>(
      segments: const [
        ButtonSegment(
          value: DisplayMode.noteName,
          label: Text('Note'),
          icon: Icon(Icons.music_note),
        ),
        ButtonSegment(
          value: DisplayMode.scaleDegree,
          label: Text('Degree'),
          icon: Icon(Icons.tag),
        ),
        ButtonSegment(
          value: DisplayMode.interval,
          label: Text('Interval'),
          icon: Icon(Icons.straighten),
        ),
      ],
      selected: {appState.displayMode},
      onSelectionChanged: (modes) {
        appState.setDisplayMode(modes.first);
      },
    );
  }
}
