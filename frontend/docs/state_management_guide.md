# State Management Guide

> How BLoC and Cubits work in this codebase — patterns, rules, and how to add new ones.

---

## BLoC vs Cubit — when to use which

Both live in `lib/logic/`. The rule is simple:

| Use | When |
|---|---|
| **Bloc** | You have named events (user did X, system emitted Y) and complex state transitions |
| **Cubit** | You have simple state changes driven by direct method calls |

In practice:
- Feature state with loading/success/error → **Bloc**
- Toggle, theme, connectivity, app lock → **Cubit**

```
logic/
  bloc/    ← AuthBloc, MatchesBloc, ConnectionsBloc, ChatSocketsBloc, …
  cubit/   ← ThemeCubit, AppLockCubit, ConnectivityCubit
```

---

## Anatomy of a Bloc

Every bloc has 3 files (Dart `part` system):

```
auth_bloc.dart    ← the bloc class
auth_event.dart   ← all events (sealed)
auth_state.dart   ← all states (sealed)
```

### Events

```dart
// auth_event.dart
part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

final class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthLoginRequested({required this.email, required this.password});
}

final class AuthRegisterRequested extends AuthEvent { ... }
```

Each event is a `final class` that extends the sealed base. Add a new event by adding a new class here.

### States

```dart
// auth_state.dart
part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}
final class AuthLoading extends AuthState {}
final class AuthAuthenticated extends AuthState {}
final class AuthFailure extends AuthState {
  final String message;
  const AuthFailure({required this.message});
}
```

Pattern: `Initial → Loading → Success | Failure`. Every feature follows this shape.

### The Bloc

```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _login;
  // ... other use cases

  AuthBloc({required LoginUseCase loginUseCase, ...})
      : _login = loginUseCase,
        super(AuthInitial()) {
    on<AuthLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _login(event.email, event.password);
        emit(AuthAuthenticated());
      } catch (e) {
        emit(AuthFailure(message: e.toString()));
      }
    });
  }
}
```

The bloc:
1. Starts in the initial state (`super(AuthInitial())`)
2. Registers one handler per event (`on<EventType>`)
3. Calls a use case
4. Emits the result state

Never put API calls, database access, or HTTP directly in a bloc. That belongs in use cases and datasources.

---

## Anatomy of a Cubit

Simpler — no events, just methods that call `emit`.

```dart
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.dark) {
    _loadTheme();    // load persisted preference on startup
  }

  void toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    emit(newMode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', newMode == ThemeMode.light ? 'light' : 'dark');
  }
}
```

The widget calls `context.read<ThemeCubit>().toggleTheme()` directly — no event class needed.

---

## Singleton vs factory blocs

Registered in `injection_container.dart`. The distinction matters:

**Singleton (`registerLazySingleton`)** — one shared instance across the whole app. Use for blocs that hold app-wide state that must survive navigation.

```dart
sl.registerLazySingleton<MatchesBloc>(() => MatchesBloc(...));
sl.registerLazySingleton<ConnectionsBloc>(() => ConnectionsBloc(...));
sl.registerLazySingleton<ProfileBloc>(() => ProfileBloc(...));
sl.registerLazySingleton<ChatSocketsBloc>(() => ChatSocketsBloc(...));
```

**Factory (`registerFactory`)** — fresh instance every time it's requested. Use for blocs scoped to a single screen.

```dart
sl.registerFactory<AuthBloc>(() => AuthBloc(...));
sl.registerFactory<OtpBloc>(() => OtpBloc(...));
sl.registerFactory<OtherProfileBloc>(() => OtherProfileBloc(...));
```

When you open a screen that uses `OtherProfileBloc`, it gets a clean slate. When you navigate away, the old instance is discarded.

---

## BlocProvider — where blocs live in the widget tree

Singleton blocs are provided at the app root so any screen can access them:

```dart
// main.dart (or app.dart)
MultiBlocProvider(
  providers: [
    BlocProvider(create: (_) => sl<MatchesBloc>()),
    BlocProvider(create: (_) => sl<ConnectionsBloc>()),
    BlocProvider(create: (_) => sl<ProfileBloc>()),
    BlocProvider(create: (_) => sl<ChatSocketsBloc>()),
    BlocProvider(create: (_) => sl<ThemeCubit>()),
    // ...
  ],
  child: MaterialApp(...),
)
```

Screen-scoped blocs are provided at the screen level:

```dart
BlocProvider(
  create: (_) => sl<OtherProfileBloc>()..add(LoadOtherProfileEvent(userId)),
  child: UserProfileBottomSheet(),
)
```

---

## Reading state in widgets

Three widgets for three patterns:

### `BlocBuilder` — rebuild on state change

```dart
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    if (state is AuthLoading) return const CircularProgressIndicator();
    if (state is AuthFailure) return Text(state.message);
    return const SizedBox.shrink();
  },
)
```

Use this when a widget needs to **render differently** based on state.

### `BlocListener` — react without rebuilding

```dart
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthAuthenticated) {
      Navigator.pushReplacementNamed(context, '/home');
    }
    if (state is AuthFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: LoginForm(),
)
```

Use this for **side effects** — navigation, snackbars, dialogs. Never navigate inside a `builder`.

### `BlocConsumer` — both

```dart
BlocConsumer<AuthBloc, AuthState>(
  listener: (context, state) { /* navigation, toasts */ },
  builder: (context, state) { /* UI */ },
)
```

Use when you need both: rebuild AND side effects.

---

## Dispatching events

```dart
// From a widget
context.read<AuthBloc>().add(AuthLoginRequested(
  email: email,
  password: password,
));

// For Cubits, call the method directly
context.read<ThemeCubit>().toggleTheme();
```

Use `context.read` when you only want to dispatch (inside a callback). Use `context.watch` only inside `build` when you need to read the current state directly (prefer `BlocBuilder` though).

---

## How to add a new Bloc

**Step 1** — Create the 3 files:

```
lib/logic/bloc/my_feature/
  my_feature_bloc.dart
  my_feature_event.dart
  my_feature_state.dart
```

**Step 2** — Define events and states using the sealed pattern shown above.

**Step 3** — Write the bloc class. Inject use cases via constructor. Register one `on<>` handler per event.

**Step 4** — Register in `injection_container.dart`:
- `registerLazySingleton` if it's app-wide state.
- `registerFactory` if it's screen-scoped.

**Step 5** — Add to `MultiBlocProvider` in the app root (if singleton) or wrap the specific screen (if factory).

**Step 6** — Use `BlocBuilder`/`BlocListener`/`BlocConsumer` in the screen.

---

## Rules

- **No API calls in blocs.** Blocs call use cases. Use cases call repositories. Repositories call datasources.
- **No navigation in `builder`.** Navigate in `listener` only.
- **No `context.watch` outside `build`.** Use `BlocBuilder`.
- **Emit `Loading` before async work.** Always. The UI needs to show a spinner.
- **Catch all exceptions.** Wrap every use case call in `try/catch` and emit a failure state.
- **Factory blocs get fresh state.** Don't rely on leftover state from a previous navigation to a screen that uses a factory bloc.
