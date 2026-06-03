# Design System Migration Guide

> **Context:** This guide is for migrating the `linkup` Flutter frontend from its current state — a mix of hardcoded values and partial token usage — to a fully consistent, industry-standard design system. There is no Figma file. All token values are reverse-engineered from existing code.

---

## Table of Contents

1. [Why Do This](#1-why-do-this)
2. [The Current State](#2-the-current-state)
3. [The Target State](#3-the-target-state)
4. [Step 1 — Audit: Find Every Hardcoded Value](#4-step-1--audit-find-every-hardcoded-value)
5. [Step 2 — Build the Color Token System](#5-step-2--build-the-color-token-system)
6. [Step 3 — Build the Typography System](#6-step-3--build-the-typography-system)
7. [Step 4 — Build the Spacing System](#7-step-4--build-the-spacing-system)
8. [Step 5 — Consolidate Radius & Shadows](#8-step-5--consolidate-radius--shadows)
9. [Step 6 — Wire Everything into AppTheme](#9-step-6--wire-everything-into-apptheme)
10. [Step 7 — Migrate Components One at a Time](#10-step-7--migrate-components-one-at-a-time)
11. [Going Forward — Rules to Follow](#11-going-forward--rules-to-follow)
12. [Migration Checklist](#12-migration-checklist)

---

## 1. Why Do This

A codebase with hardcoded colors and sizes has these problems:

- **Can't change the brand color** without a full-text search and manual replacement across 30+ files
- **Dark mode breaks silently** — hardcoded `Color(0xFFF5F5F5)` stays white even in dark mode
- **Inconsistency** — the "background grey" is `0xFFF5F5F5` in one file and `Color.fromARGB(255, 215, 215, 215)` in another, and they look slightly different
- **LLMs and new developers guess** — without documented tokens, every new screen uses different values
- **Bugs hide in plain sight** — `const Color(0xFAFAFAFA)` (invalid alpha, currently in `signup_page.dart`) looks right but renders wrong

The fix is not difficult. It's mechanical. This guide walks through it step by step.

---

## 2. The Current State

The app already has a partial design system. That's the good news — the foundation exists.

### What Already Exists

| File | What it does | Status |
|---|---|---|
| `lib/presentation/constants/colors.dart` | `AppColors` class + `AppTextStyles` helpers | Partial — ~40% coverage |
| `lib/presentation/theme/app_theme.dart` | `AppTheme` with light/dark `ColorScheme` | Good — uses `AppColors` correctly |
| `lib/presentation/theme/app_typography.dart` | `AppTypography` with full text scale | Good — well defined |
| `lib/presentation/theme/app_radius.dart` | `AppRadius` with sm/md/lg/xl | Good — just needs to be used |

### What's Broken

1. **Hardcoded color scattered across screen files** — see `around_you_page.dart`, `candidate_detail_builder.dart`, `chat_page.dart`
2. **No spacing scale** — values 2, 4, 5, 6, 8, 10, 12, 14, 16, 18, 20, 24, 30, 50 all appear raw without names
3. **Text styles overridden inline** — `.copyWith(fontSize: 30.sp)` everywhere defeats the purpose of `AppTypography`
4. **Brightness-conditional hardcoding** — manual light/dark pairs instead of using the theme's `ColorScheme`
5. **One invalid hex** — `signup_page.dart:104` has `Color(0xFAFAFAFA)` which has a non-opaque alpha

---

## 3. The Target State

After migration, every file in `presentation/` follows this rule:

```dart
// Every color comes from the theme
color: context.colors.surface
color: Theme.of(context).colorScheme.primary

// Every text style comes from the theme
style: Theme.of(context).textTheme.bodyMedium
style: context.textTheme.titleLarge

// Every spacing value comes from AppSpacing
padding: EdgeInsets.all(AppSpacing.md)
Gap(AppSpacing.lg)

// Every radius comes from AppRadius
borderRadius: BorderRadius.circular(AppRadius.md)
```

No raw `Color(0xFF...)`. No raw `EdgeInsets.all(16)`. No `FontWeight.w600` inline. No `fontSize: 30.sp` inline.

---

## 4. Step 1 — Audit: Find Every Hardcoded Value

Before writing a single new file, collect all the raw values that exist. Run these greps from the `lib/` directory.

### Find hardcoded colors

```bash
# All Color() constructor calls
grep -rn "Color(0x" lib/presentation/screens/ lib/presentation/components/

# All Color.fromARGB calls
grep -rn "Color.fromARGB" lib/presentation/

# All Colors.white, Colors.black, Colors.red etc
grep -rn "Colors\." lib/presentation/screens/ lib/presentation/components/
```

### Find raw font sizes

```bash
grep -rn "fontSize:" lib/presentation/screens/ lib/presentation/components/
```

### Find raw font weights

```bash
grep -rn "FontWeight\." lib/presentation/screens/ lib/presentation/components/
```

### Find raw padding values

```bash
grep -rn "EdgeInsets\." lib/presentation/screens/ lib/presentation/components/
grep -rn "SizedBox(" lib/presentation/screens/ lib/presentation/components/
```

Build a spreadsheet or a text file listing every unique value. This tells you what tokens you actually need.

### What this audit found in linkup

**Unique hardcoded colors discovered:**

| Raw value | Where | Should become |
|---|---|---|
| `Color(0xFAFAFAFA)` | `signup_page.dart:104` | `colorScheme.surface` + fix alpha bug |
| `Color(0xFFF5F5F5)` | `user_profile_bottom_sheet.dart:66` | `colorScheme.surfaceContainerLow` |
| `Colors.white` + `Color.fromARGB(255,215,215,215)` | `around_you_page.dart:63–66` | `colorScheme.surface` + `colorScheme.surfaceContainerHighest` |
| `Colors.transparent` / `AppColors.primary` | `chat_page.dart:231` | Brightness-aware token |
| `Colors.white` / `Colors.black` | `chat_page.dart:353` | `colorScheme.onPrimary` / `colorScheme.primary` |
| `Colors.black` / `Colors.white` | `full_screen_image_page.dart` | `AppColors.scrim` / `AppColors.onScrim` |
| `Color.fromARGB(255, 210, 208, 208)` / `Color.fromARGB(255, 31, 29, 29)` | `candidate_detail_builder.dart:58` | `colorScheme.surfaceContainerHighest` |
| `Color(0x1AFF0000)` | `confirmation_dialog_builder.dart:36` | `AppColors.errorContainer` |

**Unique raw font sizes found:** `9.sp`, `14.sp`, `16.sp`, `18.sp`, `20.sp`, `24.sp`, `26.sp`, `30.sp`

**Unique raw spacing values found:** `2, 4, 5, 6, 8, 10, 12, 13, 14, 16, 18, 20, 24, 30, 48, 50, 100`

---

## 5. Step 2 — Build the Color Token System

### The two-layer model

Colors exist at two levels:

```
Palette (raw hex values)     →     Semantic tokens (roles)
──────────────────────────────────────────────────────────
Color(0xFF00B3B3)            →     primary (interactive elements)
Color(0xFFF41505)            →     error (destructive states)
Color(0xFFFAFAFA)            →     surface (card backgrounds, scaffolds)
Color(0xFF000000)            →     onScrim (text on full-screen overlays)
```

Components only ever use semantic tokens. If the brand color changes, you change one palette entry and every component updates.

### Rewrite `lib/presentation/constants/colors.dart`

```dart
// lib/presentation/constants/colors.dart

import 'package:flutter/material.dart';

/// Raw palette — hex values live here and nowhere else.
/// Do not use these directly in UI code. Use [AppColors] instead.
abstract final class _Palette {
  static const teal400 = Color(0xFF00B3B3);
  static const teal50  = Color(0xFFE0F7FA);
  static const red600  = Color(0xFFF41505);
  static const red50   = Color(0x1AFF0000);   // red with 10% alpha
  static const green800 = Color(0xFF2E7D32);
  static const grey50  = Color(0xFFFAFAFA);
  static const grey100 = Color(0xFFF5F5F5);
  static const grey200 = Color(0xFFE0E0E0);
  static const grey300 = Color(0xFFBFBFBF);
  static const grey800 = Color(0xFF1F1D1D);   // from candidate_detail dark mode
  static const grey850 = Color(0xFF1A1A1A);
  static const white   = Color(0xFFFFFFFF);
  static const black   = Color(0xFF000000);
}

/// Semantic color tokens — use these in all UI code.
///
/// For colors that change between light and dark mode, use
/// [Theme.of(context).colorScheme] — those are defined in [AppTheme].
abstract final class AppColors {
  // Brand
  static const primary         = _Palette.teal400;
  static const primaryLight    = _Palette.teal50;

  // States
  static const error           = _Palette.red600;
  static const errorContainer  = _Palette.red50;
  static const success         = _Palette.green800;

  // Text
  static const hint            = _Palette.grey300;
  static const whiteText       = _Palette.white;

  // Surfaces (light mode — mirror in dark ColorScheme in AppTheme)
  static const authBackground  = _Palette.grey50;
  static const tabBarTrack     = _Palette.grey200;

  // Overlay / full-screen (always dark regardless of theme)
  static const scrim           = _Palette.black;
  static const onScrim         = _Palette.white;
}
```

### Extend Material ColorScheme in `AppTheme`

All brightness-conditional colors belong in the `ColorScheme`, not in `if (brightness == Brightness.light)` blocks scattered across the UI.

```dart
// lib/presentation/theme/app_theme.dart (updated colorScheme)

static ColorScheme get _lightColorScheme => const ColorScheme.light(
  primary:                AppColors.primary,
  onPrimary:              AppColors.whiteText,
  primaryContainer:       AppColors.primaryLight,

  error:                  AppColors.error,
  errorContainer:         AppColors.errorContainer,

  surface:                Color(0xFFFAFAFA),   // was: Color(0xFAFAFAFA) — note: fixed alpha bug
  onSurface:              Color(0xFF111111),
  surfaceContainerLow:    Color(0xFFF5F5F5),   // was: hardcoded in user_profile_bottom_sheet
  surfaceContainerHighest: Color(0xFFD7D7D7),  // was: Color.fromARGB(255,215,215,215)
);

static ColorScheme get _darkColorScheme => const ColorScheme.dark(
  primary:                AppColors.primary,
  onPrimary:              AppColors.whiteText,

  error:                  AppColors.error,
  errorContainer:         AppColors.errorContainer,

  surface:                Color(0xFF111111),
  onSurface:              Color(0xFFF5F5F5),
  surfaceContainerLow:    Color(0xFF1F1D1D),   // was: Color.fromARGB(255,31,29,29)
  surfaceContainerHighest: Color(0xFF2A2A2A),
);
```

### How to replace hardcoded colors

**Before** (`user_profile_bottom_sheet.dart:66`):
```dart
final backgroundColor = Theme.of(context).brightness == Brightness.light
    ? const Color(0xFFF5F5F5)
    : const Color.fromARGB(255, 0, 0, 0);
```

**After:**
```dart
final backgroundColor = Theme.of(context).colorScheme.surfaceContainerLow;
```

**Before** (`around_you_page.dart:62–66`):
```dart
colors: [
  if (Theme.of(context).brightness == Brightness.light) ...[
    Colors.white,
    const Color.fromARGB(255, 215, 215, 215),
  ] else ...[
    Colors.black,
    const Color.fromARGB(255, 0, 0, 0),
  ],
]
```

**After:**
```dart
colors: [
  Theme.of(context).colorScheme.surface,
  Theme.of(context).colorScheme.surfaceContainerHighest,
]
```

**Before** (`confirmation_dialog_builder.dart:36`):
```dart
iconBackgroundColor = const Color(0x1AFF0000);
```

**After:**
```dart
iconBackgroundColor = Theme.of(context).colorScheme.errorContainer;
```

**Bug fix** (`signup_page.dart:104`):
```dart
// Before — invalid alpha (0xFA = 98% opacity, not 100%)
backgroundColor: const Color(0xFAFAFAFA)

// After — correct
backgroundColor: Theme.of(context).colorScheme.surface
```

### BuildContext shortcut (optional but useful)

```dart
// lib/presentation/theme/theme_extensions.dart

extension ThemeX on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
}
```

Usage becomes even cleaner:
```dart
color: context.colors.primary
style: context.textTheme.bodyMedium
```

---

## 6. Step 3 — Build the Typography System

### What exists

`AppTypography` in `app_typography.dart` is well-written. The problem is that screens bypass it with inline `.copyWith(fontSize: 30.sp, fontWeight: FontWeight.w600)`. This means:
- The defined scale is ignored
- `fontSize: 30.sp` appears in 5+ places with no shared name
- Changing the display size means finding every `.sp` call manually

### The fix: Stop using `.copyWith()` to change size or weight

`.copyWith()` is for changing **non-scale properties** (color, letterSpacing, decoration). It should never be used to change `fontSize` or `fontWeight`. Those mean you need a different style token.

### Extend `AppTypography` with the sizes you actually use

```dart
// lib/presentation/theme/app_typography.dart (additions)

// Add these to the TextTheme returned by AppTypography.textTheme:
static TextStyle get displayXL => GoogleFonts.spaceGrotesk(
  fontSize: 30,      // was: textTheme.headlineLarge?.copyWith(fontSize: 30.sp)
  fontWeight: FontWeight.w700,
  height: 1.2,
);

static TextStyle get displayLg => GoogleFonts.spaceGrotesk(
  fontSize: 26,      // was: meet_at_8_page.dart - fontSize: 26.sp
  fontWeight: FontWeight.w700,
  height: 1.2,
);

static TextStyle get headingXL => GoogleFonts.spaceGrotesk(
  fontSize: 24,      // was: candidate_detail_builder.dart - fontSize: 24.sp, FontWeight.bold
  fontWeight: FontWeight.w700,
  height: 1.3,
);

static TextStyle get titleMd => GoogleFonts.spaceGrotesk(
  fontSize: 20,      // was: connections_page titleLarge?.copyWith(fontSize: 20.sp, w600)
  fontWeight: FontWeight.w600,
  height: 1.4,
);

static TextStyle get bodyLgBold => GoogleFonts.spaceGrotesk(
  fontSize: 18,      // was: chat_page.dart - fontSize: 18.sp, w500
  fontWeight: FontWeight.w500,
  height: 1.5,
);

static TextStyle get caption => GoogleFonts.spaceGrotesk(
  fontSize: 9,       // was: landing_page.dart - fontSize: 9.sp, w400
  fontWeight: FontWeight.w400,
  height: 1.5,
);
```

Register these in the `TextTheme` or expose them directly. The simplest approach — expose as static getters and reference them in the `textTheme` via `Theme.of(context).textTheme.displayLarge` mapping:

```dart
static TextTheme get textTheme => TextTheme(
  displayLarge:  /* 42sp */ ...,
  displayMedium: displayXL,    // 30sp
  displaySmall:  displayLg,    // 26sp
  headlineLarge: headingXL,    // 24sp
  headlineMedium: titleMd,     // 20sp
  titleLarge:    /* 32sp */ ...,
  bodyLarge:     /* 16sp, w400 */ ...,
  bodyMedium:    bodyLgBold,   // 18sp, w500
  labelSmall:    caption,      // 9sp
);
```

### How to replace inline text style overrides

**Before** (`connections_page.dart:43–46`):
```dart
style: Theme.of(context).textTheme.titleLarge?.copyWith(
  fontSize: 20.sp,
  fontWeight: FontWeight.w600,
  color: Theme.of(context).colorScheme.onSurface,
)
```

**After:**
```dart
style: Theme.of(context).textTheme.headlineMedium?.copyWith(
  color: Theme.of(context).colorScheme.onSurface,
)
// fontSize and fontWeight are already correct in headlineMedium.
// Only color changes here — that's the correct use of copyWith.
```

**Before** (`around_you_page.dart:106`):
```dart
style: Theme.of(context).textTheme.headlineLarge?.copyWith(
  fontSize: 30.sp,
  color: AppColors.whiteTextColor,
)
```

**After:**
```dart
style: Theme.of(context).textTheme.displayMedium?.copyWith(
  color: AppColors.whiteText,
)
```

### The rule for `.copyWith()`

```
copyWith() is ONLY for:          copyWith() is NEVER for:
─────────────────────────────    ─────────────────────────────────────
color                            fontSize   ← use a different style token
letterSpacing                    fontWeight ← use a different style token
decoration                       fontFamily ← set globally in AppTypography
shadows
height (line height only)
```

---

## 7. Step 4 — Build the Spacing System

The app currently has no spacing scale. Values 2, 4, 5, 6, 8, 10, 12, 14, 16, 20, 24, 30, 50, 100 all appear raw. This section defines the scale from the values that already exist in the codebase.

### Create `lib/presentation/theme/app_spacing.dart`

```dart
// lib/presentation/theme/app_spacing.dart

import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Spacing token scale.
///
/// Values are in logical pixels (matching the most common values
/// found in the codebase). All values use flutter_screenutil .h/.w
/// via the convenience methods below.
abstract final class AppSpacing {
  static const double xxs = 2;   // icon/label micro gap
  static const double xs  = 4;   // tight gap
  static const double sm  = 8;   // small gap (chat message spacing)
  static const double md  = 12;  // default element gap
  static const double lg  = 16;  // standard padding (cards, inputs)
  static const double xl  = 20;  // generous padding (screens)
  static const double xl2 = 24;  // section padding
  static const double xl3 = 32;  // large section gap
  static const double xl4 = 48;  // hero spacing
  static const double xl5 = 64;  // extra large sections

  // Responsive horizontal padding (scaled by screenutil)
  static double get screenH => 20.w;
  static double get screenV => 20.h;
}
```

### How to replace raw spacing values

**Before** (`chat_page.dart:244`):
```dart
margin: EdgeInsets.only(
  top: groupInfo.isFirstInGroup ? 8.h : 2.h,
  bottom: 1.5.h,
)
```

**After:**
```dart
margin: EdgeInsets.only(
  top: groupInfo.isFirstInGroup ? AppSpacing.sm.h : AppSpacing.xxs.h,
  bottom: AppSpacing.xxs.h,
)
```

**Before** (`connections_page.dart:63`):
```dart
padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h)
```

**After:**
```dart
padding: EdgeInsets.symmetric(
  horizontal: AppSpacing.xl.w,
  vertical: AppSpacing.xl.h,
)
```

**Before** (`candidate_detail_builder.dart:53`):
```dart
padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h)
```

**After — note: 10 is not in the scale, round to nearest:**
```dart
padding: EdgeInsets.symmetric(
  horizontal: AppSpacing.md.w,  // 12 (nearest standard), or use sm=8 if tighter
  vertical: AppSpacing.md.h,
)
```

> **When a raw value doesn't map to the scale:** Round to the nearest token. If it appears 3+ times and can't be rounded (like `13.w` for chat avatar), add a named constant for it in the specific component rather than adding a non-standard value to `AppSpacing`.

### Replace `Gap()` calls with the scale

```dart
// Before
Gap(30.h)
Gap(100.h)

// After
Gap(AppSpacing.xl3.h)   // 32 ≈ 30
Gap(AppSpacing.xl5.h)   // 64 ≈ 100, or add AppSpacing.xl6 = 100 if used frequently
```

---

## 8. Step 5 — Consolidate Radius & Shadows

### Radius

`AppRadius` already exists. The only task is to ensure it's being used everywhere.

```dart
// lib/presentation/theme/app_radius.dart (existing — no changes needed)
abstract final class AppRadius {
  static const double sm = 12.0;
  static const double md = 18.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double full = 999.0;  // add this for pill/circle shapes
}
```

Search for and replace raw `BorderRadius.circular(N)` calls:

```bash
grep -rn "BorderRadius.circular" lib/presentation/screens/ lib/presentation/components/
```

Typical replacements:
```dart
BorderRadius.circular(8)   → BorderRadius.circular(AppRadius.sm)
BorderRadius.circular(12)  → BorderRadius.circular(AppRadius.sm)
BorderRadius.circular(16)  → BorderRadius.circular(AppRadius.md)
BorderRadius.circular(20)  → BorderRadius.circular(AppRadius.md)
BorderRadius.circular(24)  → BorderRadius.circular(AppRadius.lg)
BorderRadius.circular(999) → BorderRadius.circular(AppRadius.full)
```

### Shadows

If box shadows appear in more than 2 places, extract them:

```dart
// lib/presentation/theme/app_shadows.dart

import 'package:flutter/material.dart';

abstract final class AppShadows {
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x14000000),  // black 8% opacity
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> elevated = [
    BoxShadow(
      color: Color(0x1F000000),  // black 12% opacity
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];
}
```

---

## 9. Step 6 — Wire Everything into AppTheme

All token files should feed into `AppTheme`. Nothing in the app should import `AppTypography` or `AppColors` directly to build a `ThemeData` — that's `AppTheme`'s job.

```dart
// lib/presentation/theme/app_theme.dart (final structure)

class AppTheme {
  static ThemeData light() => ThemeData(
    useMaterial3: true,
    colorScheme: _lightColorScheme,
    textTheme: AppTypography.textTheme,
    cardTheme: CardTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      elevation: 0,
      color: _lightColorScheme.surfaceContainerLow,
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      hintStyle: TextStyle(color: AppColors.hint),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.whiteText,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      ),
    ),
  );

  static ThemeData dark() => light().copyWith(
    colorScheme: _darkColorScheme,
    cardTheme: CardTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      color: _darkColorScheme.surfaceContainerLow,
    ),
  );

  static ColorScheme get _lightColorScheme => /* ... (from step 2) */;
  static ColorScheme get _darkColorScheme => /* ... (from step 2) */;
}
```

### In `main.dart`

```dart
MaterialApp(
  theme: AppTheme.light(),
  darkTheme: AppTheme.dark(),
  themeMode: ThemeMode.system,
  // ...
)
```

Once `AppTheme` provides `inputDecorationTheme` and `elevatedButtonTheme`, components like `TextInputField` and `ButtonBuilder` should stop accepting color/style parameters and let the theme drive everything.

---

## 10. Step 7 — Migrate Components One at a Time

Don't try to migrate everything at once. Do one component per PR. This is the order that gives you the most visible improvement fastest.

### Migration priority

| Component | Why first |
|---|---|
| `button_builder.dart` | Used on nearly every screen; fixing it fixes colors everywhere |
| `text_input_field.dart` | Same — auth flow, settings |
| `confirmation_dialog_builder.dart` | Has the hardcoded `Color(0x1AFF0000)` bug |
| `candidate_detail_builder.dart` | Worst hardcoded offender |
| `chat_page.dart` | Most complex, most hardcoded colors |
| Screen files (one by one) | After components are clean |

### How to migrate a single component

Use `button_builder.dart` as the example.

**Before:**
```dart
// presentation/components/signup_page/button_builder.dart

class ButtonBuilder extends StatelessWidget {
  const ButtonBuilder({
    required this.text,
    required this.onPressed,
    this.backgroundColor,          // raw Color passed in
    this.textColor,                // raw Color passed in
    this.borderRadius,             // raw double
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.isEnabled = true,
    this.isLoading = false,
  });

  final Color? backgroundColor;
  final Color? textColor;
  final double? borderRadius;
  // ...

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.primary,
        foregroundColor: textColor ?? Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 24),
        ),
        padding: padding,
      ),
      // ...
    );
  }
}
```

**After:**
```dart
// presentation/components/signup_page/button_builder.dart

class ButtonBuilder extends StatelessWidget {
  const ButtonBuilder({
    required this.text,
    required this.onPressed,
    this.isEnabled = true,
    this.isLoading = false,
    // Remove: backgroundColor, textColor, borderRadius, padding
    // These are now driven by the theme (ElevatedButtonThemeData in AppTheme)
  });

  // No color or style props — theme handles it

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      // No styleFrom() call — uses AppTheme.elevatedButtonTheme
      onPressed: isEnabled && !isLoading ? onPressed : null,
      child: isLoading
          ? const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(text),
    );
  }
}
```

**The improvement:** Callers can no longer accidentally pass `backgroundColor: Colors.green` and break the design. The button always looks right.

### Component migration checklist (per component)

- [ ] Remove `Color`, `TextStyle`, `EdgeInsets`, `double` parameters that duplicate what the theme provides
- [ ] Replace `Color(0xFF...)` with `Theme.of(context).colorScheme.*` or `AppColors.*`
- [ ] Replace `TextStyle(fontSize: N, fontWeight: X)` with `Theme.of(context).textTheme.*`
- [ ] Replace raw `EdgeInsets.all(16)` with `EdgeInsets.all(AppSpacing.lg)`
- [ ] Replace raw `BorderRadius.circular(12)` with `BorderRadius.circular(AppRadius.sm)`
- [ ] Test in both light and dark mode

---

## 11. Going Forward — Rules to Follow

These rules prevent the problem from coming back.

### Color rules

```dart
// NEVER in a UI file:
color: const Color(0xFF00B3B3)
color: Colors.white
color: Color.fromARGB(255, 210, 208, 208)

// ALWAYS use:
color: Theme.of(context).colorScheme.primary
color: Theme.of(context).colorScheme.surface
color: AppColors.whiteText  // only for non-theme colors (overlays)
```

### Text style rules

```dart
// NEVER:
style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)
style: someThemeStyle.copyWith(fontSize: 20.sp, fontWeight: FontWeight.w600)

// ALWAYS:
style: Theme.of(context).textTheme.headlineMedium
style: Theme.of(context).textTheme.bodyLarge?.copyWith(
  color: Theme.of(context).colorScheme.onSurface,  // only non-scale properties
)
```

### Spacing rules

```dart
// NEVER:
EdgeInsets.all(16)
Gap(20.h)
SizedBox(height: 8)

// ALWAYS:
EdgeInsets.all(AppSpacing.lg)
Gap(AppSpacing.xl.h)
SizedBox(height: AppSpacing.sm)
```

### Brightness conditional rules

```dart
// NEVER:
if (Theme.of(context).brightness == Brightness.light) {
  color = Colors.white;
} else {
  color = Colors.black;
}

// ALWAYS:
color = Theme.of(context).colorScheme.surface;
// Define both light and dark values in AppTheme._lightColorScheme / _darkColorScheme
```

### Component API rules

Components should not accept raw `Color` or `double` parameters that duplicate theme values:

```dart
// NEVER expose in a component's constructor:
final Color? backgroundColor;  // theme handles this
final double? borderRadius;    // AppRadius handles this
final TextStyle? textStyle;    // AppTypography handles this

// OK to expose:
final Color? iconColor;        // only if icon color is legitimately per-instance
final bool isDestructive;      // semantic flag, not a color
```

---

## 12. Migration Checklist

Work through this file by file. Check off as you go.

### Token files

- [ ] `AppColors` — palette abstracted into `_Palette`, all semantic names documented
- [ ] `AppTheme._lightColorScheme` — all brightness-conditional colors defined here
- [ ] `AppTheme._darkColorScheme` — all dark mode variants defined
- [ ] `AppTypography` — every font size used in the app has a named style
- [ ] `AppSpacing` — full scale from `xxs` to `xl5`
- [ ] `AppRadius` — add `full = 999` constant
- [ ] `AppShadows` — extract any repeated box shadows
- [ ] `AppTheme` — `inputDecorationTheme`, `elevatedButtonTheme`, `cardTheme` defined

### Bug fixes (do these first)

- [ ] `signup_page.dart:104` — fix `Color(0xFAFAFAFA)` → `colorScheme.surface`

### Component migration

- [ ] `button_builder.dart` — remove color/style props, use theme
- [ ] `text_input_field.dart` — use `inputDecorationTheme` from AppTheme
- [ ] `confirmation_dialog_builder.dart` — replace `Color(0x1AFF0000)` with `colorScheme.errorContainer`
- [ ] `candidate_detail_builder.dart` — replace all 4 hardcoded color instances
- [ ] `menu_tile_builder.dart` — fix raw padding

### Screen migration (after components)

- [ ] `user_profile_bottom_sheet.dart` — replace brightness conditional
- [ ] `around_you_page.dart` — replace gradient hardcoding + text size
- [ ] `chat_page.dart` — replace 4+ hardcoded color instances
- [ ] `full_screen_image_page.dart` — replace `Colors.black`/`Colors.white` with scrim tokens
- [ ] `matched_page.dart` — decide: are the confetti colors `AppColors` tokens or left as-is?
- [ ] `login_signup_modal_page.dart` — replace inline `ColorScheme.light()`
- [ ] `landing_page.dart` — replace inline `ColorScheme.light()`
- [ ] `meet_at_8_page.dart` — replace `fontSize: 26.sp` + `Colors.white`
- [ ] `match_making_page.dart` — replace `fontSize: 30.sp`
- [ ] `connections_page.dart` — replace `titleLarge.copyWith(fontSize: 20.sp)`
- [ ] `forgot_password_modal_page.dart` — replace `fontSize: 14.sp, FontWeight.w600`

---

*No Figma required — all token values are reverse-engineered from the existing codebase. The goal is not to change how the app looks, only to make it maintainable.*
