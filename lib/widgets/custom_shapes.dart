import 'dart:math' as math;
import 'package:flutter/material.dart';

class ScallopedClipper extends CustomClipper<Path> {
  ScallopedClipper({
    this.scallopCount = 6,
    this.scallopDepth = 3,
    this.capPortion =
        0.09, // 0..1 fraction of each scallop allocated to the rounded cap
    this.controlBias = 0.5, // 0..1 bias of side control angles toward the cap
  }) : assert(scallopCount >= 2);

  final int scallopCount;
  final double scallopDepth;

  /// Fraction of each scallop’s angle taken by the rounded tip (outer arc).
  /// Typical range: 0.15–0.45. Higher = broader, rounder tip.
  final double capPortion;

  /// Where to place the side bezier control angles between start/end and the cap edge.
  /// 0 = at start/end (pointier sides), 1 = at cap edge (flatter sides).
  final double controlBias;

  @override
  Path getClip(Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final maxR = math.min(size.width, size.height) / 2;

    // Keep the scallops within the canvas.
    final innerR = (maxR - scallopDepth).clamp(0.0, double.infinity);

    final path = Path();
    final step = 2 * math.pi / scallopCount;
    final outerR = innerR + scallopDepth;

    // Clamp to safe ranges.
    final safeCap = capPortion.clamp(0.0, 0.9);
    final bias = controlBias.clamp(0.0, 1.0);
    final capSweep = step * safeCap;
    final capHalf = capSweep / 2;

    Offset outerPoint(double a) =>
        Offset(c.dx + outerR * math.cos(a), c.dy + outerR * math.sin(a));
    Offset innerPoint(double a) =>
        Offset(c.dx + innerR * math.cos(a), c.dy + innerR * math.sin(a));

    double lerpAngle(double a, double b, double t) => a + (b - a) * t;

    for (int i = 0; i < scallopCount; i++) {
      final aStart = i * step;
      final aEnd = (i + 1) * step;
      final aMid = (aStart + aEnd) / 2;

      // Points on the outer circle.
      final pStart = outerPoint(aStart);
      final pEnd = outerPoint(aEnd);

      // Edges of the rounded cap around the tip.
      final aCapL = aMid - capHalf;
      final aCapR = aMid + capHalf;
      final pCapL = outerPoint(aCapL);

      // Bezier controls on the inner circle, biased toward the cap edges.
      final aCtrlL = lerpAngle(aStart, aCapL, bias);
      final aCtrlR = lerpAngle(aEnd, aCapR, bias);
      final ctrlL = innerPoint(aCtrlL);
      final ctrlR = innerPoint(aCtrlR);

      if (i == 0) {
        path.moveTo(pStart.dx, pStart.dy);
      }

      // Left side: organic inward pull toward the inner circle.
      path.quadraticBezierTo(ctrlL.dx, ctrlL.dy, pCapL.dx, pCapL.dy);

      // Rounded tip: short outer arc centered at the badge center.
      path.arcTo(
        Rect.fromCircle(center: c, radius: outerR),
        aCapL,
        capSweep,
        false,
      );

      // Right side: organic return toward the next outer point.
      path.quadraticBezierTo(ctrlR.dx, ctrlR.dy, pEnd.dx, pEnd.dy);
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant ScallopedClipper old) =>
      scallopCount != old.scallopCount ||
      scallopDepth != old.scallopDepth ||
      capPortion != old.capPortion ||
      controlBias != old.controlBias;
}

/* @override
void paint(Canvas canvas, Size size) {
  final center = Offset(size.width / 2, size.height / 2);
  final maxR = math.min(size.width, size.height) / 2;

  // Keep the scallops within the canvas.
  final innerR = (maxR - scallopDepth).clamp(0.0, double.infinity);

  final badgePath = _buildScallopedPath(
    center,
    innerR,
    scallopDepth,
    scallopCount,
    capPortion: capPortion,
    controlBias: controlBias,
  );

  final fill =
      Paint()
        ..isAntiAlias = true
        ..style = PaintingStyle.fill
        ..color = color;

  canvas.drawPath(badgePath, fill);
}

Path _buildScallopedPath(
  Offset c,
  double innerR,
  double depth,
  int n, {
  required double capPortion,
  required double controlBias,
}) {
  final path = Path();
  final step = 2 * math.pi / n;
  final outerR = innerR + depth;

  // Clamp to safe ranges.
  final safeCap = capPortion.clamp(0.0, 0.9);
  final bias = controlBias.clamp(0.0, 1.0);
  final capSweep = step * safeCap;
  final capHalf = capSweep / 2;

  Offset outerPoint(double a) =>
      Offset(c.dx + outerR * math.cos(a), c.dy + outerR * math.sin(a));
  Offset innerPoint(double a) =>
      Offset(c.dx + innerR * math.cos(a), c.dy + innerR * math.sin(a));

  double lerpAngle(double a, double b, double t) => a + (b - a) * t;

  for (int i = 0; i < n; i++) {
    final aStart = i * step;
    final aEnd = (i + 1) * step;
    final aMid = (aStart + aEnd) / 2;

    // Points on the outer circle.
    final pStart = outerPoint(aStart);
    final pEnd = outerPoint(aEnd);

    // Edges of the rounded cap around the tip.
    final aCapL = aMid - capHalf;
    final aCapR = aMid + capHalf;
    final pCapL = outerPoint(aCapL);

    // Bezier controls on the inner circle, biased toward the cap edges.
    final aCtrlL = lerpAngle(aStart, aCapL, bias);
    final aCtrlR = lerpAngle(aEnd, aCapR, bias);
    final ctrlL = innerPoint(aCtrlL);
    final ctrlR = innerPoint(aCtrlR);

    if (i == 0) {
      path.moveTo(pStart.dx, pStart.dy);
    }

    // Left side: organic inward pull toward the inner circle.
    path.quadraticBezierTo(ctrlL.dx, ctrlL.dy, pCapL.dx, pCapL.dy);

    // Rounded tip: short outer arc centered at the badge center.
    path.arcTo(
      Rect.fromCircle(center: c, radius: outerR),
      aCapL,
      capSweep,
      false,
    );

    // Right side: organic return toward the next outer point.
    path.quadraticBezierTo(ctrlR.dx, ctrlR.dy, pEnd.dx, pEnd.dy);
  }

  path.close();
  return path;
} */

/* Path _buildScallopedPath(Offset c, double innerR, double depth, int n) {
  // Creates rounded “bumps” by using quadratic beziers:
  // each scallop goes from outer point -> INNER control point -> outer inner point.
  final path = Path();
  final step = 2 * math.pi / n;
  final r = innerR + depth;

  Offset outerPoint(double angle) =>
      Offset(c.dx + r * math.cos(angle), c.dy + r * math.sin(angle));

  Offset innerControl(double angle) {
    return Offset(
      c.dx + innerR * math.cos(angle),
      c.dy + innerR * math.sin(angle),
    );
  }

  // Start at angle 0 on the inner circle.
  var a0 = 0.0;
  path.moveTo(outerPoint(a0).dx, outerPoint(a0).dy);

  for (int i = 0; i < n; i++) {
    final aStart = i * step;
    final aEnd = (i + 1) * step;
    final aMid = (aStart + aEnd) / 2;

    final pStart = outerPoint(aStart);
    final pEnd = outerPoint(aEnd);
    final ctrl = innerControl(aMid);

    if (i == 0) {
      path.moveTo(pStart.dx, pStart.dy);
    }
    path.quadraticBezierTo(ctrl.dx, ctrl.dy, pEnd.dx, pEnd.dy);
    // path.quadraticBezierTo(pEnd.dx, pEnd.dy, x2, y2);
  }

  path.close();
  return path;
} */

class DialPainter extends CustomPainter {
  DialPainter({required this.level, required this.needleColor});

  final double level; // 0.0 to 1.0
  final Color needleColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Gradient background arc
    final arcRect = Rect.fromCircle(center: center, radius: radius);

    final arcPaint =
        Paint()
          ..color = Colors.blue.shade100
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12
          ..strokeCap = StrokeCap.round;
    canvas.drawArc(arcRect, math.pi * 0.72, 1.56 * math.pi, false, arcPaint);

    // Fill level arc (animated)
    final fillPaint =
        Paint()
          ..color = Colors.lightBlue
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12
          ..strokeCap = StrokeCap.round;
    final sweep = 1.58 * math.pi * level;
    canvas.drawArc(arcRect, math.pi * 0.72, sweep, false, fillPaint);

    // Needle
    final needleAngle = math.pi * 0.72 + sweep;
    final needleLength = radius * 0.68;
    final needleEnd = Offset(
      center.dx + needleLength * math.cos(needleAngle),
      center.dy + needleLength * math.sin(needleAngle),
    );
    final needlePaint =
        Paint()
          ..color = needleColor
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, needleEnd, needlePaint);

    // final needlePath =
    //     Path()
    //       ..moveTo(center.dx, center.dy)
    //       ..lineTo(
    //         center.dx + 10 * math.cos(needleAngle - math.pi / 2),
    //         center.dy + 10 * math.sin(needleAngle - math.pi / 2),
    //       )
    //       ..lineTo(needleEnd.dx, needleEnd.dy)
    //       ..lineTo(
    //         center.dx + 10 * math.cos(needleAngle + math.pi / 2),
    //         center.dy + 10 * math.sin(needleAngle + math.pi / 2),
    //       )
    //       ..close();

    // canvas.drawPath(needlePath, Paint()..color = Colors.black);

    // Center knob
    canvas.drawCircle(center, 4, Paint()..color = needleColor);

    // Labels
    //   _drawLabel(canvas, center, radius, 'Low', math.pi * 0.85);
    //   _drawLabel(canvas, center, radius, 'High', math.pi * 0.15);
    // }

    // void _drawLabel(
    //   Canvas canvas,
    //   Offset center,
    //   double radius,
    //   String text,
    //   double angle,
    // ) {
    //   final offset = Offset(
    //     center.dx + radius * 0.6 * math.cos(angle),
    //     center.dy + radius * 0.6 * math.sin(angle),
    //   );
    //   final tp = TextPainter(
    //     text: TextSpan(
    //       text: text,
    //       style: const TextStyle(fontSize: 14, color: Colors.black),
    //     ),
    //     textDirection: TextDirection.ltr,
    //   )..layout();
    //   tp.paint(canvas, offset - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant DialPainter oldDelegate) =>
      level != oldDelegate.level;
}
