import 'package:flutter_test/flutter_test.dart';
import 'package:fretlab/core/music_theory/fretboard_calculator.dart';
import 'package:fretlab/core/music_theory/note.dart';
import 'package:fretlab/core/music_theory/scale_library.dart';
import 'package:fretlab/core/music_theory/tuning_presets.dart';

void main() {
  group('FretboardCalculator', () {
    test('C Major in standard tuning - open strings', () {
      final notes = FretboardCalculator.computeOverlay(
        tuning: TuningPresets.standard,
        rootNote: Note.c,
        scale: ScaleLibrary.major,
        overlayIndex: 0,
      );

      // Open string notes in standard tuning: E, A, D, G, B, E
      // C Major notes: C, D, E, F, G, A, B
      // All open strings are in C Major
      final openNotes = notes.where((n) => n.fret == 0).toList();
      expect(openNotes.length, 6); // all open strings are in C Major

      // Check specific open string notes
      final string0Fret0 = openNotes.firstWhere((n) => n.string == 0);
      expect(string0Fret0.note, Note.e); // low E
      expect(string0Fret0.isRoot, false);

      final string5Fret0 = openNotes.firstWhere((n) => n.string == 5);
      expect(string5Fret0.note, Note.e); // high E
    });

    test('C Major root notes are marked', () {
      final notes = FretboardCalculator.computeOverlay(
        tuning: TuningPresets.standard,
        rootNote: Note.c,
        scale: ScaleLibrary.major,
        overlayIndex: 0,
      );

      final rootNotes = notes.where((n) => n.isRoot).toList();
      // Every root note should be C
      for (final root in rootNotes) {
        expect(root.note, Note.c);
      }
      // There should be root notes on every string
      final stringsWithRoot = rootNotes.map((n) => n.string).toSet();
      expect(stringsWithRoot.length, 6);
    });

    test('interval names are correct for C Major', () {
      final notes = FretboardCalculator.computeOverlay(
        tuning: TuningPresets.standard,
        rootNote: Note.c,
        scale: ScaleLibrary.major,
        overlayIndex: 0,
      );

      // Find a C note (root)
      final cNote = notes.firstWhere((n) => n.note == Note.c);
      expect(cNote.intervalName, 'Root');
      expect(cNote.degreeName, '1');

      // Find a G note (P5)
      final gNote = notes.firstWhere((n) => n.note == Note.g);
      expect(gNote.intervalName, 'P5');
      expect(gNote.degreeName, '5');

      // Find an E note (M3)
      final eNote = notes.firstWhere((n) => n.note == Note.e);
      expect(eNote.intervalName, 'M3');
      expect(eNote.degreeName, '3');
    });

    test('notes span all 25 fret positions (0-24)', () {
      final notes = FretboardCalculator.computeOverlay(
        tuning: TuningPresets.standard,
        rootNote: Note.c,
        scale: ScaleLibrary.major,
        overlayIndex: 0,
        fretCount: 24,
      );

      // C Major has 7 notes per octave; across 6 strings and 25 frets,
      // roughly 7/12 of all positions should be active
      expect(notes.length, greaterThan(80));

      // Check fret range
      final frets = notes.map((n) => n.fret).toSet();
      expect(frets.contains(0), true);
      expect(frets.contains(24), true);
    });

    test('Drop D tuning changes string 0', () {
      final standardNotes = FretboardCalculator.computeOverlay(
        tuning: TuningPresets.standard,
        rootNote: Note.c,
        scale: ScaleLibrary.major,
        overlayIndex: 0,
      );
      final dropDNotes = FretboardCalculator.computeOverlay(
        tuning: TuningPresets.dropD,
        rootNote: Note.c,
        scale: ScaleLibrary.major,
        overlayIndex: 0,
      );

      // String 0 fret 0: standard = E, Drop D = D
      final stdOpen = standardNotes.firstWhere((n) => n.string == 0 && n.fret == 0);
      final dropDOpen = dropDNotes.firstWhere((n) => n.string == 0 && n.fret == 0);
      expect(stdOpen.note, Note.e);
      expect(dropDOpen.note, Note.d);
    });

    test('Minor Pentatonic has 5 notes per octave', () {
      final notes = FretboardCalculator.computeOverlay(
        tuning: TuningPresets.standard,
        rootNote: Note.a,
        scale: ScaleLibrary.minorPentatonic,
        overlayIndex: 0,
      );

      // 5 notes per octave, roughly 5/12 of positions
      // Fewer notes than C Major
      final majorNotes = FretboardCalculator.computeOverlay(
        tuning: TuningPresets.standard,
        rootNote: Note.c,
        scale: ScaleLibrary.major,
        overlayIndex: 0,
      );

      expect(notes.length, lessThan(majorNotes.length));
    });

    test('overlay index is preserved', () {
      final overlay0 = FretboardCalculator.computeOverlay(
        tuning: TuningPresets.standard,
        rootNote: Note.c,
        scale: ScaleLibrary.major,
        overlayIndex: 0,
      );
      final overlay1 = FretboardCalculator.computeOverlay(
        tuning: TuningPresets.standard,
        rootNote: Note.a,
        scale: ScaleLibrary.minorPentatonic,
        overlayIndex: 1,
      );

      for (final n in overlay0) {
        expect(n.overlayIndex, 0);
      }
      for (final n in overlay1) {
        expect(n.overlayIndex, 1);
      }
    });
  });

  group('Tuning frequency', () {
    test('A4 = 440Hz (string 5 fret 5 in standard, approximately)', () {
      // In standard tuning, string 5 (high E) is E4
      // Fret 5 on string 5 = A4 = 440Hz
      final freq = TuningPresets.standard.frequency(5, 5);
      expect(freq, closeTo(440.0, 0.1));
    });

    test('open low E = E2', () {
      // E2 should be around 82.41 Hz
      final freq = TuningPresets.standard.frequency(0, 0);
      expect(freq, closeTo(82.41, 0.5));
    });

    test('fret 12 is one octave up (double frequency)', () {
      final openFreq = TuningPresets.standard.frequency(0, 0);
      final fret12Freq = TuningPresets.standard.frequency(0, 12);
      expect(fret12Freq, closeTo(openFreq * 2, 0.5));
    });
  });
}
