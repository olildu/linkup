import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/city_lookup/domain/search_cities_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

void main() {
  late MockCityLookupRepository repository;
  late SearchCitiesUseCase useCase;

  setUp(() {
    repository = MockCityLookupRepository();
    useCase = SearchCitiesUseCase(repository);
  });

  test('delegates to the repository and returns its result', () async {
    when(() => repository.searchCities('del')).thenAnswer((_) async => ['Delhi']);

    expect(await useCase('del'), ['Delhi']);

    verify(() => repository.searchCities('del')).called(1);
  });

  test('propagates repository errors', () async {
    when(() => repository.searchCities('del')).thenThrow(Exception('boom'));

    expect(() => useCase('del'), throwsException);
  });
}
