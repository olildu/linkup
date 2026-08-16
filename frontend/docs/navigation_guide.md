# Navigation Guide

> How screens are opened, closed, and passed data in this app.

---

## Navigation approach

The app uses Flutter's standard imperative `Navigator` — no named routes, no go_router, no auto_route. Every navigation is an explicit `Navigator.of(context).push(...)` call.

This is intentional: the route structure is simple enough that a router package would add more boilerplate than it saves.

---

## The navigation helpers

Two helpers in `lib/presentation/utils/`:

### `navigateWithFade`

```dart
// lib/presentation/utils/navigate_fade_transistion.dart
void navigateWithFade(BuildContext context, Widget page, {bool allowBack = true}) {
  final route = PageRouteBuilder(
    pageBuilder: (_, animation, __) => page,
    transitionsBuilder: (_, animation, __, child) =>
        FadeTransition(opacity: animation, child: child),
    transitionDuration: const Duration(milliseconds: 500),
  );

  if (allowBack) {
    Navigator.of(context).push(route);
  } else {
    Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
  }
}
```

Use this for **top-level screen transitions** — landing → home, post-login routing.

- `allowBack: true` (default) — user can press back to return
- `allowBack: false` — clears the navigation stack (used after login to prevent going back to login screen)

### `CupertinoPageRoute`

For in-app screen pushes (chat, profile, settings), use `CupertinoPageRoute` directly. It gives the iOS-style slide-in animation on all platforms:

```dart
Navigator.of(context).push(
  CupertinoPageRoute(builder: (_) => ChatPage(chatRoomId: roomId, otherUser: user)),
);
```

---

## Bottom sheets

Two types of bottom sheets are used:

### `showModalBottomSheet` — system bottom sheet

Used for: forgot password, user profile viewer, settings panels.

```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  builder: (context) => ForgotPasswordModalPage(),
);
```

`isScrollControlled: true` lets the sheet take up more than 50% of the screen height. Used whenever the content might be taller than the default.

### Profile bottom sheet — with BlocProvider

The user profile sheet needs its own `OtherProfileBloc` instance (factory, so it's fresh each time). The pattern:

```dart
// lib/presentation/screens/user_profile_bottom_sheet.dart
void showBottomSheetUserProfile({
  required BuildContext context,
  required int userId,
  bool showChatButton = true,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => BlocProvider(
      create: (_) => sl<OtherProfileBloc>()..add(LoadOtherProfileEvent(userId)),
      child: BlocBuilder<OtherProfileBloc, OtherProfileState>(
        builder: (context, state) { ... },
      ),
    ),
  );
}
```

Key points:
- `sl<OtherProfileBloc>()` gets a fresh instance (registered as factory)
- `..add(LoadOtherProfileEvent(userId))` fires the load immediately after creation
- The bloc is disposed when the sheet closes

---

## Login screen modal

`LoginSignupModalPage` and `LandingPage` use `showModalBottomSheet` with `showDragHandle: true` and `useSafeArea: true` to present the login/signup flow as a sheet from the bottom.

```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  useSafeArea: true,
  builder: (context) => BlocProvider(
    create: (_) => sl<AuthBloc>(),
    child: LoginSignupModalPage(),
  ),
);
```

---

## How a screen receives data

There are no named routes with parameters, so data is passed directly via constructor:

```dart
// Navigating to chat
Navigator.of(context).push(
  CupertinoPageRoute(
    builder: (_) => ChatPage(
      chatRoomId: connection.chatRoomId,
      otherUser: connection.user,
    ),
  ),
);

// ChatPage receives it
class ChatPage extends StatefulWidget {
  final int chatRoomId;
  final ChatUser otherUser;
  const ChatPage({required this.chatRoomId, required this.otherUser, super.key});
}
```

No global route arguments map, no query strings — just typed constructor parameters.

---

## Post-login routing

After login, the app needs to figure out where to send the user (complete profile? home? locked?). This is handled by `PostLoginBloc` and `LoadingScreenPostLoginPage`.

The loading screen is shown immediately after authentication. It fires a check event, `PostLoginBloc` evaluates the state (profile complete, app lock, etc.), and emits a routing state. A `BlocListener` in the loading screen navigates to the correct destination:

```dart
BlocListener<PostLoginBloc, PostLoginState>(
  listener: (context, state) {
    if (state is PostLoginGoHome) {
      navigateWithFade(context, HomePage(), allowBack: false);
    } else if (state is PostLoginCompleteProfile) {
      navigateWithFade(context, SignupFlowPage(), allowBack: false);
    }
  },
)
```

The `allowBack: false` ensures the user can't press back to return to the login screen after successfully authenticating.

---

## Rules

- **Never navigate inside `BlocBuilder`.** Navigation is a side effect — always inside `BlocListener`.
- **Use `CupertinoPageRoute` for in-app navigation.** It gives consistent iOS-style slide animation.
- **Use `navigateWithFade` only for top-level transitions** (auth → app root).
- **Use `allowBack: false`** whenever navigation should clear the stack (after login, after onboarding completion).
- **Wrap a screen's bloc in `BlocProvider`** when pushing to it, if it's a factory bloc. Don't share a singleton bloc across screens that each need their own state.
- **Never use `Navigator.pushNamed`** — there are no named routes in this app.
