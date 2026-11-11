import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:parkomat/domain/value_objects/geo_point.dart';
import 'package:parkomat/domain/value_objects/height_limit.dart';
import 'package:parkomat/domain/value_objects/parking_type.dart';
import 'package:parkomat/domain/value_objects/provenance.dart';
import 'package:parkomat/domain/value_objects/schedule_range.dart';
import 'package:parkomat/domain/value_objects/tariff.dart';

part 'parking_place.freezed.dart';

/// A garage or lot. Unknown details stay `null`, so the app can say it
/// doesn't know rather than guess.
@freezed
abstract class ParkingPlace with _$ParkingPlace {
  const factory ParkingPlace({
    required String id,

    /// [ParkingType.garage], [ParkingType.underground] or [ParkingType.lot].
    required ParkingType type,
    required GeoPoint center,
    required Provenance provenance,
    String? name,
    int? capacity,

    /// Storeys, above or below ground.
    int? levels,

    /// How tall a garage is drawn in 3D.
    double? heightMetres,
    HeightLimit? maxHeight,

    /// Only for the customers of a shop or business.
    @Default(false) bool customersOnly,

    /// Whether parking costs money, when known without a [tariff].
    bool? fee,

    /// When it's open; `null` when unknown.
    List<ScheduleRange>? openingHours,
    Tariff? tariff,

    /// The outline on the map, when known.
    List<GeoPoint>? footprint,

    /// Details were added by hand, not only taken from OpenStreetMap.
    @Default(false) bool curated,
  }) = _ParkingPlace;
}
