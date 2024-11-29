import 'package:arabic_font/arabic_font.dart';
import 'package:flutter/material.dart';

/// اللون الأزرق المعدني
const Color metallicBlue = Color(0xFF4F4D8C);

/// ويدجت للنص الرئيسي
class CustomTitleText extends StatelessWidget {
  final String text;
  const CustomTitleText({super.key, required this.text});

  @override 
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const ArabicTextStyle(
        arabicFont: ArabicFont.changa,
        fontSize: 20,
        color: metallicBlue,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

/// ويدجت لنص الجسم
class CustomBodyText extends StatelessWidget {
  final String text;
  const CustomBodyText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
       textAlign: TextAlign.right, // ضبط محاذاة النص إلى اليمين
      textDirection: TextDirection.rtl, // تحديد اتجاه النص
      text,
      style: const ArabicTextStyle(
        arabicFont: ArabicFont.changa,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: metallicBlue,
      ),
    );
  }
}

/// ويدجت لنص الجسم
class CustomSBodyText extends StatelessWidget {
  final String text;
  const CustomSBodyText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      textAlign: TextAlign.right, // ضبط محاذاة النص إلى اليمين
      textDirection: TextDirection.rtl, // تحديد اتجاه النص
      text,
      style: const ArabicTextStyle(
        arabicFont: ArabicFont.changa,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: metallicBlue,
      ),
    );
  }
}

/// ويدجت لنص الجسم
class CustomGoldBodyText extends StatelessWidget {
  final String text;
  const CustomGoldBodyText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      textAlign: TextAlign.right, // ضبط محاذاة النص إلى اليمين
      textDirection: TextDirection.rtl, // تحديد اتجاه النص
      text,
      style: const ArabicTextStyle(
        arabicFont: ArabicFont.changa,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFFCC8400),
      ),
    );
  }
}

/// ويدجت لـ AppBar نص خاص بالشريط
class CustomAppBarText extends StatelessWidget implements PreferredSizeWidget {
  final String titleText;
  const CustomAppBarText({super.key, required this.titleText});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: metallicBlue,
      title: Text(
        titleText,
        style: const ArabicTextStyle(
          arabicFont: ArabicFont.changa,
          fontSize: 20,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// ويدجت لزر بتدرج ذهبي
class CustomGradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomGradientButton(
      {super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontSize: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ).copyWith(
        backgroundColor: WidgetStateProperty.resolveWith<Color?>(
          (states) => null,
        ),
        elevation: WidgetStateProperty.all(8),
        shadowColor: WidgetStateProperty.all(Colors.transparent),
      ),
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFA500)], // تدرج ذهبي
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          alignment: Alignment.center,
          constraints: const BoxConstraints(minWidth: 100, minHeight: 40),
          child: Text(
            text,
            style: const ArabicTextStyle(
              arabicFont: ArabicFont.changa,
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
