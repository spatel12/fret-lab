enum Note {
  c(0, 'C', 'C'),
  cs(1, 'C#', 'Db'),
  d(2, 'D', 'D'),
  ds(3, 'D#', 'Eb'),
  e(4, 'E', 'E'),
  f(5, 'F', 'F'),
  fs(6, 'F#', 'Gb'),
  g(7, 'G', 'G'),
  gs(8, 'G#', 'Ab'),
  a(9, 'A', 'A'),
  as_(10, 'A#', 'Bb'),
  b(11, 'B', 'B');

  final int semitone;
  final String sharpName;
  final String flatName;

  const Note(this.semitone, this.sharpName, this.flatName);

  Note transpose(int semitones) {
    return Note.values[(semitone + semitones) % 12];
  }

  String displayName({bool useFlats = false}) {
    return useFlats ? flatName : sharpName;
  }

  static Note fromSemitone(int semitone) {
    return Note.values[semitone % 12];
  }

  /// All note names for UI dropdowns
  static const List<String> sharpNames = [
    'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B',
  ];

  static const List<String> flatNames = [
    'C', 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab', 'A', 'Bb', 'B',
  ];
}
