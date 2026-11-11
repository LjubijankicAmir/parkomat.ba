import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:parkomat/domain/entities/parking_place.dart';
import 'package:parkomat/domain/entities/zone.dart';
import 'package:parkomat/domain/value_objects/city_camera.dart';

part 'city.freezed.dart';

/// A city's parking: its zones and every garage and lot.
@freezed
abstract class City with _$City {
  const factory City({
    required String id,
    required String name,

    /// Who runs the paid zones, e.g. "KJKP Rad".
    required String operator,
    required CityCamera camera,

    /// Days the zones don't charge, as dates at midnight.
    required Set<DateTime> holidays,
    required List<Zone> zones,
    required List<ParkingPlace> places,

    /// When the data was built.
    required DateTime dataUpdatedAt,
  }) = _City;
}
