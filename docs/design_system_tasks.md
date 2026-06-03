# Design System Migration — Task Breakdown

> Work through phases in order. Each task is ~30–60 min. Don't skip to a later phase until the current one is done — later tasks depend on earlier ones.

---

## Phase 1 — Token Files (Foundation)

Everything else depends on these being correct first.

### 1.1 Colors

- [x] **Add `_Palette` private class to `colors.dart`**
  Move all raw `Color(0xFF...)` values from `AppColors` into a private `_Palette` class.
  `AppColors` fields then reference `_Palette.*` instead of raw hex.
  File: `lib/presentation/constants/colors.dart`

- [x] **Add missing semantic color names to `AppColors`**
  Add: `scrim`, `onScrim`, `authBackground`, `tabBarTrack`, `errorContainer`, `hint`.
  These are currently hardcoded in various screens — give them names here.
  File: `lib/presentation/constants/colors.dart`

- [x] **Add `surfaceContainerLow` to light `ColorScheme`**
  Value: `Color(0xFFF5F5F5)` — currently hardcoded in `user_profile_bottom_sheet.dart`.
  File: `lib/presentation/theme/app_theme.dart`

- [x] **Add `surfaceContainerHighest` to light + dark `ColorScheme`**
  Light: `Color(0xFFD7D7D7)` — from `around_you_page.dart`.
  Dark: `Color(0xFF2A2A2A)`.
  File: `lib/presentation/theme/app_theme.dart`

- [x] **Add `surfaceContainerLow` to dark `ColorScheme`**
  Value: `Color(0xFF1F1D1D)` — from `candidate_detail_builder.dart` dark mode.
  File: `lib/presentation/theme/app_theme.dart`

- [x] **Add `BuildContext` extension for theme shortcuts**
  Create `lib/presentation/theme/theme_extensions.dart`.
  Add `context.colors` → `colorScheme` and `context.textTheme` → `textTheme`.

---

### 1.2 Typography

- [x] **Add `displayMedium` style (30sp, w700)**
  Currently: `textTheme.headlineLarge?.copyWith(fontSize: 30.sp)` in `around_you_page.dart` and `match_making_page.dart`.
  File: `lib/presentation/theme/app_typography.dart`

- [x] **Add `displaySmall` style (26sp, w700)**
  Currently: `fontSize: 26.sp` in `meet_at_8_page.dart`.
  File: `lib/presentation/theme/app_typography.dart`

- [x] **Add `headingXL` / map to `headlineLarge` (24sp, w700)**
  Currently: `fontSize: 24.sp, FontWeight.bold` in `candidate_detail_builder.dart`.
  File: `lib/presentation/theme/app_typography.dart`

- [x] **Add `headlineMedium` style (20sp, w600)**
  Currently: `textTheme.titleLarge?.copyWith(fontSize: 20.sp, w600)` in `connections_page.dart` and `landing_page.dart`.
  File: `lib/presentation/theme/app_typography.dart`

- [x] **Add `bodyLgBold` / map to `bodyMedium` (18sp, w500)**
  Currently: `fontSize: 18.sp, fontWeight: FontWeight.w500` in `chat_page.dart`.
  File: `lib/presentation/theme/app_typography.dart`

- [x] **Add `labelSmall` caption style (9sp, w400)**
  Currently: `fontSize: 9.sp, w400` in `landing_page.dart`.
  File: `lib/presentation/theme/app_typography.dart`

- [x] **Register all new styles in `TextTheme` returned by `AppTypography`**
  Map each new style to the correct `TextTheme` slot so `Theme.of(context).textTheme.*` works.
  File: `lib/presentation/theme/app_typography.dart`

---

### 1.3 Spacing

- [x] **Create `lib/presentation/theme/app_spacing.dart`**
  Define the full scale:
  `xxs=2, xs=4, sm=8, md=12, lg=16, xl=20, xl2=24, xl3=32, xl4=48, xl5=64`

---

### 1.4 Radius & Shadows

- [x] **Add `full = 999.0` to `AppRadius`**
  File: `lib/presentation/theme/app_radius.dart`

- [x] **Create `lib/presentation/theme/app_shadows.dart`**
  Extract any repeated `BoxShadow` values found in screens/components into named constants (`card`, `elevated`).

---

### 1.5 AppTheme wiring

- [x] **Add `inputDecorationTheme` to `AppTheme`**
  Set `contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg)`.
  Set `border` with `AppRadius.sm`.
  Set `hintStyle` with `AppColors.hint`.
  File: `lib/presentation/theme/app_theme.dart`

- [x] **Add `elevatedButtonTheme` to `AppTheme`**
  Set background `AppColors.primary`, foreground `AppColors.whiteText`, radius `AppRadius.md`.
  File: `lib/presentation/theme/app_theme.dart`

- [x] **Add `cardTheme` to `AppTheme`**
  Set `borderRadius: AppRadius.md`, `elevation: 0`, `color: colorScheme.surfaceContainerLow`.
  File: `lib/presentation/theme/app_theme.dart`

---

## Phase 2 — Bug Fixes (Do These Early)

- [x] **Fix invalid hex in `signup_page.dart:104`**
  `Color(0xFAFAFAFA)` → `Theme.of(context).colorScheme.surface`
  (The `0xFA` alpha means 98% opacity — this is a rendering bug)
  File: `lib/presentation/screens/signup_page.dart`

---

## Phase 3 — Component Migration

Do one component at a time. Test light + dark after each one.

- [x] **`button_builder.dart` — remove color/style props**
  Delete `backgroundColor`, `textColor`, `borderRadius`, `padding` params.
  Remove `ElevatedButton.styleFrom(...)` call — let `AppTheme.elevatedButtonTheme` drive it.
  File: `lib/presentation/components/signup_page/button_builder.dart`

- [x] **`text_input_field.dart` — use theme-driven styles**
  Replace raw `AppTextStyles.label(context)` inline calls with `Theme.of(context).textTheme.*`.
  Replace raw `EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h)` with `AppSpacing`.
  Let `AppTheme.inputDecorationTheme` drive padding and borders.
  File: `lib/presentation/components/login/text_input_field.dart`

- [x] **`confirmation_dialog_builder.dart` — fix hardcoded error color**
  Replace `Color(0x1AFF0000)` with `Theme.of(context).colorScheme.errorContainer`.
  Replace `Colors.white`/`Colors.black` button colors with `colorScheme.onPrimary`/`colorScheme.primary`.
  File: `lib/presentation/components/common/confirmation_dialog_builder.dart`

- [x] **`candidate_detail_builder.dart` — replace all 4 hardcoded colors**
  Line 58: `Color.fromARGB(255, 210, 208, 208)` / `Color.fromARGB(255, 31, 29, 29)` → `colorScheme.surfaceContainerHighest`
  Lines 53, 56, 117: replace raw `EdgeInsets` with `AppSpacing.*`
  Lines 67, 83: replace `fontSize: 24.sp, FontWeight.bold` and `fontSize: 16.sp` with theme text styles.
  File: `lib/presentation/components/candidate_detail_scroll/candidate_detail_builder.dart`

- [x] **`menu_tile_builder.dart` — fix raw padding**
  `EdgeInsets.symmetric(horizontal: 14, vertical: 14)` → `AppSpacing.md` (or `AppSpacing.lg` if needed).
  File: `lib/presentation/components/common/menu_tile_builder.dart`

- [x] **`message_input_area.dart` — replace raw spacing**
  Lines 37, 47, 57: replace all raw `EdgeInsets` with `AppSpacing.*`.
  File: `lib/presentation/components/chat_page/message_input_area.dart`

---

## Phase 4 — Screen Migration

Do one screen at a time. Each screen is independent — order doesn't matter within this phase.

- [x] **`user_profile_bottom_sheet.dart`**
  Line 66: replace `brightness == light ? Color(0xFFF5F5F5) : Color(...)` → `colorScheme.surfaceContainerLow`

- [x] **`around_you_page.dart`**
  Lines 62–66: replace gradient brightness conditional → `[colorScheme.surface, colorScheme.surfaceContainerHighest]`
  Line 96: replace `MediaQuery.of(context).size.width * 0.05` → `AppSpacing.screenH`
  Lines 102, 108: replace `Gap(30.h)`, `Gap(100.h)` → `Gap(AppSpacing.xl3.h)` etc.
  Line 106: replace `textTheme.headlineLarge?.copyWith(fontSize: 30.sp)` → `textTheme.displayMedium`

- [x] **`chat_page.dart`**
  Line 231: replace brightness conditional → `colorScheme` value
  Lines 353–354: `Colors.white`/`Colors.black` → removed (dialog uses colorScheme defaults)
  Line 434: `textTheme.bodyLarge?.copyWith(fontSize: 14.sp)` → `textTheme.bodyLarge`
  Lines 498–499: `fontSize: 18.sp, FontWeight.w500` → `textTheme.bodyMedium`
  Lines 244, 254, 270–271: replace raw `EdgeInsets` + `SizedBox` → `AppSpacing.*`

- [x] **`full_screen_image_page.dart`**
  Lines 46, 49, 51: `Colors.black`, `Colors.transparent`, `Colors.white` → `AppColors.scrim`, `Colors.transparent`, `AppColors.onScrim`

- [x] **`connections_page.dart`**
  Line 43–46: `textTheme.titleLarge?.copyWith(fontSize: 20.sp, w600)` → `textTheme.headlineMedium?.copyWith(color: ...)`
  Line 63: raw `EdgeInsets` → `AppSpacing`
  Line 219: `BoxDecoration(color: AppColors.primary)` — already correct, leave it

- [x] **`login_signup_modal_page.dart`**
  Line 29: replace inline `ColorScheme.light(primary: ..., surface: Colors.white, onSurface: Colors.black)` → use `AppTheme.light().colorScheme`

- [x] **`landing_page.dart`**
  Line 29: same inline `ColorScheme.light` → use `AppTheme.light().colorScheme`
  Line 97: `textTheme.titleMedium?.copyWith(fontSize: 20.sp, w500)` → `textTheme.headlineMedium`
  Line 115: `textTheme.bodySmall?.copyWith(fontSize: 9.sp, w400)` → `textTheme.labelSmall`
  Line 86: raw `EdgeInsets` → `AppSpacing`

- [x] **`meet_at_8_page.dart`**
  Lines 85, 89: `fontSize: 26.sp` + `Colors.white` → `textTheme.displaySmall` + `AppColors.whiteText`
  All other overrides (22sp, 24sp, 18sp) → appropriate theme styles, `AppSpacing` throughout

- [x] **`match_making_page.dart`**
  Line 65: `textTheme.displayLarge?.copyWith(fontSize: 30.sp)` → `textTheme.displayMedium`

- [x] **`set_preferences_page.dart`**
  Line 81: raw `EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h)` → `AppSpacing.xl`
  AppBar title → `textTheme.headlineMedium`, all `Gap(20.h)` → `AppSpacing.xl`

- [x] **`forgot_password_modal_page.dart`**
  `titleMedium?.copyWith(fontSize: 20.sp, w400)` → `textTheme.headlineMedium`, all spacing → `AppSpacing.*`

- [x] **`matched_page.dart`**
  Confetti colors — intentionally random/fun (comment added). All spacing → `AppSpacing.*`, radius → `AppRadius.md`.

---

## Phase 5 — Cleanup & Enforcement

- [x] **Delete unused color constants from `AppColors`**
  Removed: `primaryLight`, `authBackground`, `authScaffoldBackground`, `link`, `lightBackground`, `lightText`, `darkBackground`, `darkText`. Removed `teal50` from `_Palette`. Fixed stale `colors_test.dart` to match current API. Fixed `AppTextStyles.subtitle` to use `colorScheme.onSurface.withValues(alpha: 0.6)` instead of `Color.fromARGB`.

- [x] **Add a lint rule against raw `Color(0x...)` in `analysis_options.yaml`**
  Added comment-based convention block documenting the three rules (no raw Color, no Colors.white/black, no fontSize/fontWeight in copyWith).

- [x] **Search for any remaining `FontWeight.` in screens/components**
  Fixed all `copyWith(fontWeight:...)` violations in: `connections_page`, `settings_page`, `profile_settings_page`, `login_signup_modal_page`, `uploading_overlay`, `title_sub_builder`, `minor_event_widgets`. Remaining `FontWeight` in `AppTextStyles` (token definitions), `confirmation_dialog_builder` (dialog button emphasis), `message_renderer` (emoji size is logic-driven) are intentional or in token-definition context.

- [x] **Search for any remaining `fontSize:` in screens/components**
  Fixed all `copyWith(fontSize:...)` violations in screens. Remaining `fontSize` in component APIs (`text_widget_builder`, `picker_builder`, `page_title_builder`) are component parameters, not inline overrides. `message_renderer` emoji 35sp case is logic-driven (content-dependent sizing), noted as exception.

- [ ] **Final dark mode walkthrough**
  Open every screen in dark mode. Check for anything that looks wrong — those are missed hardcoded values.

---

## Summary

| Phase | Tasks | Effort |
|---|---|---|
| Phase 1 — Token files | 17 tasks | ~1 day |
| Phase 2 — Bug fixes | 1 task | 30 min |
| Phase 3 — Components | 7 tasks | ~1 day |
| Phase 4 — Screens | 14 tasks | ~2 days |
| Phase 5 — Cleanup | 5 tasks | ~2 hours |
| **Total** | **44 tasks** | **~4.5 days** |

**Start with Phase 1** — the token files. Every other task unblocks once those are in place.
