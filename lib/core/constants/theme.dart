import 'package:absensi_polinela/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      // Warna utama aplikasi
      primaryColor: kPrimaryColor,
      scaffoldBackgroundColor: kBackgroundColor,
      // Mengatur font utama aplikasi menjadi Poppins
      fontFamily: GoogleFonts.poppins().fontFamily,

      // Theme untuk AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      // Theme untuk Text Input (TextField)
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kPrimaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kSecondaryColor, width: 2),
        ),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(),
    );
  }
}