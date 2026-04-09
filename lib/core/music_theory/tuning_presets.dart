import 'note.dart';
import 'tuning.dart';

class TuningPresets {
  static const standard = Tuning(
    'Standard',
    [Note.e, Note.a, Note.d, Note.g, Note.b, Note.e],
    [2, 2, 3, 3, 3, 4],
  );

  static const dropD = Tuning(
    'Drop D',
    [Note.d, Note.a, Note.d, Note.g, Note.b, Note.e],
    [2, 2, 3, 3, 3, 4],
  );

  static const dropC = Tuning(
    'Drop C',
    [Note.c, Note.g, Note.c, Note.f, Note.a, Note.d],
    [2, 2, 3, 3, 3, 4],
  );

  static const cStandard = Tuning(
    'C Standard',
    [Note.c, Note.f, Note.as_, Note.ds, Note.g, Note.c],
    [2, 2, 2, 3, 3, 4],
  );

  static const openG = Tuning(
    'Open G',
    [Note.d, Note.g, Note.d, Note.g, Note.b, Note.d],
    [2, 2, 3, 3, 3, 4],
  );

  static const openD = Tuning(
    'Open D',
    [Note.d, Note.a, Note.d, Note.fs, Note.a, Note.d],
    [2, 2, 3, 3, 3, 4],
  );

  static const dadgad = Tuning(
    'DADGAD',
    [Note.d, Note.a, Note.d, Note.g, Note.a, Note.d],
    [2, 2, 3, 3, 3, 4],
  );

  static const halfStepDown = Tuning(
    'Half Step Down',
    [Note.ds, Note.gs, Note.cs, Note.fs, Note.as_, Note.ds],
    [2, 2, 3, 3, 3, 4],
  );

  static const List<Tuning> all = [
    standard,
    dropD,
    dropC,
    cStandard,
    openG,
    openD,
    dadgad,
    halfStepDown,
  ];
}
