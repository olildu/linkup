import 'package:linkup/data/datasources/remote/city_lookup_remote_datasource.dart';
import 'package:linkup/domain/repositories/city_lookup_repository.dart';

class CityLookupRepositoryImpl implements CityLookupRepository {
  final CityLookupRemoteDatasource _datasource;

  const CityLookupRepositoryImpl(this._datasource);

  @override
  Future<List<String>> searchCities(String query) =>
      _datasource.searchCities(query);
}
