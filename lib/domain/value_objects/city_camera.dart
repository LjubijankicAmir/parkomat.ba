import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:parkomat/domain/value_objects/geo_point.dart';

part 'city_camera.freezed.dart';

/// Where the map starts for a city.
@freezed
abstract class CityCamera with _$CityCamera {
  const factory CityCamera({
    required GeoPoint center,
    required double zoom,

    /// Tilt in degrees; 0 looks straight down.
    required double pitch,

    /// Rotation in degrees from north.
    required double bearing,
  }) = _CityCamera;
}
