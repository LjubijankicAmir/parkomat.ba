import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:parkomat/domain/value_objects/geo_point.dart';
import 'package:parkomat/domain/value_objects/stretch_kind.dart';

part 'zone_stretch.freezed.dart';

/// One entry of a zone's official list: a street, part of one, or a lot.
@freezed
abstract class ZoneStretch with _$ZoneStretch {
  const factory ZoneStretch({
    /// As in the official list, e.g. "Obala Kulina bana (Vijećnica)".
    required String name,
    required StretchKind kind,
    required GeoPoint center,

    /// The street's lines; empty for a lot.
    required List<List<GeoPoint>> lines,

    /// A lot's outline, when known.
    List<GeoPoint>? area,
    int? spaces,
  }) = _ZoneStretch;
}
