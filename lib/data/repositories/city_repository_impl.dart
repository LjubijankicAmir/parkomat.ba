import 'package:injectable/injectable.dart';
import 'package:parkomat/core/error/failure.dart';
import 'package:parkomat/core/error/result.dart';
import 'package:parkomat/data/datasources/asset/city_asset_source.dart';
import 'package:parkomat/data/mappers/city_mapper.dart';
import 'package:parkomat/data/repositories/guarded.dart';
import 'package:parkomat/domain/entities/city.dart';
import 'package:parkomat/domain/repositories/city_repository.dart';

@LazySingleton(as: CityRepository)
class CityRepositoryImpl implements CityRepository {
  CityRepositoryImpl(this._assets);

  final CityAssetSource _assets;

  @override
  FutureResult<City> load(String cityId) {
    return guardFuture(
      () async => (await _assets.read(cityId)).toEntity(),
      toFailure: (error) => Failure.data('$error'),
    );
  }
}
