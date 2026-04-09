import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/music_theory/note.dart';
import '../../../core/music_theory/scale.dart';
import '../../../core/music_theory/scale_library.dart';
import '../../../state/app_state.dart';

class ScaleOverlayPanel extends StatelessWidget {
  final int overlayIndex;

  const ScaleOverlayPanel({super.key, required this.overlayIndex});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final overlay = appState.overlays[overlayIndex];

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: overlay.enabled ? overlay.color : Colors.grey,
              width: 4,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // Color indicator dot
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: overlay.enabled ? overlay.color : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              // Root note dropdown
              DropdownButton<Note>(
                value: overlay.rootNote,
                underline: const SizedBox.shrink(),
                items: Note.values.map((note) {
                  return DropdownMenuItem<Note>(
                    value: note,
                    child: Text(note.displayName()),
                  );
                }).toList(),
                onChanged: overlay.enabled
                    ? (value) {
                        if (value != null) {
                          appState.setOverlayRoot(overlayIndex, value);
                        }
                      }
                    : null,
              ),
              const SizedBox(width: 8),
              // Scale type dropdown
              Expanded(
                child: DropdownButton<Scale>(
                  value: overlay.scale,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  items: ScaleLibrary.all.map((scale) {
                    return DropdownMenuItem<Scale>(
                      value: scale,
                      child: Text(scale.name),
                    );
                  }).toList(),
                  onChanged: overlay.enabled
                      ? (value) {
                          if (value != null) {
                            appState.setOverlayScale(overlayIndex, value);
                          }
                        }
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              // Toggle/close button
              IconButton(
                icon: Icon(
                  overlay.enabled ? Icons.close : Icons.add,
                  size: 18,
                ),
                onPressed: () => appState.toggleOverlay(overlayIndex),
                tooltip: overlay.enabled ? 'Disable overlay' : 'Enable overlay',
                style: IconButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(28, 28),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
