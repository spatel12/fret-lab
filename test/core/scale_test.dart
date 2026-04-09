import 'package:flutter_test/flutter_test.dart';
import 'package:fretlab/core/music_theory/note.dart';
import 'package:fretlab/core/music_theory/scale.dart';
import 'package:fretlab/core/music_theory/scale_library.dart';

void main() {
  group('Scale', () {
    test('C Major has correct notes', () {
      final notes = ScaleLibrary.major.notesFrom(Note.c);
      expect(notes, [Note.c, Note.d, Note.e, Note.f, Note.g, Note.a, Note.b]);
    });

    test('G Major has correct notes', () {
      final notes = ScaleLibrary.major.notesFrom(Note.g);
      expect(notes, [Note.g, Note.a, Note.b, Note.c, Note.d, Note.e, Note.fs]);
    });

    test('A Natural Minor has correct notes', () {
      final notes = ScaleLibrary.naturalMinor.notesFrom(Note.a);
      expect(notes, [Note.a, Note.b, Note.c, Note.d, Note.e, Note.f, Note.g]);
    });

    test('A Minor Pentatonic has correct notes', () {
      final notes = ScaleLibrary.minorPentatonic.notesFrom(Note.a);
      expect(notes, [Note.a, Note.c, Note.d, Note.e, Note.g]);
    });

    test('E Minor Pentatonic has correct notes', () {
      final notes = ScaleLibrary.minorPentatonic.notesFrom(Note.e);
      expect(notes, [Note.e, Note.g, Note.a, Note.b, Note.d]);
    });

    test('C Major Pentatonic has correct notes', () {
      final notes = ScaleLibrary.majorPentatonic.notesFrom(Note.c);
      expect(notes, [Note.c, Note.d, Note.e, Note.g, Note.a]);
    });

    test('A Blues has correct notes', () {
      final notes = ScaleLibrary.blues.notesFrom(Note.a);
      expect(notes, [Note.a, Note.c, Note.d, Note.ds, Note.e, Note.g]);
    });

    test('D Dorian has correct notes', () {
      final notes = ScaleLibrary.dorian.notesFrom(Note.d);
      expect(notes, [Note.d, Note.e, Note.f, Note.g, Note.a, Note.b, Note.c]);
    });

    test('E Phrygian has correct notes', () {
      final notes = ScaleLibrary.phrygian.notesFrom(Note.e);
      expect(notes, [Note.e, Note.f, Note.g, Note.a, Note.b, Note.c, Note.d]);
    });

    test('F Lydian has correct notes', () {
      final notes = ScaleLibrary.lydian.notesFrom(Note.f);
      expect(notes, [Note.f, Note.g, Note.a, Note.b, Note.c, Note.d, Note.e]);
    });

    test('G Mixolydian has correct notes', () {
      final notes = ScaleLibrary.mixolydian.notesFrom(Note.g);
      expect(notes, [Note.g, Note.a, Note.b, Note.c, Note.d, Note.e, Note.f]);
    });

    test('B Locrian has correct notes', () {
      final notes = ScaleLibrary.locrian.notesFrom(Note.b);
      expect(notes, [Note.b, Note.c, Note.d, Note.e, Note.f, Note.g, Note.a]);
    });

    test('C Whole Tone has correct notes', () {
      final notes = ScaleLibrary.wholeTone.notesFrom(Note.c);
      expect(notes, [Note.c, Note.d, Note.e, Note.fs, Note.gs, Note.as_]);
    });

    test('A Harmonic Minor has correct notes', () {
      final notes = ScaleLibrary.harmonicMinor.notesFrom(Note.a);
      expect(notes, [Note.a, Note.b, Note.c, Note.d, Note.e, Note.f, Note.gs]);
    });

    test('A Melodic Minor has correct notes', () {
      final notes = ScaleLibrary.melodicMinor.notesFrom(Note.a);
      expect(notes, [Note.a, Note.b, Note.c, Note.d, Note.e, Note.fs, Note.gs]);
    });

    test('all scales have at least 5 notes', () {
      for (final scale in ScaleLibrary.all) {
        expect(scale.noteCount, greaterThanOrEqualTo(5),
            reason: '${scale.name} has fewer than 5 notes');
      }
    });

    test('all scales start on 0 (root)', () {
      for (final scale in ScaleLibrary.all) {
        expect(scale.intervals.first, 0,
            reason: '${scale.name} does not start on root');
      }
    });

    test('all intervals are in ascending order', () {
      for (final scale in ScaleLibrary.all) {
        for (int i = 1; i < scale.intervals.length; i++) {
          expect(scale.intervals[i], greaterThan(scale.intervals[i - 1]),
              reason: '${scale.name} intervals not ascending at index $i');
        }
      }
    });

    test('scale library has 16 scales', () {
      expect(ScaleLibrary.all.length, 16);
    });

    test('byCategory groups correctly', () {
      final categories = ScaleLibrary.byCategory;
      expect(categories.keys, containsAll(['Major & Minor', 'Pentatonic & Blues', 'Modes', 'Exotic']));
      expect(categories['Major & Minor']!.length, 4);
      expect(categories['Pentatonic & Blues']!.length, 3);
      expect(categories['Modes']!.length, 5);
      expect(categories['Exotic']!.length, 4);
    });
  });
}
