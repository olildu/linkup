// Local replacement for package:bloc_test, which cannot be added because
// isar_generator pins analyzer <6.0.0 and that conflicts with every
// bloc_test-compatible version of package:test on this Flutter SDK.
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';
import 'package:mocktail/mocktail.dart';

/// Stubs a mocktail-mocked bloc/cubit (declared as
/// `class MockXBloc extends Mock implements XBloc {}`) so that widgets can
/// read `state`, subscribe to `stream`, and `close()` it. The tracked state
/// updates as the given stream emits, mirroring bloc_test's `whenListen`.
void whenListen<State>(
  BlocBase<State> bloc,
  Stream<State> stream, {
  required State initialState,
}) {
  final broadcast = stream.asBroadcastStream();
  State current = initialState;
  broadcast.listen((s) => current = s);
  when(() => bloc.state).thenAnswer((_) => current);
  when(() => bloc.stream).thenAnswer((_) => broadcast);
  when(() => bloc.close()).thenAnswer((_) async {});
}

/// Minimal stand-in for bloc_test's `blocTest`: builds the bloc, records every
/// emitted state, runs [act], waits for [wait] (plus a microtask flush),
/// asserts the emissions against [expect] (values or matchers), then runs
/// [verify] and closes the bloc.
@isTest
void testBloc<B extends BlocBase<State>, State>(
  String description, {
  required B Function() build,
  FutureOr<void> Function(B bloc)? act,
  Duration? wait,
  List<Object?> Function()? expect,
  FutureOr<void> Function(B bloc)? verify,
  Object Function()? errors,
}) {
  test(description, () async {
    final bloc = build();
    final states = <State>[];
    Object? thrown;
    final sub = bloc.stream.listen(states.add);
    try {
      await act?.call(bloc);
    } catch (e) {
      thrown = e;
    }
    if (wait != null) await Future<void>.delayed(wait);
    // Flush pending microtasks/stream events.
    await Future<void>.delayed(Duration.zero);
    if (errors != null) {
      expectLater(thrown, errors());
    } else if (thrown != null) {
      throw thrown; // ignore: only_throw_errors
    }
    if (expect != null) {
      check(states, orderedEquals(expect()));
    }
    await verify?.call(bloc);
    await sub.cancel();
    await bloc.close();
  });
}

// `expect` is shadowed by the named parameter inside testBloc's closure.
void check(dynamic actual, dynamic matcher) => expect(actual, matcher);
