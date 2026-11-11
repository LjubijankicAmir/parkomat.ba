import 'geo.dart';

/// A node, way or relation from an Overpass response (`out tags geom`).
class OsmElement {
  const OsmElement({
    required this.ref,
    required this.tags,
    required this.center,
    this.geometry = const [],
  });

  factory OsmElement.fromJson(Map<String, Object?> json) {
    final type = json['type']! as String;
    final tags = (json['tags'] as Map<String, Object?>? ?? const {}).map(
      (key, value) => MapEntry(key, '$value'),
    );
    final geometry = [
      for (final point in json['geometry'] as List<Object?>? ?? const [])
        if (point is Map<String, Object?>)
          (
            lon: (point['lon']! as num).toDouble(),
            lat: (point['lat']! as num).toDouble(),
          ),
    ];
    final LonLat center;
    if (json['lat'] case final num lat) {
      center = (lon: (json['lon']! as num).toDouble(), lat: lat.toDouble());
    } else if (geometry.isNotEmpty) {
      center = centerOf(geometry);
    } else if (json['bounds'] case final Map<String, Object?> b) {
      // Relations come with their bounds rather than one line of points.
      center = (
        lon: ((b['minlon']! as num) + (b['maxlon']! as num)) / 2,
        lat: ((b['minlat']! as num) + (b['maxlat']! as num)) / 2,
      );
    } else {
      throw FormatException('${json['type']} ${json['id']} has no position');
    }
    return OsmElement(
      ref: '${type[0]}${json['id']}',
      tags: tags,
      center: center,
      geometry: geometry,
    );
  }

  /// `n123`, `w123` or `r123`.
  final String ref;
  final Map<String, String> tags;
  final LonLat center;

  /// The way's points; empty for nodes and relations.
  final List<LonLat> geometry;

  bool get isClosedWay =>
      geometry.length >= 4 && geometry.first == geometry.last;
}
