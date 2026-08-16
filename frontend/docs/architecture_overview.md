# Architecture Overview

> **The big picture.** Read this first before touching any other doc. Everything else builds on what's here.

---

## The core idea: layers

The app is split into 4 layers. Each layer has one job and talks only to the layer below it. Think of it like a chain of people passing a note — the person at the top never knows who wrote the original draft.

```
┌─────────────────────────────────────────────────────────┐
│  presentation/   ← what the user sees (widgets, screens) │
│        ↓                                                  │
│  logic/          ← decisions (blocs, cubits)              │
│        ↓                                                  │
│  domain/         ← rules (use cases, repository contracts)│
│        ↓                                                  │
│  data/           ← raw data (API, local DB, sockets)      │
└─────────────────────────────────────────────────────────┘
```

The rule is simple: **a layer may only depend on the layer directly below it.** `presentation` can talk to `logic`. `logic` can talk to `domain`. `domain` can talk to nothing — it defines the contracts. `data` implements those contracts.

---

## The layers in detail

### `core/` — shared infrastructure

Not really a "layer" — it's shared utilities used by every layer.

```
lib/core/
  constants/    app_constants.dart    ← BASE_URL, WS_BASE_URL, prod flag
  di/           injection_container.dart  ← dependency registration (GetIt)
  enums/        ← shared enum types
  errors/       failures.dart         ← sealed Failure hierarchy
  network/      custom_http_client.dart  ← HTTP with auth + retry
                token_service.dart       ← JWT storage/refresh
```

Key things here:
- `app_constants.dart` controls whether you hit prod or local. Flip `prod = false` and set your IP for local dev.
- `custom_http_client.dart` handles token refresh automatically. All API calls go through it — you never write `http.get` directly.
- `failures.dart` defines `NetworkFailure`, `ServerFailure`, `AuthFailure`, `CacheFailure` — typed error wrappers.

---

### `data/` — the raw data layer

This layer knows how to fetch, store, and stream data. It knows about HTTP, JSON, Isar, and WebSockets. **No widget or business logic lives here.**

```
lib/data/
  datasources/
    remote/     ← HTTP API calls (one file per domain)
    local/      ← Isar read/write (chat_local, message_local)
    socket/     ← WebSocket event parsing (one file per socket)
  websocket_services/
    base_socket_service.dart           ← connect/disconnect/reconnect logic
    chat_socket_services/              ← chat WebSocket singleton
    connections_socket_services/       ← connections WebSocket singleton
    lobby_socket_services/             ← lobby WebSocket singleton
  isar_classes/                        ← Isar collection schemas
  models/                              ← JSON-serializable data models
  repositories/                        ← implement domain repository contracts
  services/                            ← one-off services (biometric, signup options)
```

The pattern for every datasource is the same:

```dart
// All it does: call the API, parse JSON, return a model or throw.
class AuthRemoteDatasource {
  final CustomHttpClient _client;
  AuthRemoteDatasource(this._client);

  Future<AuthModel> login(String email, String password) async {
    final res = await _client.post(Uri.parse('$BASE_URL/login'), body: ...);
    return AuthModel.fromJson(jsonDecode(res.body));
  }
}
```

---

### `domain/` — the rules layer

This layer defines **what the app can do**, not **how**. It contains:

- **Entities** — pure Dart data classes. No JSON, no Isar annotations. Just the data your UI cares about.
- **Repository interfaces** — abstract classes that declare what data operations exist.
- **Use cases** — one class, one operation. Calls a repository method.

```
lib/domain/
  entities/         ← UserEntity, MessageEntity, MatchCandidateEntity, …
  repositories/     ← abstract AuthRepository, ChatRepository, …
  use_cases/
    auth/           ← LoginUseCase, RegisterUseCase, LogoutUseCase, …
    chat/           ← FetchMessagesUseCase, CacheMessageUseCase, …
    match/          ← LoadMatchesUseCase, SwipeUseCase, …
    user/           ← GetProfileUseCase, UpdateProfileUseCase, …
    media/          ← UploadPfpUseCase, UploadUserMediaUseCase, …
    city/           ← SearchCitiesUseCase
```

A use case is tiny on purpose:

```dart
class LoginUseCase {
  final AuthRepository _repository;
  const LoginUseCase(this._repository);

  Future<void> call(String email, String password) =>
      _repository.login(email, password);
}
```

Why so small? Because the use case is the only thing the bloc ever calls. If you need to add a step to login (e.g. log analytics), you add it here, not in the bloc. The bloc stays dumb.

---

### `logic/` — the decision layer

This is where state lives. Blocs and cubits receive events/calls from the UI, call use cases, and emit new states.

```
lib/logic/
  bloc/
    auth/           ← AuthBloc (login, register, reset password)
    login/          ← LoginBloc (login-screen-specific)
    otp/            ← OtpBloc
    signup/         ← SignupBloc
    matches/        ← MatchesBloc (swipe candidates)
    connections/    ← ConnectionsBloc (connections list)
    chats/          ← ChatsBloc (chat list)
    lobby/          ← LobbyBloc (meet-at-8 lobby)
    profile/
      own/          ← ProfileBloc, PreferencesBloc
      others/       ← OtherProfileBloc
    camera/         ← CameraBloc
    post_login/     ← PostLoginBloc (routing after auth)
    web_socket/
      chat_sockets/        ← ChatSocketsBloc
      connection_sockets/  ← ConnectionsSocketBloc
      web_socket_bloc.dart ← root WebSocket orchestrator
  cubit/
    theme/          ← ThemeCubit (light/dark toggle + persistence)
    app_lock/       ← AppLockCubit (biometric lock)
    connectivity/   ← ConnectivityCubit (online/offline)
```

---

### `presentation/` — the UI layer

Widgets, screens, components, and theme. **Contains no business logic.** State comes from blocs via `BlocBuilder`/`BlocConsumer`.

```
lib/presentation/
  screens/        ← full-page widgets (one per route)
  components/     ← reusable widgets grouped by screen
  constants/      ← AppColors (semantic color tokens)
  theme/          ← AppTheme, AppTypography, AppSpacing, AppRadius, AppShadows
```

---

## Data flow — a complete example

User taps "Log In" button.

```
1. LoginPage (presentation)
   └─ context.read<AuthBloc>().add(AuthLoginRequested(email, password))

2. AuthBloc (logic)
   └─ on<AuthLoginRequested>:
       emit(AuthLoading)
       await _login(email, password)   // LoginUseCase
       emit(AuthAuthenticated)  or  emit(AuthFailure)

3. LoginUseCase (domain)
   └─ _repository.login(email, password)

4. AuthRepositoryImpl (data)
   └─ final result = await _authDatasource.login(email, password)
      await _tokenService.saveTokens(result.accessToken, result.refreshToken)

5. AuthRemoteDatasource (data)
   └─ POST /login  →  parse JSON  →  return AuthModel

6. TokenService (core)
   └─ FlutterSecureStorage.write('access_token', ...)
```

The widget reacts to `AuthAuthenticated` and navigates to the home screen. No widget touched a network call. No network call touched a widget.

---

## The dependency rule — one chart to remember

```
  presentation  →  logic  →  domain  ←  data
```

`domain` points at nothing (it defines contracts). `data` implements the contracts. The arrow shows "depends on". `data` depends on `domain` types but not on `logic` or `presentation`.

If you ever find yourself importing a `presentation/` file from `logic/`, or a `logic/` file from `data/`, something is wrong. Fix the dependency direction, not the import.

---

## Key packages and why they exist

| Package | Role |
|---|---|
| `flutter_bloc` | BLoC pattern — state management |
| `get_it` | Service locator — dependency injection (`sl<T>()`) |
| `isar` | Local database — offline-first message/chat cache |
| `flutter_secure_storage` | Encrypted storage — JWT tokens |
| `shared_preferences` | Simple key-value — theme mode, app lock flag |
| `flutter_screenutil` | Responsive sizing — `.sp`, `.w`, `.h` extensions |
| `google_fonts` | Fonts — SpaceGrotesk (UI), RobotoMono (mono) |
| `web_socket_channel` | WebSocket client |
| `http` | HTTP client (wrapped by `CustomHttpClient`) |
| `octo_image` | Image loading with blurhash placeholders |

---

## Where to start reading code

If you're new, read files in this order:

1. `lib/core/di/injection_container.dart` — see every dependency and how they connect
2. `lib/domain/repositories/auth_repository.dart` — the interface pattern
3. `lib/data/repositories/auth_repository_impl.dart` — how it's implemented
4. `lib/logic/bloc/auth/auth_bloc.dart` — how a bloc uses use cases
5. `lib/presentation/screens/login_page.dart` — how a screen uses a bloc
