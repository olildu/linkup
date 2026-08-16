import 'package:linkup/features/city_lookup/data/city_lookup_remote_datasource.dart';
import 'package:linkup/features/city_lookup/domain/city_lookup_repository.dart';

class CityLookupRepositoryImpl implements CityLookupRepository {
  final CityLookupRemoteDatasource _datasource;

  const CityLookupRepositoryImpl(this._datasource);

  @override
  Future<List<String>> searchCities(String query) =>
      _datasource.searchCities(query);
}
