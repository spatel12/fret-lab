import 'interval.dart';
import 'note.dart';
import 'scale.dart';
import 'tuning.dart';

class FretboardNote {
  final int string;
  final int fret;
  final Note note;
  final bool isRoot;
  final int overlayIndex;
  final int scaleDegreeIndex;
  final String degreeName;
  final String intervalName;

  const FretboardNote({
    required this.string,
    required this.fret,
    required this.note,
    required this.isRoot,
    required this.overlayIndex,
    required this.scaleDegreeIndex,
    required this.degreeName,
    required this.intervalName,
  });
}

class FretboardCalculator {
  static List<FretboardNote> computeOverlay({
    required Tuning tuning,
    required Note rootNote,
    required Scale scale,
    required int overlayIndex,
    int fretCount = 24,
  }) {
    final scaleNotes = scale.notesFrom(rootNote);
    final result = <FretboardNote>[];

    for (int string = 0; string < 6; string++) {
      for (int fret = 0; fret <= fretCount; fret++) {
        final note = tuning.noteAt(string, fret);
        final noteIndex = scaleNotes.indexOf(note);
        if (noteIndex != -1) {
          final semitoneInterval = scale.intervals[noteIndex];
          result.add(FretboardNote(
            string: string,
            fret: fret,
            note: note,
            isRoot: note == rootNote,
            overlayIndex: overlayIndex,
            scaleDegreeIndex: noteIndex,
            degreeName: Interval.degree(semitoneInterval),
            intervalName: Interval.name(semitoneInterval),
          ));
        }
      }
    }

    return result;
  }
}
