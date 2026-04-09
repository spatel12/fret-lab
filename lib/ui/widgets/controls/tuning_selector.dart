import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/music_theory/note.dart';
import '../../../core/music_theory/tuning.dart';
import '../../../core/music_theory/tuning_presets.dart';
import '../../../state/app_state.dart';

class TuningSelector extends StatelessWidget {
  const TuningSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final tuning = appState.tuning;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tuning preset chips
        Row(
          children: [
            const Text('TUNING',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2)),
            const SizedBox(width: 12),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: TuningPresets.all.map((preset) {
                    final isSelected = tuning.name == preset.name;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(preset.name),
                        selected: isSelected,
                        onSelected: (_) => appState.setTuning(preset),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Per-string +/- controls
        _PerStringControls(tuning: tuning, appState: appState),
      ],
    );
  }
}

class _PerStringControls extends StatelessWidget {
  final Tuning tuning;
  final AppState appState;

  const _PerStringControls({
    required this.tuning,
    required this.appState,
  });

  @override
  Widget build(BuildContext context) {
    // String labels from low (6th) to high (1st)
    const stringLabels = ['6', '5', '4', '3', '2', '1'];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(6, (i) {
        final note = tuning.openStrings[i];
        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Column(
            children: [
              Text(stringLabels[i],
                  style: const TextStyle(
                      fontSize: 10, color: Colors.grey)),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SmallButton(
                    icon: Icons.remove,
                    onPressed: () => _adjustString(i, -1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: SizedBox(
                      width: 24,
                      child: Text(
                        note.displayName(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  _SmallButton(
                    icon: Icons.add,
                    onPressed: () => _adjustString(i, 1),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  void _adjustString(int stringIndex, int semitones) {
    final newStrings = List<Note>.from(tuning.openStrings);
    newStrings[stringIndex] = newStrings[stringIndex].transpose(semitones);
    appState.setTuning(Tuning(
      'Custom',
      newStrings,
      tuning.baseOctaves,
    ));
  }
}

class _SmallButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _SmallButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 14,
        icon: Icon(icon),
        onPressed: onPressed,
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}
