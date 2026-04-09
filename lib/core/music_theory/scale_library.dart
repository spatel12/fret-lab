import 'scale.dart';

class ScaleLibrary {
  // Major & Minor
  static const major = Scale('Major (Ionian)', 'Major & Minor', [0, 2, 4, 5, 7, 9, 11]);
  static const naturalMinor = Scale('Natural Minor (Aeolian)', 'Major & Minor', [0, 2, 3, 5, 7, 8, 10]);
  static const harmonicMinor = Scale('Harmonic Minor', 'Major & Minor', [0, 2, 3, 5, 7, 8, 11]);
  static const melodicMinor = Scale('Melodic Minor', 'Major & Minor', [0, 2, 3, 5, 7, 9, 11]);

  // Pentatonic & Blues
  static const majorPentatonic = Scale('Major Pentatonic', 'Pentatonic & Blues', [0, 2, 4, 7, 9]);
  static const minorPentatonic = Scale('Minor Pentatonic', 'Pentatonic & Blues', [0, 3, 5, 7, 10]);
  static const blues = Scale('Blues', 'Pentatonic & Blues', [0, 3, 5, 6, 7, 10]);

  // Modes
  static const dorian = Scale('Dorian', 'Modes', [0, 2, 3, 5, 7, 9, 10]);
  static const phrygian = Scale('Phrygian', 'Modes', [0, 1, 3, 5, 7, 8, 10]);
  static const lydian = Scale('Lydian', 'Modes', [0, 2, 4, 6, 7, 9, 11]);
  static const mixolydian = Scale('Mixolydian', 'Modes', [0, 2, 4, 5, 7, 9, 10]);
  static const locrian = Scale('Locrian', 'Modes', [0, 1, 3, 5, 6, 8, 10]);

  // Exotic
  static const wholeTone = Scale('Whole Tone', 'Exotic', [0, 2, 4, 6, 8, 10]);
  static const diminishedWH = Scale('Diminished (W-H)', 'Exotic', [0, 2, 3, 5, 6, 8, 9, 11]);
  static const diminishedHW = Scale('Diminished (H-W)', 'Exotic', [0, 1, 3, 4, 6, 7, 9, 10]);
  static const hungarianMinor = Scale('Hungarian Minor', 'Exotic', [0, 2, 3, 6, 7, 8, 11]);

  static const List<Scale> all = [
    major,
    naturalMinor,
    harmonicMinor,
    melodicMinor,
    majorPentatonic,
    minorPentatonic,
    blues,
    dorian,
    phrygian,
    lydian,
    mixolydian,
    locrian,
    wholeTone,
    diminishedWH,
    diminishedHW,
    hungarianMinor,
  ];

  static Map<String, List<Scale>> get byCategory {
    final map = <String, List<Scale>>{};
    for (final scale in all) {
      map.putIfAbsent(scale.category, () => []).add(scale);
    }
    return map;
  }
}
