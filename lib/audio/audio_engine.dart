import 'package:flutter_pcm_sound/flutter_pcm_sound.dart';
import 'tone_generator.dart';

class AudioEngine {
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await FlutterPcmSound.setup(
      sampleRate: ToneGenerator.sampleRate,
      channelCount: 1,
    );
    // Set a reasonable buffer size to reduce latency
    FlutterPcmSound.setFeedThreshold(8000);
    _initialized = true;
  }

  Future<void> playFrequency(double frequency) async {
    if (!_initialized) await init();

    final samples = ToneGenerator.generate(frequency: frequency);
    final frame = PcmArrayInt16.fromList(samples.toList());
    await FlutterPcmSound.feed(frame);
  }

  void dispose() {
    if (_initialized) {
      FlutterPcmSound.release();
      _initialized = false;
    }
  }
}
