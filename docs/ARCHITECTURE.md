# Architecture & Migration Guide

This document explains how the Linkup Flutter codebase is structured, why it was designed this way, and how to orient yourself if you're coming from an earlier version.

---

## Why This Architecture Exists

The original codebase worked, but it had a structural problem that would have compounded as the app grew:

**BLoCs called HTTP services directly.** There was no domain layer — models doubled as domain objects, HTTP service classes used static methods, and business logic was scattered across layers. The most telling example was `AuthHttpServices.login()`:

```dart
// BEFORE — three unrelated responsibilities in one static method
static Future<int> login(String email, String password) async {
  final response = await http.post(Uri.parse("$BASE_URL/token"), ...);

  if (response.statusCode == 200) {
    final responseBody = jsonDecode(response.body);
    // 1. HTTP parsing ↓
    final String accessToken = responseBody['access_token'];
    // 2. Token persistence ↓
    await _secureStorage.write(key: 'access_token', value: accessToken);
    // 3. Dependency injection side-effect ↓
    GetItRegisterer.registerValue<int>(value: userID, name: "user_id");
  }
  return response.statusCode;
}
```

This made the codebase hard to test (static methods can't be swapped for mocks), hard to reason about (any layer could trigger DI side-effects), and brittle to change (touching the HTTP response format broke BLoC logic).

The rewrite introduced a strict four-layer boundary. Each layer only knows about the layer directly below it, and dependencies only point inward.

---

## Layer Reference

```
┌─────────────────────────────────────────────────────────┐
│  Presentation  (lib/logic/ + lib/presentation/)         │
│  Screens · BLoCs · Cubits                               │
├─────────────────────────────────────────────────────────┤
│  Domain  (lib/domain/)                                  │
│  Entities · Repository Interfaces · Use Cases           │
├─────────────────────────────────────────────────────────┤
│  Data  (lib/data/)                                      │
│  Datasources · Repository Implementations · Models      │
├─────────────────────────────────────────────────────────┤
│  Core  (lib/core/)                                      │
│  HTTP Client · Token Service · DI Container             │
└─────────────────────────────────────────────────────────┘
```

### Core — `lib/core/`

Shared infrastructure with no knowledge of business logic.

| File | Responsibility |
|------|---------------|
| `core/network/custom_http_client.dart` | Authenticated HTTP with automatic token refresh on 401/403 |
| `core/network/token_service.dart` | Read, write, and clear JWT tokens in `FlutterSecureStorage` |
| `core/di/injection_container.dart` | Single `initDependencies()` that wires the entire dependency graph |
| `core/constants/app_constants.dart` | `BASE_URL`, `WS_BASE_URL` |
| `core/enums/` | Shared enumerations |

`CustomHttpClient` wraps every outbound request in a token-refresh check — if the server returns 401 or 403, it silently fetches a new access token using the stored refresh token and retries the original request. BLoCs never see token expiry.

---

### Domain — `lib/domain/`

The only layer with zero Flutter or HTTP dependencies. Everything here is plain Dart.

**Entities** (`lib/domain/entities/`) — immutable data classes that represent the app's core concepts. They carry no JSON annotations or Isar decorators.

```
UserEntity · UserPreferenceEntity · MatchCandidateEntity
MatchesConnectionEntity · ChatConnectionEntity · MessageEntity · MediaMessageEntity
```

**Repository interfaces** (`lib/domain/repositories/`) — abstract contracts that define what the data layer must provide. Presentation code depends on these interfaces, never on the implementations.

```dart
abstract class AuthRepository {
  Future<void> login(String email, String password);
  Future<void> logout();
  Future<void> deleteAccount();
  // ...
}
```

**Use cases** (`lib/domain/use_cases/`) — 33 single-responsibility callable classes, one per discrete operation.

```dart
class LoginUseCase {
  final AuthRepository _repository;
  const LoginUseCase(this._repository);

  Future<void> call(String email, String password) =>
      _repository.login(email, password);
}
```

Use cases are registered as `registerFactory` in GetIt, so each BLoC gets a fresh instance with its injected repository.

---

### Data — `lib/data/`

Implements the domain contracts and owns all I/O.

**Remote datasources** (`lib/data/datasources/remote/`) — one class per API domain. Instance methods (not static), constructor-injected `CustomHttpClient`, typed return values using Dart records.

```dart
// AFTER — single responsibility: HTTP + deserialise only
class AuthRemoteDatasource {
  final CustomHttpClient _client;
  AuthRemoteDatasource(this._client);

  Future<({String accessToken, String refreshToken, int userId})> login(
    String email, String password,
  ) async {
    final response = await http.post(Uri.parse('$BASE_URL/token'), ...);
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return (
        accessToken: body['access_token'] as String,
        refreshToken: body['refresh_token'] as String,
        userId: body['user_id'] as int,
      );
    }
    throw Exception('Login failed: ${response.statusCode}');
  }
}
```

| Remote datasource | Covers |
|-------------------|--------|
| `AuthRemoteDatasource` | Login, register, OTP, password reset, profile completion |
| `UserRemoteDatasource` | Profile fetch/update, other-user profile, block, report, delete account |
| `MatchRemoteDatasource` | Match deck, connections list |
| `SwipeRemoteDatasource` | Like / pass actions |
| `ChatRemoteDatasource` | Chat history, start chat, paginate messages |
| `MediaRemoteDatasource` | Photo upload, profile-picture pipeline |
| `CityLookupRemoteDatasource` | City autocomplete search |

**Local datasources** (`lib/data/datasources/local/`) — Isar database operations extracted from BLoCs into dedicated classes.

| Local datasource | Covers |
|-----------------|--------|
| `MessageLocalDatasource` | Cache messages, load cached messages, unsent message queue |
| `ChatLocalDatasource` | Cache chat connections list for offline-first display |

**Socket datasources** (`lib/data/datasources/socket/`) — thin wrappers around `BaseSocketService` that expose typed streams per domain.

| Socket datasource | WebSocket endpoint | Consumed by |
|------------------|--------------------|-------------|
| `ChatSocketDatasource` | `/ws/chat` | `ChatSocketsBloc` |
| `ConnectionsSocketDatasource` | `/ws/connections` | `ConnectionsSocketBloc` |
| `LobbySocketDatasource` | `/ws/lobby` | `LobbyBloc` |

`BaseSocketService` handles auto-reconnect, 6-second keepalive ping, and transparent token refresh on 401/403 disconnections.

**Repository implementations** (`lib/data/repositories/`) — orchestrate datasources and own business coordination. `AuthRepositoryImpl` is the canonical example of clean responsibility:

```dart
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _authDatasource;
  final TokenService _tokenService;

  @override
  Future<void> login(String email, String password) async {
    final result = await _authDatasource.login(email, password);
    // token persistence belongs here, not in the datasource
    await _tokenService.saveTokens(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
      userId: result.userId,
    );
  }
}
```

**Models** (`lib/data/models/`) — serialisation-annotated classes that come back from the API. The data layer converts models → entities before handing anything to the domain or presentation layers.

---

### Presentation — `lib/logic/` + `lib/presentation/`

BLoCs and cubits receive use cases via constructor injection and emit typed states. Screens only read BLoC state — they never touch repositories or datasources directly.

```dart
// AFTER — BLoC depends only on a use case interface, nothing from data/
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _login;

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

**BLoC registration tiers:**

| Tier | Examples | GetIt registration |
|------|----------|--------------------|
| Shared global state | `MatchesBloc`, `ConnectionsBloc`, `ProfileBloc`, `ChatSocketsBloc` | `registerLazySingleton` |
| Per-screen state | `AuthBloc`, `OtpBloc`, `PreferencesBloc`, `OtherProfileBloc` | `registerFactory` |
| Inline-created | `ChatsBloc` (one per chat room) | `BlocProvider` at navigation point |

---

## Before → After: Full Comparison

| Concern | Before | After |
|---------|--------|-------|
| **Dependency injection** | `GetItRegisterer.registerValue()` called inside `login()` | `initDependencies()` in `injection_container.dart`, called once at app start |
| **HTTP access** | `static AuthHttpServices.login()` — GetIt accessed globally | Instance `AuthRemoteDatasource.login()` — `CustomHttpClient` constructor-injected |
| **Token persistence** | Inside `AuthHttpServices.login()` (3 concerns in 1 method) | `AuthRepositoryImpl.login()` delegates to `TokenService.saveTokens()` |
| **BLoC dependencies** | Direct static HTTP call from bloc event handler | Use cases injected via constructor; bloc has no `import 'package:http'` |
| **Domain types** | `UserModel` used in screens, blocs, HTTP services | `UserEntity` in presentation/domain; `UserModel` only in data layer |
| **Local DB writes** | Isar queries in `ChatsBloc` event handlers | Encapsulated in `MessageLocalDatasource` / `ChatLocalDatasource` |
| **Testability** | Static methods — no mocking without patching | All dependencies injected — swap any layer with a mock via GetIt |

---

## Full Request Lifecycle

A login button tap traced through every layer:

```
User taps "Login"
  ↓
LoginPage
  context.read<AuthBloc>().add(AuthLoginRequested(email, password))
  ↓
AuthBloc.on<AuthLoginRequested>
  emit(AuthLoading())
  await _login(event.email, event.password)   ← LoginUseCase
  ↓
LoginUseCase.call(email, password)
  _repository.login(email, password)          ← AuthRepository (interface)
  ↓
AuthRepositoryImpl.login(email, password)
  result = await _authDatasource.login(...)   ← AuthRemoteDatasource
  await _tokenService.saveTokens(result)      ← TokenService
  ↓
AuthRemoteDatasource.login(email, password)
  http.post("$BASE_URL/token", ...)
  → server responds {access_token, refresh_token, user_id}
  ← returns typed Dart record
  ↓
Back up the chain:
  AuthRepositoryImpl stores tokens
  AuthBloc emits AuthAuthenticated()
  ↓
LoadingScreenPostLogin reacts to AuthAuthenticated
  navigates to MatchMakingPage
```

---

## WebSocket Architecture

```
BaseSocketService  (lib/data/websocket_services/)
│  auto-reconnect · 6 s ping · 401 token-refresh
│
├── ChatSocketDatasource    → ChatSocketsBloc    → ChatPage
├── ConnectionsSocketDatasource → ConnectionsSocketBloc → ConnectionsPage
└── LobbySocketDatasource  → LobbyBloc          → MeetAt8Page
```

Each datasource exposes a broadcast `Stream<Map>` (messages) and a `Stream<bool>` (connection status). BLoCs subscribe in `initState` and cancel on `close()`.

---

## Dependency Injection Cheat Sheet

All registrations live in `lib/core/di/injection_container.dart`:

```
initDependencies()
│
├── Singletons (created immediately, live for app lifetime)
│   FlutterSecureStorage · CustomHttpClient · Isar · TokenService
│
├── LazySingletons (created on first use, then cached)
│   Datasources:   AuthRemoteDatasource · UserRemoteDatasource · ...
│   Repositories:  AuthRepositoryImpl · ChatRepositoryImpl · ...
│   Shared blocs:  MatchesBloc · ConnectionsBloc · ProfileBloc · ChatSocketsBloc
│
└── Factories (new instance on every sl<T>() call)
    Use cases:     LoginUseCase · FetchMessagesUseCase · SwipeUseCase · ...
    Screen blocs:  AuthBloc · OtpBloc · PreferencesBloc · OtherProfileBloc
```

---

## Migration Complete

The clean architecture migration is fully complete. All legacy code has been removed:

| Deleted | Replaced by |
|---------|-------------|
| `lib/data/http_services/` | `lib/data/datasources/remote/` |
| `lib/data/get_it/` | `lib/core/di/injection_container.dart` |
| `lib/data/token/` | `lib/core/network/token_service.dart` |
| `lib/data/clients/` | `lib/core/network/custom_http_client.dart` |
| `lib/presentation/constants/global_constants.dart` | `lib/core/constants/app_constants.dart` |

`fvm flutter analyze` reports **0 issues** (0 errors, 0 warnings, 0 info).
