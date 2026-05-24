import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized typography styles for the app.
class AppTypography {
  AppTypography._();

  static TextTheme textThemeFromBase(TextTheme base) {
    // Start with robotoMono as the general-purpose UI font
    final robotoMonoTheme = GoogleFonts.robotoMonoTextTheme(base);

    return robotoMonoTheme.copyWith(
      // Hero / large headings
      displayLarge: GoogleFonts.spaceGrotesk(textStyle: base.displayLarge, fontSize: 42, fontWeight: FontWeight.w700, height: 1.0, letterSpacing: -1.5),
      // Match screen title
      headlineLarge: GoogleFonts.spaceGrotesk(textStyle: base.headlineLarge, fontSize: 38, fontWeight: FontWeight.w700, height: 1.0),
      // Secondary large titles
      titleLarge: GoogleFonts.spaceGrotesk(textStyle: base.titleLarge, fontSize: 32, fontWeight: FontWeight.w600),
      headlineSmall: GoogleFonts.robotoMono(textStyle: base.headlineSmall, fontSize: 24, fontWeight: FontWeight.w600),

      // Buttons / labels
      labelLarge: GoogleFonts.robotoMono(textStyle: base.labelLarge, fontSize: 16, fontWeight: FontWeight.w600),

      // Body text
      bodyLarge: GoogleFonts.robotoMono(textStyle: base.bodyLarge, fontSize: 16, fontWeight: FontWeight.w400),
      bodyMedium: GoogleFonts.robotoMono(textStyle: base.bodyMedium, fontSize: 16, fontWeight: FontWeight.w400),
      bodySmall: GoogleFonts.robotoMono(textStyle: base.bodySmall, fontSize: 14, fontWeight: FontWeight.w400),

      // Metadata / timestamps
      labelSmall: GoogleFonts.robotoMono(textStyle: base.labelSmall, fontSize: 12, fontWeight: FontWeight.w500),
    );
  }
}
