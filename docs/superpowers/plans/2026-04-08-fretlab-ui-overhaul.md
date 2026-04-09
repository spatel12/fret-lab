# FretLab UI Overhaul — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rename the app to "FretLab" and overhaul the UI to match a professional fretboard scale viewer — tuning chip buttons, per-string +/- controls, scale summary bar, visibility toggles, cleaner overlay panels, stats header, and all fret numbers.

**Architecture:** Incremental UI refactor touching controls, fretboard painter, home screen layout, and app state. Each task produces a working app. No music theory or audio changes needed — this is purely UI/UX + state for new toggles.

**Tech Stack:** Flutter, Provider, CustomPainter (all existing — no new dependencies)

---

## File Map

| Action | File | Responsibility |
|--------|------|----------------|
| Modify | `pubspec.yaml` | Rename package |
| Modify | `lib/main.dart` | Update app title |
| Modify | `lib/ui/screens/home_screen.dart` | New layout: stats header, summary bar, reorganized controls |
| Modify | `lib/ui/widgets/controls/tuning_selector.dart` | Rewrite: chip buttons + per-string +/- |
| Modify | `lib/ui/widgets/controls/scale_overlay_panel.dart` | Redesign: colored border, X button, cleaner layout |
| Modify | `lib/state/app_state.dart` | Add `showNoteLabels`, `showRoots` state |
| Modify | `lib/ui/widgets/fretboard/fretboard_painter.dart` | All fret numbers, respect visibility toggles |
| Modify | `lib/ui/widgets/fretboard/fretboard_widget.dart` | Pass new visibility props |
| Create | `lib/ui/widgets/controls/scale_summary_bar.dart` | Bottom bar showing notes per active overlay |
| Create | `lib/ui/widgets/controls/visibility_toggles.dart` | Notes/Roots checkboxes |

---

### Task 1: Rename App to FretLab

**Files:**
- Modify: `pubspec.yaml:1`
- Modify: `lib/main.dart:28`
- Modify: `lib/ui/screens/home_screen.dart:21`

- [ ] **Step 1: Update pubspec.yaml**

```yaml
name: fretlab
```

Change line 1 from `name: scale_generator` to `name: fretlab`.

- [ ] **Step 2: Update main.dart app title**

In `lib/main.dart`, change the `MaterialApp` title:

```dart
return MaterialApp(
  title: 'FretLab',
  debugShowCheckedModeBanner: false,
```

- [ ] **Step 3: Update home_screen.dart AppBar title**

In `lib/ui/screens/home_screen.dart`, change:

```dart
title: const Text('FretLab'),
```

- [ ] **Step 4: Run flutter analyze to verify no breakage**

Run: `/Users/sarinpatel/flutter/bin/flutter analyze lib/`
Expected: No issues found

- [ ] **Step 5: Commit**

```bash
git add pubspec.yaml lib/main.dart lib/ui/screens/home_screen.dart
git commit -m "rename: Scale Generator -> FretLab"
```

---

### Task 2: Add Visibility Toggles to AppState

**Files:**
- Modify: `lib/state/app_state.dart`

- [ ] **Step 1: Add showNoteLabels and showRoots state fields**

In `lib/state/app_state.dart`, add after the `_themeMode` field:

```dart
bool _showNoteLabels = true;
bool get showNoteLabels => _showNoteLabels;

bool _showRoots = true;
bool get showRoots => _showRoots;
```

- [ ] **Step 2: Add toggle methods**

Add after the `toggleTheme()` method:

```dart
void toggleShowNoteLabels() {
  _showNoteLabels = !_showNoteLabels;
  notifyListeners();
}

void toggleShowRoots() {
  _showRoots = !_showRoots;
  notifyListeners();
}
```

- [ ] **Step 3: Run flutter analyze**

Run: `/Users/sarinpatel/flutter/bin/flutter analyze lib/`
Expected: No issues found

- [ ] **Step 4: Commit**

```bash
git add lib/state/app_state.dart
git commit -m "feat: add showNoteLabels and showRoots visibility state"
```

---

### Task 3: Create Visibility Toggles Widget

**Files:**
- Create: `lib/ui/widgets/controls/visibility_toggles.dart`

- [ ] **Step 1: Create the widget file**

Create `lib/ui/widgets/controls/visibility_toggles.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/app_state.dart';

class VisibilityToggles extends StatelessWidget {
  const VisibilityToggles({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCheckbox(
          label: 'Notes',
          value: appState.showNoteLabels,
          onChanged: (_) => appState.toggleShowNoteLabels(),
        ),
        const SizedBox(width: 12),
        _buildCheckbox(
          label: 'Roots',
          value: appState.showRoots,
          onChanged: (_) => appState.toggleShowRoots(),
        ),
      ],
    );
  }

  Widget _buildCheckbox({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}
```

- [ ] **Step 2: Run flutter analyze**

Run: `/Users/sarinpatel/flutter/bin/flutter analyze lib/`
Expected: No issues found

- [ ] **Step 3: Commit**

```bash
git add lib/ui/widgets/controls/visibility_toggles.dart
git commit -m "feat: create VisibilityToggles widget (Notes/Roots checkboxes)"
```

---

### Task 4: Rewrite Tuning Selector — Chip Buttons + Per-String +/-

**Files:**
- Modify: `lib/ui/widgets/controls/tuning_selector.dart`

This is the biggest single UI change. The reference image shows:
- A row of pill/chip buttons for presets (Standard, Drop D, etc.)
- Below that, per-string note displays with +/- buttons for custom adjustment
- String labels (6, 5, 4, 3, 2, 1) above each note

- [ ] **Step 1: Rewrite tuning_selector.dart completely**

Replace the entire content of `lib/ui/widgets/controls/tuning_selector.dart`:

```dart
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
```

- [ ] **Step 2: Run flutter analyze**

Run: `/Users/sarinpatel/flutter/bin/flutter analyze lib/`
Expected: No issues found

- [ ] **Step 3: Commit**

```bash
git add lib/ui/widgets/controls/tuning_selector.dart
git commit -m "feat: rewrite tuning selector with chip buttons and per-string +/- controls"
```

---

### Task 5: Redesign Scale Overlay Panel

**Files:**
- Modify: `lib/ui/widgets/controls/scale_overlay_panel.dart`

The reference shows:
- Colored left border on each overlay card
- Colored dot before dropdowns
- Root note dropdown + scale dropdown (cleaner, no "Root:" / "Scale:" labels)
- X button to clear/disable the overlay

- [ ] **Step 1: Rewrite scale_overlay_panel.dart**

Replace the entire content of `lib/ui/widgets/controls/scale_overlay_panel.dart`:

```dart
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
```

- [ ] **Step 2: Run flutter analyze**

Run: `/Users/sarinpatel/flutter/bin/flutter analyze lib/`
Expected: No issues found

- [ ] **Step 3: Commit**

```bash
git add lib/ui/widgets/controls/scale_overlay_panel.dart
git commit -m "feat: redesign overlay panel with colored border, cleaner layout, X button"
```

---

### Task 6: Create Scale Summary Bar

**Files:**
- Create: `lib/ui/widgets/controls/scale_summary_bar.dart`

The reference image shows a bar at the bottom listing each active overlay's notes:
`● E Phrygian Dominant: E · F · G# · A · B · C · D  ● E Harmonic Minor: E · F# · G · A · B · C · D#`

- [ ] **Step 1: Create scale_summary_bar.dart**

Create `lib/ui/widgets/controls/scale_summary_bar.dart`:

```dart
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
                '$label: ${notes.join(' \u00b7 ')}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
```

- [ ] **Step 2: Run flutter analyze**

Run: `/Users/sarinpatel/flutter/bin/flutter analyze lib/`
Expected: No issues found

- [ ] **Step 3: Commit**

```bash
git add lib/ui/widgets/controls/scale_summary_bar.dart
git commit -m "feat: create ScaleSummaryBar showing active overlay notes"
```

---

### Task 7: Update Fretboard Painter — All Fret Numbers + Visibility Toggles

**Files:**
- Modify: `lib/ui/widgets/fretboard/fretboard_painter.dart`

Two changes:
1. Show ALL fret numbers (1-24) at the bottom, not just a sparse selection
2. Add `showNoteLabels` and `showRoots` parameters — when `showNoteLabels` is false, draw note circles without text; when `showRoots` is false, don't draw root styling

- [ ] **Step 1: Add new parameters to FretboardPainter**

In `lib/ui/widgets/fretboard/fretboard_painter.dart`, update the `FretboardPainter` class fields and constructor:

```dart
class FretboardPainter extends CustomPainter {
  final List<FretboardNote> overlayNotes;
  final DisplayMode displayMode;
  final List<Color> overlayColors;
  final int fretCount;
  final bool isDarkMode;
  final bool showNoteLabels;
  final bool showRoots;

  FretboardPainter({
    required this.overlayNotes,
    required this.displayMode,
    required this.overlayColors,
    this.fretCount = 24,
    this.isDarkMode = true,
    this.showNoteLabels = true,
    this.showRoots = true,
  });
```

- [ ] **Step 2: Update fret number drawing to show all frets**

In the `_drawFretMarkers` method, replace the sparse fret number loop:

```dart
    // Fret numbers — show all
    final textStyle = TextStyle(
      color: isDarkMode
          ? const Color(0xFF888888)
          : const Color(0xFF666666),
      fontSize: 10,
    );
    for (int fret = 1; fret <= fretCount; fret++) {
      final tp = TextPainter(
        text: TextSpan(text: '$fret', style: textStyle),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(layout.noteCenterX(fret) - tp.width / 2,
            layout.stringY(0) + 15),
      );
    }
```

This replaces the old loop that used `for (int fret = 1; fret <= fretCount; fret += (fret < 12 ? 2 : 3))` and drew numbers at the top. Now all 24 fret numbers appear at the bottom of the fretboard.

- [ ] **Step 3: Update _drawNotes to respect visibility toggles**

In the `_drawNotes` method, update the root styling and label drawing:

```dart
  void _drawNotes(Canvas canvas, FretboardLayout layout) {
    for (final note in overlayNotes) {
      final cx = layout.noteCenterX(note.fret);
      final cy = layout.stringY(note.string);
      final color = note.overlayIndex < overlayColors.length
          ? overlayColors[note.overlayIndex]
          : Colors.blue;

      final isRootStyled = note.isRoot && showRoots;
      final radius = isRootStyled ? 14.0 : 11.0;

      // Note circle
      final circlePaint = Paint()..color = color;
      canvas.drawCircle(Offset(cx, cy), radius, circlePaint);

      // Root note border
      if (isRootStyled) {
        final borderPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5;
        canvas.drawCircle(Offset(cx, cy), radius, borderPaint);
      }

      // Label text (only if showNoteLabels is true)
      if (showNoteLabels) {
        final label = switch (displayMode) {
          DisplayMode.noteName => note.note.displayName(),
          DisplayMode.scaleDegree => note.degreeName,
          DisplayMode.interval => note.intervalName,
        };

        final textStyle = TextStyle(
          color: Colors.white,
          fontSize: isRootStyled ? 10 : 9,
          fontWeight: isRootStyled ? FontWeight.bold : FontWeight.normal,
        );
        final tp = TextPainter(
          text: TextSpan(text: label, style: textStyle),
          textDirection: ui.TextDirection.ltr,
        )..layout();
        tp.paint(
          canvas,
          Offset(cx - tp.width / 2, cy - tp.height / 2),
        );
      }
    }
  }
```

- [ ] **Step 4: Update shouldRepaint to include new fields**

```dart
  @override
  bool shouldRepaint(FretboardPainter oldDelegate) {
    return overlayNotes != oldDelegate.overlayNotes ||
        displayMode != oldDelegate.displayMode ||
        overlayColors != oldDelegate.overlayColors ||
        isDarkMode != oldDelegate.isDarkMode ||
        showNoteLabels != oldDelegate.showNoteLabels ||
        showRoots != oldDelegate.showRoots;
  }
```

- [ ] **Step 5: Run flutter analyze**

Run: `/Users/sarinpatel/flutter/bin/flutter analyze lib/`
Expected: No issues found

- [ ] **Step 6: Commit**

```bash
git add lib/ui/widgets/fretboard/fretboard_painter.dart
git commit -m "feat: show all fret numbers, add showNoteLabels/showRoots support"
```

---

### Task 8: Wire FretboardWidget to Pass Visibility Props

**Files:**
- Modify: `lib/ui/widgets/fretboard/fretboard_widget.dart`

- [ ] **Step 1: Add new parameters to FretboardWidget**

In `lib/ui/widgets/fretboard/fretboard_widget.dart`, add new fields:

```dart
class FretboardWidget extends StatelessWidget {
  final List<FretboardNote> overlayNotes;
  final DisplayMode displayMode;
  final List<Color> overlayColors;
  final Tuning tuning;
  final int fretCount;
  final bool isDarkMode;
  final bool showNoteLabels;
  final bool showRoots;
  final void Function(int string, int fret)? onNoteTapped;

  const FretboardWidget({
    super.key,
    required this.overlayNotes,
    required this.displayMode,
    required this.overlayColors,
    required this.tuning,
    this.fretCount = 24,
    this.isDarkMode = true,
    this.showNoteLabels = true,
    this.showRoots = true,
    this.onNoteTapped,
  });
```

- [ ] **Step 2: Pass new props to FretboardPainter**

In the `build` method, update the `FretboardPainter` constructor call:

```dart
                child: CustomPaint(
                  size: Size(width, height),
                  painter: FretboardPainter(
                    overlayNotes: overlayNotes,
                    displayMode: displayMode,
                    overlayColors: overlayColors,
                    fretCount: fretCount,
                    isDarkMode: isDarkMode,
                    showNoteLabels: showNoteLabels,
                    showRoots: showRoots,
                  ),
                ),
```

- [ ] **Step 3: Run flutter analyze**

Run: `/Users/sarinpatel/flutter/bin/flutter analyze lib/`
Expected: No issues found

- [ ] **Step 4: Commit**

```bash
git add lib/ui/widgets/fretboard/fretboard_widget.dart
git commit -m "feat: pass showNoteLabels/showRoots through FretboardWidget"
```

---

### Task 9: Rewire Home Screen — Stats, Summary Bar, New Layout

**Files:**
- Modify: `lib/ui/screens/home_screen.dart`

This is where everything comes together. The new layout:
1. AppBar with "FretLab" title + stats subtitle + theme toggle
2. Tuning selector (chips + per-string +/-)
3. Overlay panels row + visibility toggles + display mode toggle
4. Fretboard (expanded)
5. Scale summary bar at bottom

- [ ] **Step 1: Rewrite home_screen.dart**

Replace the entire content of `lib/ui/screens/home_screen.dart`:

```dart
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
```

- [ ] **Step 2: Run flutter analyze**

Run: `/Users/sarinpatel/flutter/bin/flutter analyze lib/`
Expected: No issues found

- [ ] **Step 3: Run existing tests to verify no regressions**

Run: `/Users/sarinpatel/flutter/bin/flutter test`
Expected: All 39 tests pass

- [ ] **Step 4: Commit**

```bash
git add lib/ui/screens/home_screen.dart
git commit -m "feat: rewire home screen with stats header, summary bar, visibility toggles"
```

---

### Task 10: Increase Fretboard Bottom Padding for Fret Numbers

**Files:**
- Modify: `lib/ui/widgets/fretboard/fretboard_painter.dart`

The fret numbers now render at the bottom (below the lowest string). We need to increase `bottomPadding` so they don't get clipped.

- [ ] **Step 1: Update FretboardLayout default bottomPadding**

In `lib/ui/widgets/fretboard/fretboard_painter.dart`, change the `FretboardLayout` constructor default:

```dart
  FretboardLayout({
    required this.width,
    required this.height,
    this.fretCount = 24,
    this.topPadding = 20,
    this.bottomPadding = 40,
    this.leftPadding = 40,
    this.nutWidth = 6,
  });
```

Changed `topPadding` from 30 to 20 (fret numbers moved to bottom so less top space needed) and `bottomPadding` from 30 to 40 (more room for fret numbers below strings).

- [ ] **Step 2: Run flutter analyze**

Run: `/Users/sarinpatel/flutter/bin/flutter analyze lib/`
Expected: No issues found

- [ ] **Step 3: Commit**

```bash
git add lib/ui/widgets/fretboard/fretboard_painter.dart
git commit -m "fix: adjust fretboard padding for bottom fret numbers"
```

---

## Self-Review Checklist

1. **Spec coverage:**
   - [x] App rename to FretLab (Task 1)
   - [x] Tuning chip buttons (Task 4)
   - [x] Per-string +/- buttons (Task 4)
   - [x] Scale summary bar at bottom (Task 6)
   - [x] Notes/Roots visibility checkboxes (Tasks 2, 3)
   - [x] Cleaner overlay panels with colored border + X button (Task 5)
   - [x] Stats in header (Task 9)
   - [x] All fret numbers at bottom (Task 7)
   - [x] Visibility props wired through widget (Task 8)
   - [x] Home screen layout reorganized (Task 9)
   - [x] Padding adjusted for fret numbers (Task 10)

2. **Placeholder scan:** No TBD/TODO/placeholder found.

3. **Type consistency:**
   - `showNoteLabels` / `showRoots` — consistent across AppState (Task 2), VisibilityToggles (Task 3), FretboardPainter (Task 7), FretboardWidget (Task 8), HomeScreen (Task 9)
   - `OverlayConfig` — unchanged, used consistently
   - `DisplayMode` — unchanged, used consistently
   - `ScaleSummaryBar` — created in Task 6, imported in Task 9
   - `VisibilityToggles` — created in Task 3, imported in Task 9
