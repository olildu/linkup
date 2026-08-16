import 'package:linkup/domain/repositories/city_lookup_repository.dart';

class SearchCitiesUseCase {
  final CityLookupRepository _repository;
  const SearchCitiesUseCase(this._repository);

  Future<List<String>> call(String query) => _repository.searchCities(query);
}
