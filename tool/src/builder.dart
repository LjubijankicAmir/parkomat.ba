import 'config.dart';
import 'geo.dart';
import 'osm.dart';

/// The app's data format. Bump [formatVersion] on any change the app can't
/// read with its current parser.
const format = 'parkomat.city';
const formatVersion = 1;

/// A street with no `near` anchor that's longer than this isn't drawn: the
/// paid part is probably only a piece of it.
const longStreetM = 800.0;

/// Roughly one storey of a parking garage.
const _storeyM = 3.0;

/// Overpass QL that fetches everything [build] needs for [config].
String overpassQuery(DatasetConfig config) {
  final [minLon, minLat, maxLon, maxLat] = config.city.bbox;
  final bbox = '$minLat,$minLon,$maxLat,$maxLon';
  final names = {
    for (final zone in config.zones)
      for (final stretch in zone.stretches)
        if (stretch.kind == StretchKind.street) stretch.osmName,
  }.map(_regexEscape).join('|');
  final refs = [
    for (final place in config.places)
      '${const {'n': 'node', 'w': 'way', 'r': 'relation'}[place.osm[0]]}(${place.osm.substring(1)});',
  ].join();
  return '''
[out:json][timeout:120];
(
  way["highway"]["name"~"^($names)\$"]($bbox);
  way["man_made"="bridge"]["name"~"^($names)\$"]($bbox);
  nwr["amenity"="parking"]($bbox);
  $refs
);
out tags geom;
''';
}

String _regexEscape(String value) =>
    value.replaceAllMapped(RegExp(r'[.*+?^${}()|[\]\\"]'), (m) => '\\${m[0]}');

class BuildResult {
  const BuildResult({required this.json, required this.report});

  /// The app's asset, ready for `jsonEncode`.
  final Map<String, Object?> json;

  /// Lines worth a person's attention: anything unresolved or unverified.
  final List<String> report;
}

/// Joins the hand-written [config] with OpenStreetMap's [elements] into the
/// app's data.
BuildResult build(
  DatasetConfig config,
  List<OsmElement> elements, {
  required DateTime generatedAt,
  String? osmTimestamp,
}) {
  final report = <String>[];
  final parkingAreas = [
    for (final e in elements)
      if (e.tags['amenity'] == 'parking') e,
  ];
  final byRef = {for (final e in elements) e.ref: e};

  // OSM parking areas that turned out to be zone lots or curated places, so
  // they aren't added a second time.
  final used = <String>{};

  final zones = [
    for (final zone in config.zones)
      _zone(zone, elements, parkingAreas, used, report),
  ];

  final places = <Map<String, Object?>>[];
  for (final place in config.places) {
    final element = byRef[place.osm];
    if (element == null) {
      report.add(
        'Place "${place.name}": ${place.osm} not found in OpenStreetMap; left out.',
      );
      continue;
    }
    used.add(element.ref);
    places.add(_curatedPlace(place, element));
    if (place.verifiedAt == null) {
      report.add('Place "${place.name}": not verified yet.');
    }
    if (place.tariff == null) {
      report.add('Place "${place.name}": no prices yet.');
    }
  }

  var fromOsm = 0;
  for (final element in parkingAreas) {
    if (used.contains(element.ref)) continue;
    final place = _osmPlace(element);
    if (place == null) continue;
    places.add(place);
    fromOsm++;
  }
  report.add('$fromOsm parking places added from OpenStreetMap as they are.');

  return BuildResult(
    json: {
      'format': format,
      'formatVersion': formatVersion,
      'generatedAt': generatedAt.toUtc().toIso8601String(),
      'osmTimestamp': osmTimestamp,
      'city': {
        'id': config.city.id,
        'name': config.city.name,
        'operator': config.city.operator,
        'camera': config.city.camera,
        'holidays': config.city.holidays,
      },
      'zones': zones,
      'places': places,
    },
    report: report,
  );
}

Map<String, Object?> _zone(
  ZoneConfig zone,
  List<OsmElement> elements,
  List<OsmElement> parkingAreas,
  Set<String> used,
  List<String> report,
) {
  final stretches = <Map<String, Object?>>[];
  for (final stretch in zone.stretches) {
    final where = '${zone.name} › ${stretch.name}';
    switch (stretch.kind) {
      case StretchKind.street:
        final lines = _streetLines(stretch, elements, where, report);
        if (lines.isEmpty) continue;
        stretches.add({
          'name': stretch.name,
          'kind': 'street',
          'spaces': stretch.spaces,
          'center': encode(centerOf([for (final line in lines) ...line])),
          'lines': [
            for (final line in lines) [for (final point in line) encode(point)],
          ],
          'area': null,
        });
      case StretchKind.lot:
        final anchor = stretch.near!;
        final at = (lon: anchor.lon, lat: anchor.lat);
        final candidates =
            [
              for (final area in parkingAreas)
                if (!used.contains(area.ref) &&
                    distanceM(area.center, at) <= anchor.radiusM)
                  area,
            ]..sort(
              (a, b) =>
                  distanceM(a.center, at).compareTo(distanceM(b.center, at)),
            );
        final lot = candidates.firstOrNull;
        if (lot == null) {
          report.add(
            '$where: no parking area within ${anchor.radiusM.round()} m of the anchor; shown as a point.',
          );
        } else {
          used.add(lot.ref);
        }
        stretches.add({
          'name': stretch.name,
          'kind': 'lot',
          'spaces': stretch.spaces,
          'center': encode(lot?.center ?? at),
          'lines': const <Object>[],
          'area': lot != null && lot.isClosedWay
              ? [for (final p in lot.geometry) encode(p)]
              : null,
        });
    }
  }
  if (zone.verifiedAt == null) report.add('${zone.name}: not verified yet.');
  if (zone.maxStayMinutes == null) {
    report.add('${zone.name}: maximum stay unknown.');
  }
  return {
    'id': zone.id,
    'number': zone.number,
    'name': zone.name,
    'smsNumber': zone.smsNumber,
    'pricePerHour': zone.pricePerHour,
    'dailyTicket': zone.dailyTicket,
    'maxStayMinutes': zone.maxStayMinutes,
    'paidHours': [for (final range in zone.paidHours) range.toJson()],
    'sources': zone.sources,
    'verifiedAt': zone.verifiedAt,
    'stretches': stretches,
  };
}

List<List<LonLat>> _streetLines(
  StretchConfig stretch,
  List<OsmElement> elements,
  String where,
  List<String> report,
) {
  var ways = [
    for (final e in elements)
      if (e.tags['name'] == stretch.osmName &&
          e.geometry.length >= 2 &&
          (e.tags.containsKey('highway') || e.tags['man_made'] == 'bridge'))
        e,
  ];
  if (ways.isEmpty) {
    report.add(
      '$where: no OpenStreetMap street named "${stretch.osmName}"; not drawn.',
    );
    return const [];
  }
  final anchor = stretch.near;
  if (anchor != null) {
    final at = (lon: anchor.lon, lat: anchor.lat);
    ways = [
      for (final way in ways)
        if (way.geometry.any((p) => distanceM(p, at) <= anchor.radiusM)) way,
    ];
    if (ways.isEmpty) {
      report.add(
        '$where: "${stretch.osmName}" doesn\'t pass within ${anchor.radiusM.round()} m of the anchor; not drawn.',
      );
      return const [];
    }
  } else {
    final length = ways.fold<double>(
      0,
      (sum, way) => sum + lengthM(way.geometry),
    );
    if (length > longStreetM) {
      report.add(
        '$where: ${length.round()} m long with no "near" anchor, so the paid part is unknown; not drawn.',
      );
      return const [];
    }
  }
  return [for (final way in ways) way.geometry];
}

Map<String, Object?> _curatedPlace(PlaceConfig place, OsmElement element) {
  final levels = place.levels ?? _levels(element);
  return {
    'id': 'osm:${element.ref}',
    'name': place.name,
    'type': place.type.name,
    'capacity': place.capacity ?? _int(element.tags['capacity']),
    'levels': levels,
    'heightM': place.type == PlaceType.garage ? _height(element, levels) : null,
    'maxHeightCm': place.maxHeightCm ?? _maxHeightCm(element.tags['maxheight']),
    'customersOnly': place.customersOnly,
    'fee': place.tariff != null ? true : _fee(element.tags['fee']),
    'openingHours': place.openingHours?.map((r) => r.toJson()).toList(),
    'tariff': place.tariff?.toJson(),
    'center': encode(element.center),
    'footprint': element.isClosedWay
        ? [for (final p in element.geometry) encode(p)]
        : null,
    'sources': place.sources,
    'verifiedAt': place.verifiedAt,
    'curated': true,
  };
}

/// A public parking area straight from OpenStreetMap, or `null` when it
/// isn't open to the public.
Map<String, Object?>? _osmPlace(OsmElement element) {
  final tags = element.tags;
  final access = tags['access'];
  if (access == 'private' || access == 'no' || access == 'permit') return null;
  final type = switch (tags['parking']) {
    'multi-storey' => PlaceType.garage,
    'underground' => PlaceType.underground,
    _ => PlaceType.lot,
  };
  final levels = _levels(element);
  return {
    'id': 'osm:${element.ref}',
    'name': tags['name'],
    'type': type.name,
    'capacity': _int(tags['capacity']),
    'levels': levels,
    'heightM': type == PlaceType.garage ? _height(element, levels) : null,
    'maxHeightCm': _maxHeightCm(tags['maxheight']),
    'customersOnly':
        access == 'customers' || (access?.contains('customers') ?? false),
    'fee': _fee(tags['fee']),
    'openingHours': tags['opening_hours'] == '24/7'
        ? [
            const ScheduleRange(
              days: [1, 2, 3, 4, 5, 6, 7],
              from: '00:00',
              to: '24:00',
            ).toJson(),
          ]
        : null,
    'tariff': null,
    'center': encode(element.center),
    'footprint': element.isClosedWay
        ? [for (final p in element.geometry) encode(p)]
        : null,
    'sources': ['https://www.openstreetmap.org/${_osmPath(element.ref)}'],
    'verifiedAt': null,
    'curated': false,
  };
}

String _osmPath(String ref) =>
    '${const {'n': 'node', 'w': 'way', 'r': 'relation'}[ref[0]]}/${ref.substring(1)}';

int? _int(String? value) => value == null ? null : int.tryParse(value.trim());

int? _levels(OsmElement element) =>
    _int(element.tags['building:levels']) ??
    _int(element.tags['parking:levels']);

double _height(OsmElement element, int? levels) {
  final tagged = double.tryParse(
    element.tags['height']?.replaceAll('m', '').trim() ?? '',
  );
  return tagged ?? (levels ?? 3) * _storeyM;
}

bool? _fee(String? value) => switch (value) {
  'yes' => true,
  'no' => false,
  _ => null,
};

/// `maxheight` in centimetres: "2.1", "2.10 m" or "2,1".
int? _maxHeightCm(String? value) {
  if (value == null) return null;
  final metres = double.tryParse(
    value.replaceAll(',', '.').replaceAll('m', '').trim(),
  );
  return metres == null ? null : (metres * 100).round();
}
