import 'package:flutter/material.dart';
import '../../../core/music_theory/fretboard_calculator.dart';
import '../../../core/music_theory/tuning.dart';
import 'fretboard_painter.dart';

class FretboardWidget extends StatelessWidget {
  final List<FretboardNote> overlayNotes;
  final DisplayMode displayMode;
  final List<Color> overlayColors;
  final Tuning tuning;
  final int fretCount;
  final bool isDarkMode;
  final bool showNoteLabels;
  final bool showRoots;
  final void Function(int string, int fret)? onNoteTapped;

  const FretboardWidget({
    super.key,
    required this.overlayNotes,
    required this.displayMode,
    required this.overlayColors,
    required this.tuning,
    this.fretCount = 24,
    this.isDarkMode = true,
    this.showNoteLabels = true,
    this.showRoots = true,
    this.onNoteTapped,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight.clamp(200.0, 300.0);

        return SizedBox(
          height: height,
          child: Stack(
            children: [
              GestureDetector(
                onTapDown: (details) {
                  final layout = FretboardLayout(
                    width: width,
                    height: height,
                    fretCount: fretCount,
                  );
                  final hit = layout.hitTest(details.localPosition);
                  if (hit != null) {
                    onNoteTapped?.call(hit.$1, hit.$2);
                  }
                },
                child: CustomPaint(
                  size: Size(width, height),
                  painter: FretboardPainter(
                    overlayNotes: overlayNotes,
                    displayMode: displayMode,
                    overlayColors: overlayColors,
                    fretCount: fretCount,
                    isDarkMode: isDarkMode,
                    showNoteLabels: showNoteLabels,
                    showRoots: showRoots,
                  ),
                ),
              ),
              // String labels on the left
              ...List.generate(6, (string) {
                final layout = FretboardLayout(
                  width: width,
                  height: height,
                  fretCount: fretCount,
                );
                final y = layout.stringY(string);
                final noteName = tuning.openStrings[string].displayName();
                return Positioned(
                  left: 4,
                  top: y - 8,
                  child: Text(
                    noteName,
                    style: TextStyle(
                      color: isDarkMode
                          ? const Color(0xFFCCCCCC)
                          : const Color(0xFF333333),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
