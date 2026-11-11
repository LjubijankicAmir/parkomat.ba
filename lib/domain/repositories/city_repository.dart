import 'package:parkomat/core/error/result.dart';
import 'package:parkomat/domain/entities/city.dart';

abstract interface class CityRepository {
  /// The parking data for the city with [cityId], e.g. "sarajevo".
  FutureResult<City> load(String cityId);
}
