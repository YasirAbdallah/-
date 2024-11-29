import 'package:flutter/material.dart';

class FontAdjuster {
  // Method to get adjusted font size
  static double getAdjustedFontSize(BuildContext context) {
    // الحصول على عرض الشاشة
    double screenWidth = MediaQuery.of(context).size.width;

    // حساب حجم النص الافتراضي كنسبة مئوية من عرض الشاشة
    double baseFontSize = screenWidth * 0.05; // 5% من عرض الشاشة

    // الحصول على TextScaler
    TextScaler textScaler = MediaQuery.textScalerOf(context);

    // Adjusted size based on baseFontSize
    double textScaleFactor = textScaler.scale(baseFontSize);

    // تحديد حجم النص بناءً على قيمة التكبير
    double fontSize;

    if (textScaleFactor >= 3.0) {
      fontSize = baseFontSize * 0.8; // حجم نص صغير إذا كانت النسبة كبيرة جداً
    } else if (textScaleFactor >= 2.0) {
      fontSize = baseFontSize * 0.9; // حجم نص متوسط إذا كانت النسبة متوسطة
    } else if (textScaleFactor >= 1.5) {
      fontSize = baseFontSize; // حجم النص الافتراضي
    } else if (textScaleFactor >= 1.2) {
      fontSize = baseFontSize * 1.1; // تكبير النص قليلاً
    } else if (textScaleFactor >= 1.0) {
      fontSize = baseFontSize * 1.2; // تكبير النص قليلاً إذا كانت النسبة 1
    } else {
      fontSize = baseFontSize * 1.3; // تكبير أكبر إذا كانت النسبة أقل من 1
    }

    return fontSize; // إرجاع حجم النص المعدل
  }
}
