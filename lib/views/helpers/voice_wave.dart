import 'package:flutter/material.dart';
import 'dart:math';
import 'package:get/get.dart';
class WavePainter extends CustomPainter {
  final Rx<Duration> currentPosition; // استخدام Rx<Duration>
  final Rx<Duration> totalDuration; // استخدام Rx<Duration>

  WavePainter(this.currentPosition, this.totalDuration);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.orangeAccent
      ..style = PaintingStyle.fill;

    // رسم شكل الموجة
    final path = Path();

    // إعدادات الموجة
    double frequency = 5; // تردد الموجة
    double amplitude = size.height / 4; // ارتفاع الموجة

    // رسم الموجة
    for (double i = 0; i < size.width; i++) {
      // استخدم دالة جيب مع مضاعف زمني لخلق تأثير حركة مثل الموجة الصوتية
      double y = size.height / 2 +
          amplitude *
              sin((i / size.width * frequency * 2 * pi) +
                  (currentPosition.value.inMilliseconds * 0.005)) * // استخدام milliseconds مع قيمة أقل لزيادة السرعة
              (1 - (currentPosition.value.inMilliseconds /
                  (totalDuration.value.inMilliseconds > 0
                      ? totalDuration.value.inMilliseconds
                      : 1)));

      if (i == 0) {
        path.moveTo(i, y);
      } else {
        path.lineTo(i, y);
      }
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
