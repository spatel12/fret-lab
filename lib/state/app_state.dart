import 'package:flutter/material.dart';
import '../core/music_theory/fretboard_calculator.dart';
import '../core/music_theory/note.dart';
import '../core/music_theory/scale.dart';
import '../core/music_theory/scale_library.dart';
import '../core/music_theory/tuning.dart';
import '../core/music_theory/tuning_presets.dart';
import '../models/overlay_config.dart';
import '../ui/widgets/fretboard/fretboard_painter.dart';

class AppState extends ChangeNotifier {
  Tuning _tuning = TuningPresets.standard;
  Tuning get tuning => _tuning;

  final List<OverlayConfig> _overlays = [
    OverlayConfig(
      rootNote: Note.c,
      scale: ScaleLibrary.major,
      color: Colors.blue.shade400,
      enabled: true,
    ),
    OverlayConfig(
      rootNote: Note.a,
      scale: ScaleLibrary.minorPentatonic,
      color: Colors.orange.shade400,
      enabled: false,
    ),
  ];

  List<OverlayConfig> get overlays => List.unmodifiable(_overlays);

  DisplayMode _displayMode = DisplayMode.noteName;
  DisplayMode get displayMode => _displayMode;

  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;

  bool _showNoteLabels = true;
  bool get showNoteLabels => _showNoteLabels;

  bool _showRoots = true;
  bool get showRoots => _showRoots;

  void setTuning(Tuning tuning) {
    _tuning = tuning;
    notifyListeners();
  }

  void updateOverlay(int index, OverlayConfig config) {
    if (index >= 0 && index < _overlays.length) {
      _overlays[index] = config;
      notifyListeners();
    }
  }

  void toggleOverlay(int index) {
    if (index >= 0 && index < _overlays.length) {
      _overlays[index] = _overlays[index].copyWith(
        enabled: !_overlays[index].enabled,
      );
      notifyListeners();
    }
  }

  void setOverlayRoot(int index, Note root) {
    if (index >= 0 && index < _overlays.length) {
      _overlays[index] = _overlays[index].copyWith(rootNote: root);
      notifyListeners();
    }
  }

  void setOverlayScale(int index, Scale scale) {
    if (index >= 0 && index < _overlays.length) {
      _overlays[index] = _overlays[index].copyWith(scale: scale);
      notifyListeners();
    }
  }

  void setDisplayMode(DisplayMode mode) {
    _displayMode = mode;
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void toggleShowNoteLabels() {
    _showNoteLabels = !_showNoteLabels;
    notifyListeners();
  }

  void toggleShowRoots() {
    _showRoots = !_showRoots;
    notifyListeners();
  }

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  List<FretboardNote> get activeNotes {
    final notes = <FretboardNote>[];
    for (int i = 0; i < _overlays.length; i++) {
      if (_overlays[i].enabled) {
        notes.addAll(FretboardCalculator.computeOverlay(
          tuning: _tuning,
          rootNote: _overlays[i].rootNote,
          scale: _overlays[i].scale,
          overlayIndex: i,
        ));
      }
    }
    return notes;
  }

  List<Color> get activeColors => _overlays.map((o) => o.color).toList();
}
