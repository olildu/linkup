import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/connections/domain/get_cached_connections_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';
import '../../../helpers/fixtures.dart';

void main() {
  late MockMatchRepository repository;
  late GetCachedConnectionsUseCase useCase;

  final chats = [makeChatConnection()];
  setUp(() {
    repository = MockMatchRepository();
    useCase = GetCachedConnectionsUseCase(repository);
  });

  test('delegates to the repository and returns its result', () async {
    when(() => repository.getCachedConnections()).thenAnswer((_) async => chats);

    expect(await useCase(), chats);

    verify(() => repository.getCachedConnections()).called(1);
  });

  test('propagates repository errors', () async {
    when(() => repository.getCachedConnections()).thenThrow(Exception('boom'));

    expect(() => useCase(), throwsException);
  });
}
