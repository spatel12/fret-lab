import 'dart:math' as math;
import 'dart:typed_data';

class ToneGenerator {
  static const int sampleRate = 44100;

  /// Generate a short decaying tone at the given frequency.
  /// Returns PCM Int16 data suitable for flutter_pcm_sound.
  static Int16List generate({
    required double frequency,
    double durationSeconds = 0.5,
    double amplitude = 0.6,
  }) {
    final numSamples = (sampleRate * durationSeconds).toInt();
    final samples = Int16List(numSamples);

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;

      // Fundamental + harmonics for a guitar-like timbre
      double value = math.sin(2 * math.pi * frequency * t);
      value += 0.5 * math.sin(2 * math.pi * 2 * frequency * t); // 2nd harmonic
      value += 0.25 * math.sin(2 * math.pi * 3 * frequency * t); // 3rd harmonic
      value += 0.125 * math.sin(2 * math.pi * 4 * frequency * t); // 4th harmonic

      // Normalize the harmonic sum
      value /= 1.875; // 1 + 0.5 + 0.25 + 0.125

      // Exponential decay envelope for plucked-string sound
      final envelope = math.exp(-4.0 * t);

      samples[i] = (value * envelope * amplitude * 32767)
          .toInt()
          .clamp(-32768, 32767);
    }

    return samples;
  }
}
