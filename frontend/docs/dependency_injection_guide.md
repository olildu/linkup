# Dependency Injection Guide

> How `GetIt` is used to wire everything together — and how to register something new.

---

## What is dependency injection?

Dependency injection is just a fancy term for: **don't create your own dependencies, ask for them**.

Instead of:
```dart
// Bad — LoginUseCase creates its own AuthRemoteDatasource
class LoginUseCase {
  final _ds = AuthRemoteDatasource(CustomHttpClient());  // tightly coupled
}
```

We do:
```dart
// Good — LoginUseCase receives its dependency
class LoginUseCase {
  final AuthRepository _repository;
  const LoginUseCase(this._repository);   // injected from outside
}
```

This makes code testable (swap the real repository for a fake one in tests) and decoupled (LoginUseCase doesn't care how auth works, just what it returns).

---

## The service locator: `GetIt`

We use the `get_it` package. The global instance is `sl` ("service locator"):

```dart
// lib/core/di/injection_container.dart
final sl = GetIt.instance;
```

Think of `sl` as a dictionary. You put things in during startup. Any code in the app can look them up by type.

---

## Startup: `initDependencies()`

Called once in `main.dart` before `runApp`. It's async because Isar and path_provider need async init.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(MyApp());
}
```

The function registers everything in a specific order:

```
Core (storage, HTTP client, Isar, token service)
    ↓
Datasources (remote, local, socket)
    ↓
Repositories (implement domain contracts, use datasources)
    ↓
Use Cases (use repositories)
    ↓
Blocs (use use cases)
```

Order matters. You can't register a repository before the datasource it needs, because `sl()` resolves the dependency at registration time for some registration types.

---

## Registration types

### `registerSingleton` — created immediately, one instance forever

```dart
sl.registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage());
sl.registerSingleton<CustomHttpClient>(CustomHttpClient());
sl.registerSingleton<Isar>(isar);
sl.registerSingleton<TokenService>(TokenService(storage));
```

Used for infrastructure that must exist before anything else runs. Note that `FlutterSecureStorage` is registered first — `CustomHttpClient` reads it at construction time.

### `registerLazySingleton` — created once, on first use

```dart
sl.registerLazySingleton<AuthRemoteDatasource>(() => AuthRemoteDatasource(sl()));
sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
  authDatasource: sl(),
  userDatasource: sl(),
  tokenService: sl(),
));
sl.registerLazySingleton<MatchesBloc>(() => MatchesBloc(
  loadMatchesUseCase: sl(),
  swipeUseCase: sl(),
));
```

The `() => ...` is a factory function. `sl()` inside it resolves the type parameter automatically — `sl<AuthRemoteDatasource>()` but with the type inferred from the parameter. Used for most datasources, repositories, and singleton blocs.

### `registerFactory` — new instance on every `sl<T>()` call

```dart
sl.registerFactory(() => LoginUseCase(sl()));
sl.registerFactory<AuthBloc>(() => AuthBloc(
  loginUseCase: sl(),
  logoutUseCase: sl(),
  ...
));
```

Use cases are always factories — they're stateless, so a new instance costs almost nothing. Screen-scoped blocs are also factories so each screen gets a clean state.

---

## Resolving dependencies

In widget code, use `sl<T>()` inside `BlocProvider`:

```dart
BlocProvider(
  create: (_) => sl<OtherProfileBloc>(),
  child: UserProfileBottomSheet(),
)
```

You almost never call `sl<T>()` directly inside widgets. The bloc is provided via `BlocProvider` and read via `context.read<T>()`.

---

## How to add a new dependency

**Scenario: you're adding a `NotificationsFeature`** with a datasource, repository, use case, and bloc.

**1. Create the files** following the existing pattern, grouped under the feature's own folder:
- `lib/features/notifications/data/notifications_remote_datasource.dart`
- `lib/features/notifications/data/notifications_repository_impl.dart`
- `lib/features/notifications/domain/notifications_repository.dart` (abstract)
- `lib/features/notifications/domain/get_notifications_use_case.dart`
- `lib/features/notifications/presentation/bloc/notifications_bloc.dart`

**2. Register in `injection_container.dart`** in the correct section and order:

```dart
// Datasource
sl.registerLazySingleton<NotificationsRemoteDatasource>(
  () => NotificationsRemoteDatasource(sl()),
);

// Repository (use the abstract type as key, impl as value)
sl.registerLazySingleton<NotificationsRepository>(
  () => NotificationsRepositoryImpl(sl()),
);

// Use case (always factory — stateless)
sl.registerFactory(() => GetNotificationsUseCase(sl()));

// Bloc — singleton if app-wide, factory if screen-scoped
sl.registerLazySingleton<NotificationsBloc>(
  () => NotificationsBloc(getNotificationsUseCase: sl()),
);
```

**3. Add to `MultiBlocProvider`** in the app root if it's a singleton bloc.

---

## Common mistakes

**Registering in the wrong order.** If `AuthRepositoryImpl` needs `AuthRemoteDatasource`, register the datasource first.

**Using `sl()` instead of `sl<Type>()`.** `sl()` infers the type from context. Inside a factory lambda, write `sl<AuthRemoteDatasource>()` explicitly if type inference fails.

**Registering a bloc as `registerSingleton` when it should be `registerLazySingleton`.** `registerSingleton` constructs immediately — the bloc tries to get its use cases from `sl` before they're registered. Always use `registerLazySingleton` for blocs.

**Calling `sl<T>()` inside `initState`.** At `initState` time, `BlocProvider` already provides the bloc. Use `context.read<T>()` instead.

---

## Reading what's registered

To see all registered types and the full wiring, read:

```
lib/core/di/injection_container.dart
```

It's the single source of truth for what depends on what. If you're confused about where a bloc gets its use case, this file answers it.
