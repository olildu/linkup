import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/connections/domain/cache_connections_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';
import '../../../helpers/fixtures.dart';

void main() {
  late MockMatchRepository repository;
  late CacheConnectionsUseCase useCase;

  final chats = [makeChatConnection()];
  setUp(() {
    repository = MockMatchRepository();
    useCase = CacheConnectionsUseCase(repository);
  });

  test('delegates to the repository and returns its result', () async {
    when(() => repository.cacheConnections(chats)).thenAnswer((_) async {});

    await useCase(chats);

    verify(() => repository.cacheConnections(chats)).called(1);
  });

  test('propagates repository errors', () async {
    when(() => repository.cacheConnections(chats)).thenThrow(Exception('boom'));

    expect(() => useCase(chats), throwsException);
  });
}
