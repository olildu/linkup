# Feature Development Guide

> End-to-end walkthrough — from API call to UI. Follow this every time you add a new feature.

---

## The mental model

Every feature in this app is built the same way, layer by layer, starting from the bottom. Think of it like building a water pipe: you lay the pipe from the source (API) to the tap (UI), and water only flows in one direction.

The codebase is organized **feature-first**: each feature owns a `lib/features/<feature>/` folder containing its own `data/`, `domain/`, and `presentation/` subfolders — the layer boundaries below still apply, they're just scoped per-feature instead of being top-level folders shared by all features. Cross-feature infrastructure (HTTP client, DI, entities used by 3+ features) lives in `lib/core/`; cross-feature widgets/theme live in `lib/shared_ui/`. See `docs/ARCHITECTURE.md`.

```
API (server)
  → Datasource (fetch + parse JSON)
  → Repository implementation (orchestrate datasources)
  → Repository interface (domain contract)
  → Use case (one action = one class)
  → Bloc (call use case, emit state)
  → Widget (listen to state, dispatch events)
```

Build it in this order. Test each layer as you go. Don't jump to the widget before the use case is wired up.

---

## Worked example: "Notifications" feature

We'll add a notifications endpoint that fetches a list of notifications for the user.

---

### Step 1 — The domain entity

The entity is a pure Dart class. No JSON, no database annotations, no Flutter imports. Just the fields the UI will care about.

```dart
// lib/features/notifications/domain/notification_entity.dart
class NotificationEntity {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
  });
}
```

Keep entities immutable (`const`, no setters). If the UI needs a modified version, use `copyWith`.

---

### Step 2 — The data model

The model knows about JSON. It lives in `data/models/`.

```dart
// lib/features/notifications/data/notification_model.dart
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;

  const NotificationModel({...});

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool,
    );
  }

  // Converts to the domain entity (strip JSON knowledge from domain)
  NotificationEntity toEntity() => NotificationEntity(
    id: id,
    title: title,
    body: body,
    createdAt: createdAt,
    isRead: isRead,
  );
}
```

The model has `fromJson`. The entity doesn't. That's the split.

---

### Step 3 — The remote datasource

Makes the HTTP call. Returns a model (not an entity). Lives in `data/datasources/remote/`.

```dart
// lib/features/notifications/data/notifications_remote_datasource.dart
import 'dart:convert';
import 'package:linkup/core/constants/app_constants.dart';
import 'package:linkup/core/network/custom_http_client.dart';
import 'package:linkup/features/notifications/data/notification_model.dart';

class NotificationsRemoteDatasource {
  final CustomHttpClient _client;
  NotificationsRemoteDatasource(this._client);

  Future<List<NotificationModel>> getNotifications() async {
    final res = await _client.get(Uri.parse('$BASE_URL/notifications'));
    final List<dynamic> json = jsonDecode(res.body);
    return json.map((e) => NotificationModel.fromJson(e)).toList();
  }
}
```

Never use `http.get` directly. Always go through `CustomHttpClient` — it handles auth headers, token refresh, and error mapping automatically.

---

### Step 4 — The domain repository interface

This is the contract. The `domain/` layer defines what it wants. The `data/` layer fulfills it.

```dart
// lib/features/notifications/domain/notifications_repository.dart
abstract class NotificationsRepository {
  Future<List<NotificationEntity>> getNotifications();
}
```

Notice: it returns `NotificationEntity`, not `NotificationModel`. The domain layer never touches JSON models.

---

### Step 5 — The repository implementation

Implements the interface. Calls the datasource. Converts models to entities.

```dart
// lib/features/notifications/data/notifications_repository_impl.dart
import 'package:linkup/features/notifications/data/notifications_remote_datasource.dart';
import 'package:linkup/features/notifications/domain/notification_entity.dart';
import 'package:linkup/features/notifications/domain/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDatasource _datasource;
  NotificationsRepositoryImpl(this._datasource);

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    final models = await _datasource.getNotifications();
    return models.map((m) => m.toEntity()).toList();
  }
}
```

---

### Step 6 — The use case

One class, one action. Takes the repository, calls the method.

```dart
// lib/features/notifications/domain/get_notifications_use_case.dart
import 'package:linkup/features/notifications/domain/notifications_repository.dart';
import 'package:linkup/features/notifications/domain/notification_entity.dart';

class GetNotificationsUseCase {
  final NotificationsRepository _repository;
  const GetNotificationsUseCase(this._repository);

  Future<List<NotificationEntity>> call() => _repository.getNotifications();
}
```

The `call()` method lets you invoke it like a function: `await _getNotifications()`.

---

### Step 7 — The bloc

Three files: bloc, event, state.

```dart
// lib/features/notifications/presentation/bloc/notifications_state.dart
part of 'notifications_bloc.dart';

@immutable
sealed class NotificationsState {}

final class NotificationsInitial extends NotificationsState {}
final class NotificationsLoading extends NotificationsState {}
final class NotificationsLoaded extends NotificationsState {
  final List<NotificationEntity> notifications;
  const NotificationsLoaded(this.notifications);
}
final class NotificationsFailure extends NotificationsState {
  final String message;
  const NotificationsFailure(this.message);
}
```

```dart
// lib/features/notifications/presentation/bloc/notifications_event.dart
part of 'notifications_bloc.dart';

@immutable
sealed class NotificationsEvent {}

final class LoadNotificationsEvent extends NotificationsEvent {}
```

```dart
// lib/features/notifications/presentation/bloc/notifications_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:linkup/features/notifications/domain/notification_entity.dart';
import 'package:linkup/features/notifications/domain/get_notifications_use_case.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final GetNotificationsUseCase _getNotifications;

  NotificationsBloc({required GetNotificationsUseCase getNotificationsUseCase})
      : _getNotifications = getNotificationsUseCase,
        super(NotificationsInitial()) {
    on<LoadNotificationsEvent>((event, emit) async {
      emit(NotificationsLoading());
      try {
        final notifications = await _getNotifications();
        emit(NotificationsLoaded(notifications));
      } catch (e) {
        emit(NotificationsFailure(e.toString()));
      }
    });
  }
}
```

---

### Step 8 — Register in the DI container

```dart
// lib/core/di/injection_container.dart

// Datasource
sl.registerLazySingleton<NotificationsRemoteDatasource>(
  () => NotificationsRemoteDatasource(sl()),
);

// Repository (always register against the abstract type)
sl.registerLazySingleton<NotificationsRepository>(
  () => NotificationsRepositoryImpl(sl()),
);

// Use case (always factory — stateless)
sl.registerFactory(() => GetNotificationsUseCase(sl()));

// Bloc (singleton if shared app-wide, factory if per-screen)
sl.registerLazySingleton<NotificationsBloc>(
  () => NotificationsBloc(getNotificationsUseCase: sl()),
);
```

---

### Step 9 — The screen

```dart
// lib/features/notifications/presentation/screens/notifications_page.dart
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});
  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationsBloc>().add(LoadNotificationsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, state) {
          if (state is NotificationsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is NotificationsFailure) {
            return Center(
              child: Text(state.message, style: Theme.of(context).textTheme.bodyLarge),
            );
          }
          if (state is NotificationsLoaded) {
            return ListView.builder(
              itemCount: state.notifications.length,
              itemBuilder: (context, i) => NotificationTile(state.notifications[i]),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
```

---

## Checklist — before you call a feature done

- [ ] Entity in `features/[feature]/domain/`
- [ ] Model in `features/[feature]/data/` with `fromJson` and `toEntity()`
- [ ] Datasource in `features/[feature]/data/` using `CustomHttpClient`
- [ ] Repository interface in `features/[feature]/domain/`
- [ ] Repository implementation in `features/[feature]/data/` implementing the interface
- [ ] Use case(s) in `features/[feature]/domain/`
- [ ] Bloc in `features/[feature]/presentation/bloc/` — event, state, bloc (3 files)
- [ ] Registered in `injection_container.dart` — datasource → repository → use case → bloc
- [ ] Provided via `BlocProvider` in the screen (factory blocs) or app root (singleton blocs)
- [ ] Screen uses only `Theme.of(context)` tokens — no raw colors, sizes, or font styles

---

## What NOT to do

**Don't put API calls in blocs.** The bloc calls a use case. The use case calls a repository. The repository calls a datasource. That's the chain.

**Don't return models from repositories.** The repository interface is in `domain/`. It knows nothing about JSON. Return entities only.

**Don't share entities and models.** A model has `fromJson`. An entity has neither. Keep them separate even if the fields look identical — they serve different purposes.

**Don't skip the use case because it looks tiny.** The one-liner use case is not overhead — it's the seam where you can add logging, analytics, or validation later without touching the bloc.

**Don't hardcode colors, sizes, or fonts in screens.** Use `Theme.of(context).colorScheme`, `Theme.of(context).textTheme`, and `AppSpacing`. See `docs/design_system_guide.md`.
