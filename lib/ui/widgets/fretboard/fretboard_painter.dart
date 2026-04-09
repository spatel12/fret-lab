import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../core/music_theory/fretboard_calculator.dart';

enum DisplayMode { noteName, scaleDegree, interval }

class FretboardLayout {
  final double width;
  final double height;
  final int fretCount;
  final double topPadding;
  final double bottomPadding;
  final double leftPadding; // space for string labels
  final double nutWidth;

  FretboardLayout({
    required this.width,
    required this.height,
    this.fretCount = 24,
    this.topPadding = 20,
    this.bottomPadding = 40,
    this.leftPadding = 40,
    this.nutWidth = 6,
  });

  double get stringAreaHeight => height - topPadding - bottomPadding;
  double get stringSpacing => stringAreaHeight / 5; // 5 gaps for 6 strings
  double get fretAreaWidth => width - leftPadding - 20; // 20 right padding
  double get fretSpacing => fretAreaWidth / fretCount;

  double stringY(int string) {
    // String 0 (low E) at bottom, string 5 (high E) at top
    return topPadding + (5 - string) * stringSpacing;
  }

  double fretX(int fret) {
    if (fret == 0) return leftPadding;
    return leftPadding + fret * fretSpacing;
  }

  /// Center x position for a note at a given fret
  double noteCenterX(int fret) {
    if (fret == 0) return leftPadding - 15; // before the nut
    return leftPadding + (fret - 0.5) * fretSpacing;
  }

  /// Hit test: convert a position to (string, fret), or null
  (int, int)? hitTest(Offset position) {
    // Find closest string
    int? closestString;
    double minStringDist = double.infinity;
    for (int s = 0; s < 6; s++) {
      final dist = (position.dy - stringY(s)).abs();
      if (dist < minStringDist && dist < stringSpacing * 0.5) {
        minStringDist = dist;
        closestString = s;
      }
    }
    if (closestString == null) return null;

    // Find fret
    if (position.dx < leftPadding) {
      return (closestString, 0); // open string
    }
    final fretPos = (position.dx - leftPadding) / fretSpacing;
    final fret = fretPos.ceil().clamp(1, fretCount);
    return (closestString, fret);
  }
}

class FretboardPainter extends CustomPainter {
  final List<FretboardNote> overlayNotes;
  final DisplayMode displayMode;
  final List<Color> overlayColors;
  final int fretCount;
  final bool isDarkMode;
  final bool showNoteLabels;
  final bool showRoots;

  FretboardPainter({
    required this.overlayNotes,
    required this.displayMode,
    required this.overlayColors,
    this.fretCount = 24,
    this.isDarkMode = true,
    this.showNoteLabels = true,
    this.showRoots = true,
  });

  static const List<int> markerFrets = [3, 5, 7, 9, 12, 15, 17, 19, 21, 24];
  static const List<int> doubleMarkerFrets = [12, 24];

  @override
  void paint(Canvas canvas, Size size) {
    final layout = FretboardLayout(
      width: size.width,
      height: size.height,
      fretCount: fretCount,
    );

    _drawBackground(canvas, size);
    _drawFretMarkers(canvas, layout);
    _drawFrets(canvas, layout);
    _drawNut(canvas, layout);
    _drawStrings(canvas, layout);
    _drawNotes(canvas, layout);
  }

  void _drawBackground(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDarkMode
          ? const Color(0xFF1E1E1E)
          : const Color(0xFFF5E6D0);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Fretboard wood area
    final boardPaint = Paint()
      ..color = isDarkMode
          ? const Color(0xFF2D2520)
          : const Color(0xFFD4A574);
    final layout = FretboardLayout(
      width: size.width,
      height: size.height,
      fretCount: fretCount,
    );
    canvas.drawRect(
      Rect.fromLTRB(
        layout.leftPadding,
        layout.topPadding - 10,
        size.width - 20,
        size.height - layout.bottomPadding + 10,
      ),
      boardPaint,
    );
  }

  void _drawFretMarkers(Canvas canvas, FretboardLayout layout) {
    final markerPaint = Paint()
      ..color = isDarkMode
          ? const Color(0xFF555555)
          : const Color(0xFFB8956A);

    for (final fret in markerFrets) {
      if (fret > fretCount) continue;
      final cx = layout.noteCenterX(fret);
      if (doubleMarkerFrets.contains(fret)) {
        // Double dot
        final y1 = layout.stringY(1) + (layout.stringY(2) - layout.stringY(1)) / 2;
        final y2 = layout.stringY(3) + (layout.stringY(4) - layout.stringY(3)) / 2;
        canvas.drawCircle(Offset(cx, y1), 5, markerPaint);
        canvas.drawCircle(Offset(cx, y2), 5, markerPaint);
      } else {
        // Single dot centered between strings 2 and 3
        final cy = (layout.stringY(2) + layout.stringY(3)) / 2;
        canvas.drawCircle(Offset(cx, cy), 5, markerPaint);
      }
    }

    // Fret numbers — show all
    final textStyle = TextStyle(
      color: isDarkMode
          ? const Color(0xFF888888)
          : const Color(0xFF666666),
      fontSize: 10,
    );
    for (int fret = 1; fret <= fretCount; fret++) {
      final tp = TextPainter(
        text: TextSpan(text: '$fret', style: textStyle),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(layout.noteCenterX(fret) - tp.width / 2,
            layout.stringY(0) + 15),
      );
    }
  }

  void _drawFrets(Canvas canvas, FretboardLayout layout) {
    final fretPaint = Paint()
      ..color = isDarkMode
          ? const Color(0xFF888888)
          : const Color(0xFFA0A0A0)
      ..strokeWidth = 2;

    for (int fret = 1; fret <= fretCount; fret++) {
      final x = layout.fretX(fret);
      canvas.drawLine(
        Offset(x, layout.stringY(5) - 5),
        Offset(x, layout.stringY(0) + 5),
        fretPaint,
      );
    }
  }

  void _drawNut(Canvas canvas, FretboardLayout layout) {
    final nutPaint = Paint()
      ..color = isDarkMode
          ? const Color(0xFFCCCCCC)
          : const Color(0xFF333333)
      ..strokeWidth = layout.nutWidth;

    canvas.drawLine(
      Offset(layout.leftPadding, layout.stringY(5) - 5),
      Offset(layout.leftPadding, layout.stringY(0) + 5),
      nutPaint,
    );
  }

  void _drawStrings(Canvas canvas, FretboardLayout layout) {
    // String thickness: thickest (string 0) to thinnest (string 5)
    const thicknesses = [3.0, 2.5, 2.0, 1.5, 1.2, 1.0];

    for (int s = 0; s < 6; s++) {
      final stringPaint = Paint()
        ..color = isDarkMode
            ? const Color(0xFFAAAAAA)
            : const Color(0xFF777777)
        ..strokeWidth = thicknesses[s];

      final y = layout.stringY(s);
      canvas.drawLine(
        Offset(layout.leftPadding - 20, y),
        Offset(layout.fretX(fretCount) + 10, y),
        stringPaint,
      );
    }

    // String labels are drawn by FretboardWidget (it knows the tuning)
  }

  void _drawNotes(Canvas canvas, FretboardLayout layout) {
    for (final note in overlayNotes) {
      final cx = layout.noteCenterX(note.fret);
      final cy = layout.stringY(note.string);
      final color = note.overlayIndex < overlayColors.length
          ? overlayColors[note.overlayIndex]
          : Colors.blue;

      final isRootStyled = note.isRoot && showRoots;
      final radius = isRootStyled ? 14.0 : 11.0;

      // Note circle
      final circlePaint = Paint()..color = color;
      canvas.drawCircle(Offset(cx, cy), radius, circlePaint);

      // Root note border
      if (isRootStyled) {
        final borderPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5;
        canvas.drawCircle(Offset(cx, cy), radius, borderPaint);
      }

      // Label text (only if showNoteLabels is true)
      if (showNoteLabels) {
        final label = switch (displayMode) {
          DisplayMode.noteName => note.note.displayName(),
          DisplayMode.scaleDegree => note.degreeName,
          DisplayMode.interval => note.intervalName,
        };

        final textStyle = TextStyle(
          color: Colors.white,
          fontSize: isRootStyled ? 10 : 9,
          fontWeight: isRootStyled ? FontWeight.bold : FontWeight.normal,
        );
        final tp = TextPainter(
          text: TextSpan(text: label, style: textStyle),
          textDirection: ui.TextDirection.ltr,
        )..layout();
        tp.paint(
          canvas,
          Offset(cx - tp.width / 2, cy - tp.height / 2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(FretboardPainter oldDelegate) {
    return overlayNotes != oldDelegate.overlayNotes ||
        displayMode != oldDelegate.displayMode ||
        overlayColors != oldDelegate.overlayColors ||
        isDarkMode != oldDelegate.isDarkMode ||
        showNoteLabels != oldDelegate.showNoteLabels ||
        showRoots != oldDelegate.showRoots;
  }
}
