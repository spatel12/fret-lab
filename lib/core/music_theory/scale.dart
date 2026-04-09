import 'note.dart';

class Scale {
  final String name;
  final String category;
  final List<int> intervals;

  const Scale(this.name, this.category, this.intervals);

  List<Note> notesFrom(Note root) {
    return intervals.map((i) => root.transpose(i)).toList();
  }

  int get noteCount => intervals.length;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Scale &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          category == other.category;

  @override
  int get hashCode => name.hashCode ^ category.hashCode;

  @override
  String toString() => name;
}
