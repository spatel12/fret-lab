import 'dart:math' as math;
import 'note.dart';

class Tuning {
  final String name;
  /// Open string notes, index 0 = lowest (thickest) string (6th string)
  final List<Note> openStrings;
  /// Base octave for each string (for frequency calculation)
  final List<int> baseOctaves;

  const Tuning(this.name, this.openStrings, this.baseOctaves);

  Note noteAt(int string, int fret) {
    return openStrings[string].transpose(fret);
  }

  /// MIDI note number for a given string and fret
  int midiNote(int string, int fret) {
    final octave = baseOctaves[string];
    final semitone = openStrings[string].semitone + fret;
    return (octave + 1) * 12 + semitone;
  }

  /// Frequency in Hz for a given string and fret (A4 = 440Hz)
  double frequency(int string, int fret) {
    final midi = midiNote(string, fret);
    return 440.0 * math.pow(2, (midi - 69) / 12.0);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tuning && runtimeType == other.runtimeType && name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => name;
}
