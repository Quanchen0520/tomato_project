import 'package:flutter/material.dart';
import 'dart:math';

class ClockPainter extends CustomPainter {
  final double progressRatio; // 當前進度（0 ~ 1）
  final int workDuration; // 工作時間（分鐘）
  final int breakDuration; // 休息時間（分鐘）
  final bool isRunning; // 計時器是否運行中

  ClockPainter(this.progressRatio, this.workDuration, this.breakDuration, {this.isRunning = true});

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = min(size.width, size.height) / 2 * 0.9; // 使用最小尺寸計算半徑並留邊距
    final int totalDuration = workDuration + breakDuration;

    // 檢查是否在休息時間
    final double elapsedTimeInMinutes = totalDuration * progressRatio;
    final bool isInBreakTime = elapsedTimeInMinutes >= workDuration && isRunning;

    // 外圈畫筆
    final Paint circlePaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    // 畫外圈
    canvas.drawCircle(center, radius, circlePaint);

    // 分隔工作和休息區域
    final double workAngle = (workDuration / totalDuration) * 2 * pi;
    final double breakAngle = (breakDuration / totalDuration) * 2 * pi;

    // 工作區域填充
    final Paint workAreaPaint = Paint()
      ..color = Colors.blue.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 1),
      -pi/2, // 從12點鐘方向開始
      workAngle,
      true,
      workAreaPaint,
    );

    // 休息區域填充
    final Paint breakAreaPaint = Paint()
      ..color = Colors.red.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 1),
      -pi/2 + workAngle,
      breakAngle,
      true,
      breakAreaPaint,
    );

    // 畫主要刻度和分鐘數字
    for (int minute = 0; minute <= totalDuration; minute += 5) {
      if (minute == 0) continue; // 跳過0分鐘

      double tickAngle = -pi / 2 + (minute / totalDuration) * 2 * pi;
      bool isWorkTimeEnd = minute == workDuration;

      // 主要刻度線（粗線）
      final Offset majorTickStart = Offset(
        center.dx + cos(tickAngle) * (radius - 15),
        center.dy + sin(tickAngle) * (radius - 15),
      );

      final Offset majorTickEnd = Offset(
        center.dx + cos(tickAngle) * radius,
        center.dy + sin(tickAngle) * radius,
      );

      final Paint majorTickPaint = Paint()
        ..color = isWorkTimeEnd ? Colors.orange : Colors.white
        ..strokeWidth = isWorkTimeEnd ? 3 : 2
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(majorTickStart, majorTickEnd, majorTickPaint);

      // 僅為主要刻度繪製數字
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: "$minute",
          style: TextStyle(
              color: isWorkTimeEnd ? Colors.orange : Colors.white,
              fontSize: 16,
              fontWeight: isWorkTimeEnd ? FontWeight.bold : FontWeight.normal
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      final Offset textOffset = Offset(
        center.dx + cos(tickAngle) * (radius - 30) - textPainter.width / 2,
        center.dy + sin(tickAngle) * (radius - 30) - textPainter.height / 2,
      );

      textPainter.paint(canvas, textOffset);
    }

    // 畫次要刻度（不帶數字）
    for (int minute = 1; minute <= totalDuration; minute++) {
      if (minute % 5 == 0) continue; // 跳過主要刻度

      double tickAngle = -pi / 2 + (minute / totalDuration) * 2 * pi;

      final Offset minorTickStart = Offset(
        center.dx + cos(tickAngle) * (radius - 8),
        center.dy + sin(tickAngle) * (radius - 8),
      );

      final Offset minorTickEnd = Offset(
        center.dx + cos(tickAngle) * radius,
        center.dy + sin(tickAngle) * radius,
      );

      final Paint minorTickPaint = Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..strokeWidth = 1;

      canvas.drawLine(minorTickStart, minorTickEnd, minorTickPaint);
    }

    // 繪製中央小圓點
    final Paint centerDotPaint = Paint()
      ..color = isInBreakTime ? Colors.red : Colors.blue
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 5, centerDotPaint);

    // 指針
    final Color needleColor = isInBreakTime ? Colors.red : Colors.blue;
    final double needleAngle = isRunning
        ? -pi / 2 + (progressRatio * 2 * pi)
        : -pi / 2; // 非運行狀態時指向12點鐘方向

    final double needleLength = radius * 0.85;
    final Paint needlePaint = Paint()
      ..color = needleColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final Offset needleEnd = Offset(
      center.dx + cos(needleAngle) * needleLength,
      center.dy + sin(needleAngle) * needleLength,
    );

    canvas.drawLine(center, needleEnd, needlePaint);

    // 在指針尾端加上一個小圓點
    canvas.drawCircle(needleEnd, 6, centerDotPaint);

    // 在外圈周圍添加一個進度指示環
    if (isRunning) {
      final Paint progressPaint = Paint()
        ..color = needleColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius + 5),
        -pi/2,
        progressRatio * 2 * pi,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ClockPainter oldDelegate) {
    return oldDelegate.progressRatio != progressRatio ||
        oldDelegate.workDuration != workDuration ||
        oldDelegate.breakDuration != breakDuration ||
        oldDelegate.isRunning != isRunning;
  }
}