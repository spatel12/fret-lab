import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../state/audio_state.dart';
import '../widgets/controls/display_mode_toggle.dart';
import '../widgets/controls/scale_overlay_panel.dart';
import '../widgets/controls/scale_summary_bar.dart';
import '../widgets/controls/tuning_selector.dart';
import '../widgets/controls/visibility_toggles.dart';
import '../widgets/fretboard/fretboard_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final audioState = context.read<AudioState>();

    // Count active overlays
    final activeCount =
        appState.overlays.where((o) => o.enabled).length;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('FretLab',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 12),
            Text(
              '24 frets \u00b7 $activeCount ${activeCount == 1 ? 'scale' : 'scales'} \u00b7 6 strings',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon:
                Icon(appState.isDarkMode ? Icons.light_mode : Icons.dark_mode),
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
            // Tuning controls (chips + per-string +/-)
            const TuningSelector(),
            const SizedBox(height: 12),
            // Scale overlays + controls row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overlay panels stacked
                Expanded(
                  child: Column(
                    children: const [
                      ScaleOverlayPanel(overlayIndex: 0),
                      SizedBox(height: 4),
                      ScaleOverlayPanel(overlayIndex: 1),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Right controls column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    VisibilityToggles(),
                    SizedBox(height: 8),
                    DisplayModeToggle(),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Fretboard
            Expanded(
              child: FretboardWidget(
                overlayNotes: appState.activeNotes,
                displayMode: appState.displayMode,
                overlayColors: appState.activeColors,
                tuning: appState.tuning,
                isDarkMode: appState.isDarkMode,
                showNoteLabels: appState.showNoteLabels,
                showRoots: appState.showRoots,
                onNoteTapped: (string, fret) {
                  audioState.playNote(appState.tuning, string, fret);
                },
              ),
            ),
            // Scale summary bar
            const ScaleSummaryBar(),
          ],
        ),
      ),
    );
  }
}
