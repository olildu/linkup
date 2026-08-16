# Design System Guide

> **Who is this for?** Any engineer touching the `presentation/` layer.
> Read this before writing a single widget. It takes 10 minutes and will save you hours of review feedback.

---

## The Big Idea — What Even Is a Design System?

Imagine you're painting a house. You could go to the shop every time you need paint and pick whatever colour looks good that day. Sometimes you'd come back with slightly different shades of white, slightly different blues. Over time the house looks patchy and inconsistent.

A design system is like agreeing on an exact set of paint colours, brush sizes, and rules before you start. Everyone uses the same tins. The house looks intentional.

Before this migration, Linkup's UI code was full of paint chosen at random:

```dart
// 🚩 The old way — random paint every time
color: const Color(0xFF00B3B3)   // who is this? no idea
color: Colors.white
Gap(20.h)
BorderRadius.circular(12)
style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)
```

After the migration, every colour, size, and text style comes from a named token. When the designer changes the brand teal, you change it in one place and every screen updates.

---

## Where Everything Lives

```
lib/presentation/
├── constants/
│   └── colors.dart          ← AppColors + AppTextStyles
└── theme/
    ├── app_theme.dart        ← AppTheme.lightTheme / AppTheme.darkTheme
    ├── app_typography.dart   ← Font sizes, weights, fonts → TextTheme slots
    ├── app_spacing.dart      ← AppSpacing — the spacing scale
    ├── app_radius.dart       ← AppRadius — border radius tokens
    ├── app_shadows.dart      ← AppShadows — box shadow tokens
    └── theme_extensions.dart ← context.colors, context.textTheme shortcuts
```

That is **the only place** design values should ever be written. Everywhere else in `presentation/` just reads from these files.

---

## Chapter 1 — Colors

### How Colors Work: Two Layers

**Layer 1 — Raw hex values** (`_Palette`, private to `colors.dart`)

Nobody outside `colors.dart` should touch these. They are just named paint tins.

```dart
abstract final class _Palette {
  static const teal400  = Color(0xFF00B3B3);  // our brand teal
  static const red600   = Color(0xFFF41505);  // error red
  static const white    = Color(0xFFFFFFFF);
  // ...
}
```

**Layer 2 — Semantic tokens** (`AppColors`)

These are what you actually use. They answer "what is this colour *for*?", not "what hex is this?"

```dart
abstract final class AppColors {
  static const primary    = _Palette.teal400;  // brand colour
  static const error      = _Palette.red600;   // error states
  static const whiteText  = _Palette.white;    // text on dark/primary backgrounds
  static const scrim      = _Palette.black;    // full-screen dark overlays
  // ...
}
```

**Layer 3 — ColorScheme** (light/dark adaptive, from `AppTheme`)

For anything that needs to *change* between light and dark mode, use the Flutter `ColorScheme`. It is wired up in `AppTheme` and automatically switches when the user toggles dark mode.

```dart
// Light:  Color(0xFFFAFAFA)  → pale grey
// Dark:   Color(0xFF111111)  → near black
// You don't need to know which — the theme handles it
Theme.of(context).colorScheme.surface
```

### The Full ColorScheme Map

| Token | Light | Dark | Use for |
|---|---|---|---|
| `primary` | Teal | Teal | Brand buttons, icons, active states |
| `onPrimary` | White | White | Text/icons on top of primary |
| `surface` | `#FAFAFA` | `#111111` | Page / card backgrounds |
| `onSurface` | `#111111` | `#F5F5F5` | Body text, icons |
| `surfaceContainerLow` | `#F5F5F5` | `#1F1D1D` | Slightly raised surfaces (cards, sheets) |
| `surfaceContainerHighest` | `#D7D7D7` | `#2A2A2A` | Received chat bubbles, strong contrast surfaces |
| `error` | Red | Red | Error states |
| `onError` | White | White | Text on error backgrounds |
| `outline` | `#E6E6E6` | `#171717` | Input borders, dividers |

### The Color Rules

```dart
// ❌ NEVER — hardcoded hex
color: const Color(0xFF00B3B3)
color: Color.fromARGB(255, 33, 37, 42)

// ❌ NEVER — raw Flutter colors
color: Colors.white
color: Colors.black
color: Colors.red

// ❌ NEVER — brightness conditionals
color: Theme.of(context).brightness == Brightness.dark ? X : Y

// ✅ For brand / overlay colors that don't change between modes
color: AppColors.primary
color: AppColors.whiteText      // only for text ON dark/primary backgrounds
color: AppColors.scrim          // only for full-screen overlays
color: Theme.of(context).colorScheme.error  // ← also fine, same value

// ✅ For anything that adapts to light/dark
color: Theme.of(context).colorScheme.surface
color: Theme.of(context).colorScheme.onSurface
color: Theme.of(context).colorScheme.surfaceContainerHighest
```

> **Rule of thumb:** If you find yourself asking "what colour is this in light/dark mode?", use `colorScheme`. If it's always the same colour (brand teal, white text on teal, full-screen black scrim), use `AppColors`.

---

## Chapter 2 — Typography

### The Font Stack

| Font | Used for |
|---|---|
| **SpaceGrotesk** | Display text, headlines — the hero fonts |
| **RobotoMono** | Body text, labels, captions — the reading fonts |

You never set a font directly in a widget. The `AppTypography` class registers everything into Flutter's `TextTheme`, and you just pick the right slot.

### The Text Style Slots

| Slot | Font | Size | Weight | Use for |
|---|---|---|---|---|
| `displayLarge` | SpaceGrotesk | 42sp | w700 | App name logo ("linkup") |
| `displayMedium` | SpaceGrotesk | 30sp | w700 | Large hero numbers / titles |
| `displaySmall` | SpaceGrotesk | 26sp | w700 | Section hero text |
| `headlineLarge` | SpaceGrotesk | 24sp | w700 | Page-level headings |
| `headlineMedium` | SpaceGrotesk | 20sp | w600 | AppBar titles, card headings |
| `titleLarge` | SpaceGrotesk | 32sp | w600 | Large section titles |
| `bodyMedium` | RobotoMono | 18sp | w500 | Primary body text, chat usernames |
| `bodyLarge` | RobotoMono | 16sp | w400 | Secondary body, list items |
| `bodySmall` | RobotoMono | 14sp | w400 | Subtitles, timestamps, captions |
| `labelLarge` | RobotoMono | 16sp | w600 | Button labels, tab labels |
| `labelMedium` | RobotoMono | 12sp | w500 | Badges, chips |
| `labelSmall` | RobotoMono | 9sp | w400 | Tiny metadata, "Seen" indicator |

### The Typography Rules

```dart
// ❌ NEVER — inline TextStyle
style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)

// ❌ NEVER — overriding size or weight in copyWith
style: Theme.of(context).textTheme.titleLarge?.copyWith(
  fontSize: 20.sp,         // ← NO
  fontWeight: FontWeight.w600,  // ← NO
)

// ✅ Just pick the right slot
style: Theme.of(context).textTheme.headlineMedium

// ✅ copyWith is ONLY allowed for these properties:
style: Theme.of(context).textTheme.bodySmall?.copyWith(
  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
  letterSpacing: 1.2,
  fontStyle: FontStyle.italic,
  height: 1.5,
  decoration: TextDecoration.underline,
)
```

> **How to pick a slot:** Match the semantic meaning, not the pixel size. An AppBar title → `headlineMedium`. A badge counter → `labelMedium`. Body copy → `bodyLarge` or `bodySmall`. If nothing feels right, it usually means we need a new slot in `AppTypography` — ask before inventing an inline size.

### The `AppTextStyles` Helpers

For common patterns that combine a slot + colour, `AppTextStyles` provides shortcuts:

```dart
AppTextStyles.subtitle(context)   // bodySmall + muted onSurface colour
AppTextStyles.label(context)      // labelLarge + onSurface
AppTextStyles.error(context)      // bodyMedium + error colour
AppTextStyles.link(context)       // bodyMedium + primary colour
AppTextStyles.destructive(context) // bodyMedium + error colour (for buttons)
```

---

## Chapter 3 — Spacing

We have a fixed scale. There are **10 sizes**. That is it. If you need a gap, pick the closest one.

```dart
abstract final class AppSpacing {
  static const double xxs = 2;   // hairline separators
  static const double xs  = 4;   // tight icon/text gaps
  static const double sm  = 8;   // default gap between related items
  static const double md  = 12;  // card internal padding
  static const double lg  = 16;  // default screen horizontal padding
  static const double xl  = 20;  // section gaps, standard screen padding
  static const double xl2 = 24;  // larger section gaps
  static const double xl3 = 32;  // major section breaks
  static const double xl4 = 48;  // hero spacing
  static const double xl5 = 64;  // screen-level breathing room
}
```

### Using the Scale

```dart
// ❌ NEVER — raw numbers
Gap(20.h)
SizedBox(height: 8)
EdgeInsets.all(16)
EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h)

// ✅ Always use the token
Gap(AppSpacing.xl.h)
SizedBox(height: AppSpacing.sm)
EdgeInsets.all(AppSpacing.lg)
EdgeInsets.symmetric(horizontal: AppSpacing.xl2.w, vertical: AppSpacing.lg.h)

// ✅ Standard screen edges
padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl.w)
// or use the screen helper:
padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenH)
```

> **The `.h` and `.w` extensions** come from `flutter_screenutil` and make the value responsive to screen size. Use them on padding and gaps. The raw constant (e.g. `AppSpacing.md`) is fine when you just need a `double` — like `EdgeInsets.all(AppSpacing.md)` which screenutil handles automatically.

---

## Chapter 4 — Border Radius

```dart
abstract final class AppRadius {
  static const double sm   = 12.0;   // text inputs, small chips
  static const double md   = 18.0;   // cards, buttons, bottom sheets
  static const double lg   = 24.0;   // large overlays, modals
  static const double xl   = 32.0;   // very rounded containers
  static const double full = 999.0;  // pill / circle shapes
}
```

```dart
// ❌ NEVER
BorderRadius.circular(12)
BorderRadius.circular(20.r)

// ✅ Always
BorderRadius.circular(AppRadius.sm)
BorderRadius.circular(AppRadius.md)
BorderRadius.circular(AppRadius.full)  // for circles/pills
```

---

## Chapter 5 — Shadows

```dart
abstract final class AppShadows {
  static const List<BoxShadow> card     = [...];  // subtle card lift
  static const List<BoxShadow> elevated = [...];  // stronger elevation
}
```

```dart
// ❌ NEVER — inline BoxShadow
decoration: BoxDecoration(
  boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 8, ...)],
)

// ✅ Use the token
decoration: BoxDecoration(boxShadow: AppShadows.card)
```

---

## Chapter 6 — The Theme Is Your Friend

`AppTheme` registers all of the above into Flutter's `ThemeData`. This means many things work **for free** without you writing a single style:

| Widget | What the theme handles for you |
|---|---|
| `ElevatedButton` | Background teal, white text, `AppRadius.md` corners, full-width, 52px tall |
| `Card` | Background `surfaceContainerLow`, `AppRadius.md` corners, no elevation |
| `TextField` / `TextFormField` | Border `AppRadius.sm`, `AppSpacing.lg` padding, hint colour |
| `AppBar` | Transparent background, `onSurface` text, no elevation |
| Any `Text` | Font, size, weight from `textTheme` |

```dart
// This button looks exactly right — no extra styling needed
ElevatedButton(
  onPressed: _submit,
  child: Text('Continue'),  // labelLarge from theme
)

// ✅ Disabled state — set onPressed to null, NOT a separate colour
ElevatedButton(
  onPressed: isValid ? _submit : null,  // theme handles the greyed-out look
  child: Text('Continue'),
)
```

---

## Chapter 7 — Components

### The Component Contract

A component should **never** accept raw design values as parameters if the theme already covers them.

```dart
// ❌ OLD ButtonBuilder — leaked design details into callers
ButtonBuilder(
  text: 'Save',
  backgroundColor: AppColors.primary,   // ← the theme already knows this
  textColor: Colors.white,
  borderRadius: 12.0,
  height: 52.0,
  isFullWidth: true,
)

// ✅ NEW ButtonBuilder — callers express intent, not appearance
ButtonBuilder(text: 'Save', onPressed: _save)
ButtonBuilder(text: 'Delete Account', onPressed: _delete, isDestructive: true)
ButtonBuilder(text: 'Sending...', onPressed: _submit, isLoading: true)
ButtonBuilder(text: 'Continue', onPressed: null)  // null = disabled, theme handles it
```

### Rules for Writing a Component

1. **No `Color` parameters** unless the colour genuinely varies per-callsite (e.g. a user-generated avatar colour). If it's always the same, it belongs in the theme.
2. **No `TextStyle` parameters** — pick the right `textTheme` slot inside the component.
3. **No raw `double` padding/radius parameters** — use `AppSpacing.*` and `AppRadius.*` internally.
4. **Use semantic flags** instead of colour params: `isDestructive: true` not `backgroundColor: Colors.red`.

---

## Chapter 8 — Quick Reference (Cheat Sheet)

### "What colour should I use for X?"

| Situation | Use |
|---|---|
| Brand button / active tab / icon | `AppColors.primary` |
| Text or icon on top of primary/teal | `AppColors.whiteText` |
| Page background | `colorScheme.surface` |
| Text on the page | `colorScheme.onSurface` |
| Slightly raised card/sheet | `colorScheme.surfaceContainerLow` |
| Received chat bubble | `colorScheme.surfaceContainerHighest` |
| Error message / border | `colorScheme.error` |
| Full-screen dark scrim | `AppColors.scrim` |
| Icons on a dark scrim | `AppColors.onScrim` |
| Placeholder / hint text | `AppColors.hint` |
| Deselected tab / inactive | `AppColors.notSelected` |
| Badge / notification dot | `AppColors.primary` background, `colorScheme.onPrimary` text |

### "What text style should I use for X?"

| Situation | Use |
|---|---|
| App name / biggest display text | `textTheme.displayLarge` |
| Hero section headline | `textTheme.displayMedium` or `displaySmall` |
| Page title / card heading | `textTheme.headlineLarge` or `headlineMedium` |
| AppBar title | `textTheme.headlineMedium` |
| Section label inside a page | `textTheme.headlineMedium` |
| Body paragraph | `textTheme.bodyLarge` |
| Important body text (chat name) | `textTheme.bodyMedium` |
| Subtitle / secondary info | `textTheme.bodySmall` or `AppTextStyles.subtitle(context)` |
| Button label | `textTheme.labelLarge` (set automatically by theme) |
| Chip / badge text | `textTheme.labelMedium` |
| Tiny metadata ("Seen", timestamps) | `textTheme.labelSmall` |

### "What spacing/radius should I use?"

```
Tiny gaps between icon and text:   AppSpacing.xs  (4)
Default gap between related items: AppSpacing.sm  (8)
Card internal padding:             AppSpacing.md  (12)
Screen horizontal padding:         AppSpacing.xl  (20)
Large section gap:                 AppSpacing.xl3 (32)

Text input corners:                AppRadius.sm   (12)
Cards / buttons / sheets:          AppRadius.md   (18)
Large modals:                      AppRadius.lg   (24)
Pills / circles:                   AppRadius.full (999)
```

---

## Chapter 9 — Before & After (Real Examples)

### Colors

```dart
// ❌ Before
color: const Color(0xFF00B3B3)
color: Colors.white
if (Theme.of(context).brightness == Brightness.dark) {
  bgColor = Color(0xFF2A2A2A);
} else {
  bgColor = Color(0xFFD7D7D7);
}

// ✅ After
color: AppColors.primary
color: AppColors.whiteText
color: Theme.of(context).colorScheme.surfaceContainerHighest
```

### Text Styles

```dart
// ❌ Before
style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)
style: Theme.of(context).textTheme.titleLarge?.copyWith(
  fontSize: 20.sp,
  fontWeight: FontWeight.w600,
  color: Theme.of(context).colorScheme.onSurface,
)

// ✅ After
style: Theme.of(context).textTheme.headlineMedium
style: Theme.of(context).textTheme.headlineMedium?.copyWith(
  color: Theme.of(context).colorScheme.onSurface,  // color is OK
)
```

### Spacing

```dart
// ❌ Before
Gap(20.h)
SizedBox(height: 8)
EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h)
BorderRadius.circular(12)

// ✅ After
Gap(AppSpacing.xl.h)
SizedBox(height: AppSpacing.sm)
EdgeInsets.symmetric(horizontal: AppSpacing.xl2.w, vertical: AppSpacing.lg.h)
BorderRadius.circular(AppRadius.sm)
```

### Buttons

```dart
// ❌ Before
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    minimumSize: Size(double.infinity, 52),
  ),
  onPressed: isEnabled ? _submit : null,
  child: Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
)

// ✅ After — theme handles everything
ButtonBuilder(text: 'Continue', onPressed: isEnabled ? _submit : null)
// or directly:
ElevatedButton(onPressed: _submit, child: Text('Continue'))
```

---

## Chapter 10 — How the Migration Happened

Here's what was done across the codebase so you understand the history.

### Phase 1 — Token Files

We created the token system from scratch:

- **`colors.dart`** — Added `_Palette` (private raw hex), `AppColors` (semantic tokens), cleaned up `AppTextStyles`.
- **`app_typography.dart`** — Mapped every size/weight combination used across the app into named `TextTheme` slots.
- **`app_spacing.dart`** — Created the 10-step spacing scale.
- **`app_radius.dart`** — Added `full = 999` radius.
- **`app_shadows.dart`** — Extracted repeated `BoxShadow` definitions into `card` and `elevated` tokens.
- **`app_theme.dart`** — Wired `ColorScheme`, `textTheme`, `elevatedButtonTheme`, `cardTheme`, and `inputDecorationTheme` so widgets get correct defaults automatically.
- **`theme_extensions.dart`** — Added `context.colors` and `context.textTheme` as shortcuts.

### Phase 2 — Bug Fix

Caught a rendering bug: `Color(0xFAFAFAFA)` in `signup_page.dart` had an alpha of `0xFA` (98%), not `0xFF`. It was barely visible. Fixed to `colorScheme.surface`.

### Phase 3 — Components

Migrated all shared components before touching screens, so every screen could use the clean version immediately:

- `ButtonBuilder` — removed all colour/size parameters, wired `ElevatedButton` to the theme, added `isDestructive` semantic flag.
- `TextInputField` — removed manual `contentPadding`, let `inputDecorationTheme` handle it.
- `ConfirmationDialogBuilder` — replaced hardcoded `Colors.white`/`Colors.black` with `colorScheme.onError`/`colorScheme.onSurface` defaults.
- `CandidateDetailBuilder` — replaced brightness conditionals with `colorScheme` tokens.
- `MenuTileBuilder`, `MessageInputArea` — replaced raw `EdgeInsets` with `AppSpacing.*`.

### Phase 4 — Screens

Every screen was migrated one by one:

`landing_page` → `login_signup_modal_page` → `connections_page` → `full_screen_image_page` → `around_you_page` → `user_profile_bottom_sheet` → `meet_at_8_page` → `match_making_page` → `set_preferences_page` → `forgot_password_modal_page` → `matched_page` → `chat_page` → `settings_page` → `profile_settings_page`

### Phase 5 — Cleanup

- Deleted deprecated `AppColors` aliases (`lightBackground`, `darkBackground`, `whiteTextColor`, etc.) after confirming no callers remained.
- Fixed `AppTextStyles.subtitle` to use `colorScheme.onSurface` instead of a brightness conditional.
- Fixed remaining `fontSize`/`fontWeight` overrides across all screens and components.
- Fixed `Color.fromARGB(255, 33, 37, 42)` (hardcoded dark chat bubble colour) → `colorScheme.surfaceContainerHighest` in both `chat_page` and `message_renderer`.
- Updated `colors_test.dart` to reflect the new `AppColors` API.
- Added convention documentation to `analysis_options.yaml`.

---

## Common Mistakes to Avoid

### 1. The "I'll just hardcode it this once" trap

```dart
// You think: "it's just one screen, it's fine"
color: const Color(0xFF1A1A2E)

// What actually happens: six months later nobody knows what this colour is,
// it doesn't respond to dark mode, and it's impossible to change globally.
```

### 2. The `.copyWith(fontSize:)` trap

```dart
// You think: "I need 22sp, there's no token for that"
style: textTheme.titleLarge?.copyWith(fontSize: 22.sp)

// What you should do: pick the closest slot (headlineMedium = 20sp, headlineLarge = 24sp)
// or add a new slot to AppTypography if it's a recurring size.
```

### 3. The "brightness check" trap

```dart
// You think: "I need different colours in light/dark"
color: Theme.of(context).brightness == Brightness.dark
    ? Color(0xFF2A2A2A)
    : Color(0xFFD7D7D7)

// What you should do: this is exactly what ColorScheme is for
color: Theme.of(context).colorScheme.surfaceContainerHighest
// The theme already switches between the right values automatically.
```

### 4. The "disabled button colour" trap

```dart
// You think: "I need to show the button is disabled"
backgroundColor: isEnabled ? AppColors.primary : AppColors.notSelected

// What you should do: Flutter handles disabled state automatically
onPressed: isEnabled ? _submit : null  // null = disabled, theme greys it out
```

---

## Adding Something New

### New colour needed?

1. Add the hex to `_Palette` in `colors.dart`.
2. Add a semantic name to `AppColors` — think about *what it's for*, not what it looks like.
3. If it adapts between light/dark, add it to both `_lightColorScheme` and `_darkColorScheme` in `app_theme.dart` instead.

### New text size needed?

1. Check if an existing slot is close enough. "Close enough" usually means within 2sp.
2. If not, add a new slot in `AppTypography.textThemeFromBase()` with the right font, size, and weight.
3. Use it via `textTheme.yourNewSlot` — never inline.

### New spacing value needed?

The scale has 10 steps. If your value doesn't fit, pick the closest one. If you find yourself picking "closest" five times for the same specific value, it might belong in the scale — raise it.

### New component needed?

- Define its visual defaults inside the component using theme/token references.
- Only expose parameters for things that *logically vary* between uses (text content, callbacks, semantic flags like `isDestructive`).
- Never expose `Color`, raw `TextStyle`, or padding `double` parameters.

---

## TL;DR — The Three Laws

**Law 1 — Never write a hex.** All colour values live in `_Palette`. All colour names live in `AppColors` or `colorScheme`.

**Law 2 — Never write a size.** All sizes come from `textTheme.*`, `AppSpacing.*`, or `AppRadius.*`. The only place numbers appear is in those files.

**Law 3 — Never write a style.** Widgets get their look from the theme. Components derive their look from the theme. You just pick the right slot and use it.

When in doubt: look at how a nearby widget does it, and copy the pattern.
