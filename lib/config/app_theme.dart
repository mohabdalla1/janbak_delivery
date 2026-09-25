import 'package:flutter/material.dart';

class AppTheme {
  // تعريف الألوان الأساسية للتطبيق (يمكنك تعديلها حسب هوية مشروع جنبك)
  static const Color primaryColor = Color(0xFF2E7D32); // أخضر أساسي
  static const Color secondaryColor = Color(0xFFFFA000); // برتقالي ثانوي
  static const Color backgroundColor = Color(0xFFF5F5F5); // لون الخلفية
  static const Color textColor = Color(0xFF212121); // لون النصوص الرئيسي

  // الثيم الفاتح للتطبيق
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: secondaryColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textColor, fontSize: 16),
      bodyMedium: TextStyle(color: textColor, fontSize: 14),
    ),
  );
}
