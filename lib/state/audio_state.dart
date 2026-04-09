import 'package:flutter/foundation.dart';
import '../audio/audio_engine.dart';
import '../core/music_theory/tuning.dart';

class AudioState extends ChangeNotifier {
  final AudioEngine _engine = AudioEngine();

  Future<void> init() => _engine.init();

  void playNote(Tuning tuning, int string, int fret) {
    final freq = tuning.frequency(string, fret);
    _engine.playFrequency(freq);
  }

  @override
  void dispose() {
    _engine.dispose();
    super.dispose();
  }
}
