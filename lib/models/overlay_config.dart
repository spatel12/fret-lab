import 'package:flutter/material.dart';
import '../core/music_theory/note.dart';
import '../core/music_theory/scale.dart';

class OverlayConfig {
  final Note rootNote;
  final Scale scale;
  final Color color;
  final bool enabled;

  const OverlayConfig({
    required this.rootNote,
    required this.scale,
    required this.color,
    this.enabled = true,
  });

  OverlayConfig copyWith({
    Note? rootNote,
    Scale? scale,
    Color? color,
    bool? enabled,
  }) {
    return OverlayConfig(
      rootNote: rootNote ?? this.rootNote,
      scale: scale ?? this.scale,
      color: color ?? this.color,
      enabled: enabled ?? this.enabled,
    );
  }
}
