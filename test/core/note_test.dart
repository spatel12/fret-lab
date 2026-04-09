import 'package:flutter_test/flutter_test.dart';
import 'package:fretlab/core/music_theory/note.dart';

void main() {
  group('Note', () {
    test('has correct semitone values', () {
      expect(Note.c.semitone, 0);
      expect(Note.cs.semitone, 1);
      expect(Note.d.semitone, 2);
      expect(Note.e.semitone, 4);
      expect(Note.a.semitone, 9);
      expect(Note.b.semitone, 11);
    });

    test('transpose up', () {
      expect(Note.c.transpose(2), Note.d);
      expect(Note.c.transpose(4), Note.e);
      expect(Note.c.transpose(7), Note.g);
    });

    test('transpose wraps around', () {
      expect(Note.a.transpose(3), Note.c);
      expect(Note.b.transpose(1), Note.c);
      expect(Note.g.transpose(5), Note.c);
    });

    test('transpose by 0 returns same note', () {
      for (final note in Note.values) {
        expect(note.transpose(0), note);
      }
    });

    test('transpose by 12 returns same note', () {
      for (final note in Note.values) {
        expect(note.transpose(12), note);
      }
    });

    test('display name sharp', () {
      expect(Note.c.displayName(), 'C');
      expect(Note.cs.displayName(), 'C#');
      expect(Note.fs.displayName(), 'F#');
      expect(Note.as_.displayName(), 'A#');
    });

    test('display name flat', () {
      expect(Note.cs.displayName(useFlats: true), 'Db');
      expect(Note.ds.displayName(useFlats: true), 'Eb');
      expect(Note.as_.displayName(useFlats: true), 'Bb');
    });

    test('fromSemitone', () {
      for (final note in Note.values) {
        expect(Note.fromSemitone(note.semitone), note);
      }
      expect(Note.fromSemitone(12), Note.c);
      expect(Note.fromSemitone(13), Note.cs);
    });

    test('all 12 notes are unique', () {
      final semitones = Note.values.map((n) => n.semitone).toSet();
      expect(semitones.length, 12);
    });
  });
}
