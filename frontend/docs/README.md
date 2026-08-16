# Linkup Frontend — Documentation Index

> Start here. Every doc is linked below with a one-line summary.

---

## New to the codebase?

Read in this order:

1. [Architecture Overview](architecture_overview.md) — the 4-layer structure and how data flows
2. [Feature Development Guide](feature_development_guide.md) — step-by-step: API → entity → use case → bloc → widget
3. [State Management Guide](state_management_guide.md) — BLoC/Cubit patterns, when to use each
4. [Design System Guide](design_system_guide.md) — colors, typography, spacing — the rules for all UI code

---

## Reference docs

| Doc | What it covers |
|---|---|
| [Architecture Overview](architecture_overview.md) | The 4 layers (data/domain/logic/presentation), what lives where, dependency rules |
| [Feature Development Guide](feature_development_guide.md) | End-to-end walkthrough with a worked example — the canonical "how to add a feature" |
| [State Management Guide](state_management_guide.md) | BLoC vs Cubit, singleton vs factory, BlocBuilder/Listener/Consumer patterns |
| [Dependency Injection Guide](dependency_injection_guide.md) | GetIt, `sl<T>()`, registration types, how to add a new dependency |
| [WebSocket Guide](websocket_guide.md) | The 3 socket services (chat, connections, lobby), BaseSocketService, unsent message queue |
| [Local Persistence Guide](local_persistence_guide.md) | Isar (messages/chats), SharedPreferences (theme, app lock), FlutterSecureStorage (tokens) |
| [Navigation Guide](navigation_guide.md) | Navigator patterns, CupertinoPageRoute, bottom sheets, post-login routing |
| [Design System Guide](design_system_guide.md) | Colors, typography, spacing, radius — full rules + before/after examples |

---

## Design system migration history

| Doc | What it covers |
|---|---|
| [Design System Migration](design_system_migration.md) | Context, patterns, and before/after examples from the migration |
| [Design System Tasks](design_system_tasks.md) | The task checklist — all phases, what was done and what's left |
