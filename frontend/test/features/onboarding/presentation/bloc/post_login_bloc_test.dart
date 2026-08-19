import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/connections/presentation/bloc/connections_bloc.dart';
import 'package:linkup/features/connections/presentation/bloc/connections_socket_bloc.dart';
import 'package:linkup/features/discovery/presentation/bloc/matches_bloc.dart';
import 'package:linkup/features/likes/presentation/bloc/likes_bloc.dart';
import 'package:linkup/features/messaging/presentation/bloc/chat_sockets_bloc.dart';
import 'package:linkup/features/messaging/presentation/bloc/web_socket_bloc.dart';
import 'package:linkup/features/onboarding/presentation/bloc/post_login_bloc.dart';
import 'package:linkup/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:linkup/features/discovery/domain/match_candidate_entity.dart';
import 'package:linkup/features/connections/domain/chat_connection_entity.dart';
import 'package:linkup/core/entities/matches_connection_entity.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fake_socket_services.dart';
import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockGetProfileUseCase getProfile;
  late MockLoadMatchesUseCase loadMatches;
  late MockGetConnectionsUseCase getConnections;
  late MockGetLikesCountUseCase getLikesCount;

  late ProfileBloc profileBloc;
  late MatchesBloc matchesBloc;
  late WebSocketBloc webSocketBloc;
  late ChatSocketsBloc chatSocketsBloc;
  late ConnectionsSocketBloc connectionsSocketBloc;
  late ConnectionsBloc connectionsBloc;
  late LikesBloc likesBloc;

  setUp(() {
    getProfile = MockGetProfileUseCase();
    loadMatches = MockLoadMatchesUseCase();
    getConnections = MockGetConnectionsUseCase();
    getLikesCount = MockGetLikesCountUseCase();

    profileBloc = ProfileBloc(
      getProfileUseCase: getProfile,
      updateProfileUseCase: MockUpdateProfileUseCase(),
      uploadUserMediaUseCase: MockUploadUserMediaUseCase(),
      uploadPfpFromUrlUseCase: MockUploadPfpFromUrlUseCase(),
    );
    matchesBloc = MatchesBloc(
      loadMatchesUseCase: loadMatches,
      swipeUseCase: MockSwipeUseCase(),
    );
    webSocketBloc = WebSocketBloc();
    final getUnsent = MockGetUnsentMessagesUseCase();
    when(() => getUnsent()).thenAnswer((_) async => []);
    chatSocketsBloc = ChatSocketsBloc(
      getUnsentMessagesUseCase: getUnsent,
      deleteUnsentByMessageIdUseCase: MockDeleteUnsentByMessageIdUseCase(),
      chatSocket: FakeChatSocketServices(),
    );
    connectionsSocketBloc = ConnectionsSocketBloc(
        connectionsSocket: FakeConnectionsSocketService());
    final cacheConnections = MockCacheConnectionsUseCase();
    when(() => cacheConnections(any())).thenAnswer((_) async {});
    connectionsBloc = ConnectionsBloc(
      getConnectionsUseCase: getConnections,
      cacheConnectionsUseCase: cacheConnections,
      getCachedConnectionsUseCase: MockGetCachedConnectionsUseCase(),
      blockUserUseCase: MockBlockUserUseCase(),
      reportUserUseCase: MockReportUserUseCase(),
      chatSocket: FakeChatSocketServices(),
      connectionsSocket: FakeConnectionsSocketService(),
      resolveCurrentUserId: () => 1,
    );
    likesBloc = LikesBloc(
      getReceivedLikesUseCase: MockGetReceivedLikesUseCase(),
      getLikesCountUseCase: getLikesCount,
      likeBackUseCase: MockLikeBackUseCase(),
      passLikeUseCase: MockPassLikeUseCase(),
      connectionsSocket: FakeConnectionsSocketService(),
    );
  });

  PostLoginBloc build() => PostLoginBloc(
        matchesBloc: matchesBloc,
        webSocketBloc: webSocketBloc,
        chatSocketsBloc: chatSocketsBloc,
        connectionsSocketBloc: connectionsSocketBloc,
        profileBloc: profileBloc,
        connectionsBloc: connectionsBloc,
        likesBloc: likesBloc,
      );

  Future<void> closeAll(PostLoginBloc bloc) async {
    await bloc.close();
    await profileBloc.close();
    await matchesBloc.close();
    await webSocketBloc.close();
    await chatSocketsBloc.close();
    await connectionsSocketBloc.close();
    await connectionsBloc.close();
    await likesBloc.close();
  }

  test('incomplete profile short-circuits to the signup page', () async {
    when(() => getProfile())
        .thenAnswer((_) async => makeUser(universityId: -1));
    final bloc = build();
    bloc.add(StartPostLoginEvent());
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(bloc.state, isA<PostLoginLoaded>());
    expect((bloc.state as PostLoginLoaded).goToSignUpPage, isTrue);
    await closeAll(bloc);
  });

  test('complete profile kicks off all loads and waits for them', () async {
    when(() => getProfile()).thenAnswer((_) async => makeUser());
    when(() => loadMatches(refresh: false)).thenAnswer(
        (_) async => (matches: [makeCandidate()], swipesRemaining: 5));
    when(() => getConnections()).thenAnswer((_) async => (
          matches: <MatchesConnectionEntity>[],
          chats: <ChatConnectionEntity>[],
        ));
    when(() => getLikesCount()).thenAnswer((_) async => 0);

    final bloc = build();
    bloc.add(StartPostLoginEvent());
    await Future<void>.delayed(const Duration(milliseconds: 100));

    expect(bloc.state, isA<PostLoginLoaded>());
    expect((bloc.state as PostLoginLoaded).goToSignUpPage, isFalse);
    await closeAll(bloc);
  });

  test('profile load failure emits PostLoginError', () async {
    when(() => getProfile()).thenThrow(Exception('down'));
    final bloc = build();
    bloc.add(StartPostLoginEvent());
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(bloc.state, isA<PostLoginError>());
    await closeAll(bloc);
  });
}
