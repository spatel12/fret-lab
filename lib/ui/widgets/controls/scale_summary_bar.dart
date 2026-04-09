import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/app_state.dart';

class ScaleSummaryBar extends StatelessWidget {
  const ScaleSummaryBar({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final activeOverlays = <(int, String, List<String>, Color)>[];

    for (int i = 0; i < appState.overlays.length; i++) {
      final overlay = appState.overlays[i];
      if (overlay.enabled) {
        final rootName = overlay.rootNote.displayName();
        final scaleName = overlay.scale.name;
        final notes = overlay.scale
            .notesFrom(overlay.rootNote)
            .map((n) => n.displayName())
            .toList();
        activeOverlays.add((i, '$rootName $scaleName', notes, overlay.color));
      }
    }

    if (activeOverlays.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 24,
        runSpacing: 4,
        children: activeOverlays.map((entry) {
          final (_, label, notes, color) = entry;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$label: ${notes.join(' · ')}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
