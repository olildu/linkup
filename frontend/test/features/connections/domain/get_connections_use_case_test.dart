import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/connections/domain/get_connections_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';
import '../../../helpers/fixtures.dart';

void main() {
  late MockMatchRepository repository;
  late GetConnectionsUseCase useCase;

  final result = (matches: [makeMatchesConnection()], chats: [makeChatConnection()]);
  setUp(() {
    repository = MockMatchRepository();
    useCase = GetConnectionsUseCase(repository);
  });

  test('delegates to the repository and returns its result', () async {
    when(() => repository.getConnections()).thenAnswer((_) async => result);

    expect(await useCase(), result);

    verify(() => repository.getConnections()).called(1);
  });

  test('propagates repository errors', () async {
    when(() => repository.getConnections()).thenThrow(Exception('boom'));

    expect(() => useCase(), throwsException);
  });
}
