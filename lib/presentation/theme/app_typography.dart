import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized typography styles for the app.
class AppTypography {
  AppTypography._();

  static TextTheme textThemeFromBase(TextTheme base) {
    // Start with robotoMono as the general-purpose UI font
    final robotoMonoTheme = GoogleFonts.robotoMonoTextTheme(base);

    return robotoMonoTheme.copyWith(
      // Hero / large headings (SpaceGrotesk)
      displayLarge:  GoogleFonts.spaceGrotesk(textStyle: base.displayLarge,  fontSize: 42, fontWeight: FontWeight.w700, height: 1.0, letterSpacing: -1.5),
      displayMedium: GoogleFonts.spaceGrotesk(textStyle: base.displayMedium, fontSize: 30, fontWeight: FontWeight.w700, height: 1.2),
      displaySmall:  GoogleFonts.spaceGrotesk(textStyle: base.displaySmall,  fontSize: 26, fontWeight: FontWeight.w700, height: 1.2),
      headlineLarge: GoogleFonts.spaceGrotesk(textStyle: base.headlineLarge, fontSize: 24, fontWeight: FontWeight.w700, height: 1.3),
      headlineMedium: GoogleFonts.spaceGrotesk(textStyle: base.headlineMedium, fontSize: 20, fontWeight: FontWeight.w600, height: 1.4),
      titleLarge:    GoogleFonts.spaceGrotesk(textStyle: base.titleLarge,    fontSize: 32, fontWeight: FontWeight.w600),

      // Sub-headings / labels (RobotoMono)
      headlineSmall: GoogleFonts.robotoMono(textStyle: base.headlineSmall, fontSize: 24, fontWeight: FontWeight.w600),
      labelLarge:    GoogleFonts.robotoMono(textStyle: base.labelLarge,    fontSize: 16, fontWeight: FontWeight.w600),

      // Body text (RobotoMono)
      bodyLarge:  GoogleFonts.robotoMono(textStyle: base.bodyLarge,  fontSize: 16, fontWeight: FontWeight.w400),
      bodyMedium: GoogleFonts.robotoMono(textStyle: base.bodyMedium, fontSize: 18, fontWeight: FontWeight.w500, height: 1.5),
      bodySmall:  GoogleFonts.robotoMono(textStyle: base.bodySmall,  fontSize: 14, fontWeight: FontWeight.w400),

      // Caption / metadata (RobotoMono)
      labelSmall: GoogleFonts.robotoMono(textStyle: base.labelSmall, fontSize: 9, fontWeight: FontWeight.w400, height: 1.5),
    );
  }
}
