import 'package:freezed_annotation/freezed_annotation.dart';

part 'geo_point.freezed.dart';

/// A position on the map, in degrees.
@freezed
abstract class GeoPoint with _$GeoPoint {
  const factory GeoPoint({required double lat, required double lon}) =
      _GeoPoint;
}
