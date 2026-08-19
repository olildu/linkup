import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/city_lookup/data/city_lookup_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

void main() {
  test('searchCities delegates to the datasource', () async {
    final ds = MockCityLookupRemoteDatasource();
    final repo = CityLookupRepositoryImpl(ds);
    when(() => ds.searchCities('del')).thenAnswer((_) async => ['Delhi']);
    expect(await repo.searchCities('del'), ['Delhi']);
  });
}
