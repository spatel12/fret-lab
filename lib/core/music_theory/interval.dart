class Interval {
  static const Map<int, String> names = {
    0: 'Root',
    1: 'm2',
    2: 'M2',
    3: 'm3',
    4: 'M3',
    5: 'P4',
    6: 'TT',
    7: 'P5',
    8: 'm6',
    9: 'M6',
    10: 'm7',
    11: 'M7',
  };

  static const Map<int, String> degreeNames = {
    0: '1',
    1: 'b2',
    2: '2',
    3: 'b3',
    4: '3',
    5: '4',
    6: 'b5',
    7: '5',
    8: 'b6',
    9: '6',
    10: 'b7',
    11: '7',
  };

  static String name(int semitones) {
    return names[semitones % 12] ?? '?';
  }

  static String degree(int semitones) {
    return degreeNames[semitones % 12] ?? '?';
  }
}
