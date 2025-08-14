import 'package:flutter/material.dart';
import 'dart:math';

class ClockPainter extends CustomPainter {
  final double progressRatio; // 當前進度比例（0.0 ~ 1.0）
  final int workDuration;
  final int breakDuration;
  final bool isRunning;
  final double pausedNeedleAngle;
  final double pausedProgressRatio; // 暫停時的指針角度

  ClockPainter({
    required this.progressRatio,
    required this.workDuration,
    required this.breakDuration,
    required this.isRunning,
    required this.pausedNeedleAngle,
    this.pausedProgressRatio = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = min(size.width, size.height) / 2 * 0.9;
    final int totalDuration = workDuration + breakDuration;

    final double displayProgress = isRunning ? progressRatio : pausedProgressRatio;
    final double elapsedTime = totalDuration * progressRatio;
    final bool isInBreak = elapsedTime >= workDuration && isRunning;

    _drawOuterCircle(canvas, center, radius);
    _drawWorkBreakAreas(canvas, center, radius, workDuration, breakDuration);
    _drawTicks(canvas, center, radius, totalDuration, workDuration);
    _drawCenterDot(canvas, center, isInBreak);
    _drawNeedle(canvas, center, radius, isInBreak);
    _drawProgressRing(canvas, center, radius, isInBreak, displayProgress);
  }

  /// 畫外圈
  void _drawOuterCircle(Canvas canvas, Offset center, double radius) {
    final Paint paint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, paint);
  }

  /// 畫工作 & 休息背景
  void _drawWorkBreakAreas(Canvas canvas, Offset center, double radius, int workDuration, int breakDuration) {
    final int totalDuration = workDuration + breakDuration;
    final double workAngle = (workDuration / totalDuration) * 2 * pi;
    final double breakAngle = (breakDuration / totalDuration) * 2 * pi;

    final Paint workPaint = Paint()
      ..color = Colors.blue.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 1),
      -pi / 2,
      workAngle,
      true,
      workPaint,
    );

    final Paint breakPaint = Paint()
      ..color = Colors.red.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 1),
      -pi / 2 + workAngle,
      breakAngle,
      true,
      breakPaint,
    );
  }

  /// 畫刻度線
  void _drawTicks(Canvas canvas, Offset center, double radius, int totalDuration, int workDuration) {
    // 主要刻度（每5分鐘）
    for (int minute = 0; minute <= totalDuration; minute += 5) {
      if (minute == 0) continue;
      double angle = -pi / 2 + (minute / totalDuration) * 2 * pi;
      bool isWorkEnd = minute == workDuration;

      // 刻度線
      final Offset start = Offset(center.dx + cos(angle) * (radius - 15), center.dy + sin(angle) * (radius - 15));
      final Offset end = Offset(center.dx + cos(angle) * radius, center.dy + sin(angle) * radius);
      final Paint paint = Paint()
        ..color = isWorkEnd ? Colors.orange : Colors.white
        ..strokeWidth = isWorkEnd ? 3 : 2;
      canvas.drawLine(start, end, paint);

      // 刻度文字
      final textPainter = TextPainter(
        text: TextSpan(
          text: "$minute",
          style: TextStyle(
            color: isWorkEnd ? Colors.orange : Colors.white,
            fontSize: 16,
            fontWeight: isWorkEnd ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      final Offset textOffset = Offset(
        center.dx + cos(angle) * (radius - 30) - textPainter.width / 2,
        center.dy + sin(angle) * (radius - 30) - textPainter.height / 2,
      );
      textPainter.paint(canvas, textOffset);
    }

    // 次要刻度（每分鐘）
    for (int minute = 1; minute <= totalDuration; minute++) {
      if (minute % 5 == 0) continue;
      double angle = -pi / 2 + (minute / totalDuration) * 2 * pi;

      final Offset start = Offset(center.dx + cos(angle) * (radius - 8), center.dy + sin(angle) * (radius - 8));
      final Offset end = Offset(center.dx + cos(angle) * radius, center.dy + sin(angle) * radius);
      final Paint paint = Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..strokeWidth = 1;
      canvas.drawLine(start, end, paint);
    }
  }

  /// 畫中心小圓點
  void _drawCenterDot(Canvas canvas, Offset center, bool isInBreak) {
    final Paint paint = Paint()
      ..color = isInBreak ? Colors.red : Colors.blue
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 5, paint);
  }

  /// 畫指針
  void _drawNeedle(Canvas canvas, Offset center, double radius, bool isInBreak) {
    final Color needleColor = isInBreak ? Colors.red : Colors.blue;
    final double angle = isRunning
        ? -pi / 2 + (progressRatio * 2 * pi)
        : pausedNeedleAngle; // 暫停時保留角度

    final double length = radius * 0.85;

    final Paint paint = Paint()
      ..color = needleColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final Offset end = Offset(center.dx + cos(angle) * length, center.dy + sin(angle) * length);
    canvas.drawLine(center, end, paint);
    canvas.drawCircle(end, 6, Paint()..color = needleColor);
  }

  /// 畫外圈進度環
  void _drawProgressRing(Canvas canvas, Offset center, double radius, bool isInBreak, double displayProgress) {

    final Paint paint = Paint()
      ..color = isInBreak ? Colors.red : Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius + 5),
      -pi / 2,
      displayProgress * 2 * pi,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant ClockPainter oldDelegate) {
    return oldDelegate.progressRatio != progressRatio ||
        oldDelegate.workDuration != workDuration ||
        oldDelegate.breakDuration != breakDuration ||
        oldDelegate.isRunning != isRunning ||
        oldDelegate.pausedNeedleAngle != pausedNeedleAngle ||
        oldDelegate.pausedProgressRatio != pausedProgressRatio;
  }
}