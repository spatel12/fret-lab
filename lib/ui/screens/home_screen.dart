import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../state/audio_state.dart';
import '../widgets/controls/display_mode_toggle.dart';
import '../widgets/controls/scale_overlay_panel.dart';
import '../widgets/controls/tuning_selector.dart';
import '../widgets/fretboard/fretboard_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final audioState = context.read<AudioState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('FretLab'),
        actions: [
          IconButton(
            icon: Icon(appState.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Toggle theme',
            onPressed: () => appState.toggleTheme(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Controls row
            Wrap(
              spacing: 16,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const TuningSelector(),
                const DisplayModeToggle(),
              ],
            ),
            const SizedBox(height: 12),
            // Scale overlay panels
            const ScaleOverlayPanel(overlayIndex: 0),
            const SizedBox(height: 4),
            const ScaleOverlayPanel(overlayIndex: 1),
            const SizedBox(height: 16),
            // Fretboard
            Expanded(
              child: FretboardWidget(
                overlayNotes: appState.activeNotes,
                displayMode: appState.displayMode,
                overlayColors: appState.activeColors,
                tuning: appState.tuning,
                isDarkMode: appState.isDarkMode,
                onNoteTapped: (string, fret) {
                  audioState.playNote(appState.tuning, string, fret);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
