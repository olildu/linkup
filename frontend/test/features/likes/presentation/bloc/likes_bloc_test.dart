import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/likes/presentation/bloc/likes_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fake_socket_services.dart';
import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late FakeConnectionsSocketService socket;
  late MockGetReceivedLikesUseCase getReceived;
  late MockGetLikesCountUseCase getCount;
  late MockLikeBackUseCase likeBack;
  late MockPassLikeUseCase passLike;

  setUp(() {
    socket = FakeConnectionsSocketService();
    getReceived = MockGetReceivedLikesUseCase();
    getCount = MockGetLikesCountUseCase();
    likeBack = MockLikeBackUseCase();
    passLike = MockPassLikeUseCase();
  });

  LikesBloc build() => LikesBloc(
        getReceivedLikesUseCase: getReceived,
        getLikesCountUseCase: getCount,
        likeBackUseCase: likeBack,
        passLikeUseCase: passLike,
        connectionsSocket: socket,
      );

  Future<void> pump([int ms = 10]) =>
      Future<void>.delayed(Duration(milliseconds: ms));

  test('LoadLikesCountEvent from initial emits LikesLoaded with count',
      () async {
    when(() => getCount()).thenAnswer((_) async => 7);
    final bloc = build();
    bloc.add(LoadLikesCountEvent());
    await pump();

    final state = bloc.state as LikesLoaded;
    expect(state.totalCount, 7);
    expect(state.entries, isEmpty);
    await bloc.close();
  });

  test('LoadLikesCountEvent on loaded state updates count in place', () async {
    when(() => getReceived(offset: 0)).thenAnswer(
        (_) async => (entries: [makeLikesEntry()], totalCount: 1, unseenCount: 1));
    when(() => getCount()).thenAnswer((_) async => 5);
    final bloc = build();
    bloc.add(LoadReceivedLikesEvent());
    await pump();
    bloc.add(LoadLikesCountEvent());
    await pump();

    final state = bloc.state as LikesLoaded;
    expect(state.totalCount, 5);
    expect(state.entries, hasLength(1));
    await bloc.close();
  });

  test('LoadLikesCountEvent errors are swallowed', () async {
    when(() => getCount()).thenThrow(Exception('boom'));
    final bloc = build();
    bloc.add(LoadLikesCountEvent());
    await pump();
    expect(bloc.state, isA<LikesInitial>());
    await bloc.close();
  });

  test('LoadReceivedLikesEvent loads entries and appends on next page',
      () async {
    when(() => getReceived(offset: 0)).thenAnswer((_) async =>
        (entries: [makeLikesEntry(id: 1)], totalCount: 2, unseenCount: 1));
    when(() => getReceived(offset: 1)).thenAnswer((_) async =>
        (entries: [makeLikesEntry(id: 2)], totalCount: 2, unseenCount: 0));

    final bloc = build();
    bloc.add(LoadReceivedLikesEvent());
    await pump();
    expect((bloc.state as LikesLoaded).entries.map((e) => e.id), [1]);

    bloc.add(LoadReceivedLikesEvent());
    await pump();
    expect((bloc.state as LikesLoaded).entries.map((e) => e.id), [1, 2]);
    await bloc.close();
  });

  test('LoadReceivedLikesEvent failure from initial emits LikesError',
      () async {
    when(() => getReceived(offset: 0)).thenThrow(Exception('boom'));
    final bloc = build();
    bloc.add(LoadReceivedLikesEvent());
    await pump();
    expect(bloc.state, isA<LikesError>());
    await bloc.close();
  });

  test('LoadReceivedLikesEvent failure from loaded clears the loading flag',
      () async {
    when(() => getReceived(offset: 0)).thenAnswer((_) async =>
        (entries: [makeLikesEntry(id: 1)], totalCount: 1, unseenCount: 0));
    final bloc = build();
    bloc.add(LoadReceivedLikesEvent());
    await pump();

    when(() => getReceived(offset: 1)).thenThrow(Exception('boom'));
    bloc.add(LoadReceivedLikesEvent());
    await pump();

    final state = bloc.state as LikesLoaded;
    expect(state.loadingEntries, isFalse);
    expect(state.entries, hasLength(1));
    await bloc.close();
  });

  test('LikeBackEvent with a match sets matchUser and refreshes', () async {
    when(() => getReceived(offset: 0)).thenAnswer((_) async =>
        (entries: [makeLikesEntry(id: 5)], totalCount: 1, unseenCount: 0));
    when(() => likeBack(5)).thenAnswer((_) async => {
          'match': true,
          'matched_user': {
            'id': 5,
            'username': 'alice',
            'profile_picture': {'url': 'a.jpg'},
          },
        });

    final bloc = build();
    bloc.add(LoadReceivedLikesEvent());
    await pump();

    final seen = <LikesState>[];
    bloc.stream.listen(seen.add);
    bloc.add(LikeBackEvent(likerId: 5));
    await pump();

    final matched = seen.whereType<LikesLoaded>().firstWhere(
        (s) => s.matchUser != null);
    expect(matched.matchUser!.username, 'alice');
    await bloc.close();
  });

  test('LikeBackEvent without match just removes the entry', () async {
    when(() => getReceived(offset: 0)).thenAnswer((_) async =>
        (entries: [makeLikesEntry(id: 5)], totalCount: 1, unseenCount: 0));
    when(() => likeBack(5)).thenAnswer((_) async => {'match': false});

    final bloc = build();
    bloc.add(LoadReceivedLikesEvent());
    await pump();
    bloc.add(LikeBackEvent(likerId: 5));
    await pump();

    final state = bloc.state as LikesLoaded;
    expect(state.matchUser, isNull);
    await bloc.close();
  });

  test('LikeBackEvent error is swallowed; ignored when not loaded', () async {
    when(() => likeBack(any())).thenThrow(Exception('boom'));
    final bloc = build();
    bloc.add(LikeBackEvent(likerId: 5)); // not loaded -> early return
    await pump();
    expect(bloc.state, isA<LikesInitial>());
    await bloc.close();
  });

  test('PassLikeEvent removes the entry and refreshes', () async {
    when(() => getReceived(offset: 0)).thenAnswer((_) async =>
        (entries: [makeLikesEntry(id: 5)], totalCount: 1, unseenCount: 0));
    when(() => passLike(5)).thenAnswer((_) async {});

    final bloc = build();
    bloc.add(LoadReceivedLikesEvent());
    await pump();

    final seen = <LikesState>[];
    bloc.stream.listen(seen.add);
    bloc.add(PassLikeEvent(likerId: 5));
    await pump();

    final afterPass = seen.whereType<LikesLoaded>().first;
    expect(afterPass.entries, isEmpty);
    expect(afterPass.totalCount, 0);
    verify(() => passLike(5)).called(1);
    await bloc.close();
  });

  test('PassLikeEvent error is swallowed', () async {
    when(() => getReceived(offset: 0)).thenAnswer((_) async =>
        (entries: [makeLikesEntry(id: 5)], totalCount: 1, unseenCount: 0));
    when(() => passLike(5)).thenThrow(Exception('boom'));

    final bloc = build();
    bloc.add(LoadReceivedLikesEvent());
    await pump();
    bloc.add(PassLikeEvent(likerId: 5));
    await pump();

    expect((bloc.state as LikesLoaded).entries, hasLength(1));
    await bloc.close();
  });

  test('ClearLikesMatchUserEvent clears matchUser', () async {
    when(() => getReceived(offset: 0)).thenAnswer((_) async =>
        (entries: [makeLikesEntry(id: 5)], totalCount: 1, unseenCount: 0));
    when(() => likeBack(5)).thenAnswer((_) async => {
          'match': true,
          'matched_user': {
            'id': 5,
            'username': 'alice',
            'profile_picture': {'url': 'a.jpg'},
          },
        });

    final bloc = build();
    bloc.add(LoadReceivedLikesEvent());
    await pump();
    bloc.add(LikeBackEvent(likerId: 5));
    await pump();
    bloc.add(ClearLikesMatchUserEvent());
    await pump();

    expect((bloc.state as LikesLoaded).matchUser, isNull);
    await bloc.close();
  });

  test('connections-reload/like socket message triggers a count reload',
      () async {
    when(() => getCount()).thenAnswer((_) async => 3);
    final bloc = build();
    bloc.add(LoadLikesCountEvent()); // initialises the socket listener
    await pump();

    when(() => getCount()).thenAnswer((_) async => 4);
    socket.emitMessage({'type': 'connections-reload', 'sub_type': 'like'});
    await pump();

    expect((bloc.state as LikesLoaded).totalCount, 4);
    await bloc.close();
  });
}
