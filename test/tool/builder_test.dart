import 'package:flutter_test/flutter_test.dart';

import '../../tool/src/builder.dart';
import '../../tool/src/config.dart';
import '../../tool/src/osm.dart';

const _city = '''
id: testcity
name: Test City
operator: Test Operator
bbox: [18.0, 43.0, 18.1, 43.1]
camera: { lat: 43.05, lon: 18.05, zoom: 16, pitch: 56, bearing: -24 }
holidays: { source: https://example.com, verifiedAt: null, dates: [] }
''';

DatasetConfig _config(String stretches, {String places = 'places: []'}) {
  return DatasetConfig.parse(
    cityYaml: _city,
    zonesYaml:
        '''
zones:
  - id: test-1
    number: 1
    name: Zona I
    sms: { number: "0832001" }
    pricePerHour: 3
    paidHours: [{ days: [mon], from: "07:00", to: "22:00" }]
    sources: [https://example.com]
    stretches:
$stretches
''',
    placesYaml: places,
  );
}

/// A way along latitude 43.05 from [fromLon] to [toLon].
OsmElement _street(int id, String name, double fromLon, double toLon) {
  return OsmElement.fromJson({
    'type': 'way',
    'id': id,
    'tags': {'highway': 'residential', 'name': name},
    'geometry': [
      {'lat': 43.05, 'lon': fromLon},
      {'lat': 43.05, 'lon': toLon},
    ],
  });
}

OsmElement _parkingNode(
  int id,
  double lat,
  double lon,
  Map<String, String> tags,
) {
  return OsmElement.fromJson({
    'type': 'node',
    'id': id,
    'lat': lat,
    'lon': lon,
    'tags': {'amenity': 'parking', ...tags},
  });
}

BuildResult _build(DatasetConfig config, List<OsmElement> elements) =>
    build(config, elements, generatedAt: DateTime.utc(2026, 11, 11));

List<Map<String, Object?>> _stretches(BuildResult result) =>
    ((result.json['zones']! as List).single as Map)['stretches']
        as List<Map<String, Object?>>;

List<Map<String, Object?>> _places(BuildResult result) =>
    (result.json['places']! as List).cast<Map<String, Object?>>();

void main() {
  test('draws a short street from every way with its name', () {
    final result = _build(_config('      - { name: Kaptol, spaces: 10 }'), [
      _street(1, 'Kaptol', 18.050, 18.052),
      _street(2, 'Kaptol', 18.052, 18.054),
    ]);

    final stretch = _stretches(result).single;
    expect(stretch['kind'], 'street');
    expect(stretch['spaces'], 10);
    expect(stretch['lines'], hasLength(2));
  });

  test('skips a long street without an anchor and reports it', () {
    // About 1.6 km.
    final result = _build(_config('      - { name: Dugačka }'), [
      _street(1, 'Dugačka', 18, 18.02),
    ]);

    expect(_stretches(result), isEmpty);
    expect(result.report.join('\n'), contains('Dugačka: 1625 m long'));
  });

  test('keeps only the ways near an anchor', () {
    final result = _build(
      _config('''
      - name: Obala (Vijećnica)
        osmName: Obala
        near: { lat: 43.05, lon: 18.05, radius: 100 }'''),
      [_street(1, 'Obala', 18, 18.010), _street(2, 'Obala', 18.0495, 18.0505)],
    );

    final lines = _stretches(result).single['lines']! as List;
    expect(lines, hasLength(1));
    expect((lines.single as List).first, [18.0495, 43.05]);
  });

  test('reports a street name OpenStreetMap does not have', () {
    final result = _build(_config('      - { name: Nepostojeća }'), const []);

    expect(_stretches(result), isEmpty);
    expect(
      result.report.join('\n'),
      contains('no OpenStreetMap street named "Nepostojeća"'),
    );
  });

  test(
    'matches a zone lot to the closest parking area and does not add it twice',
    () {
      final result = _build(
        _config('''
      - name: Rampa
        kind: lot
        spaces: 48
        near: { lat: 43.05, lon: 18.05, radius: 300 }'''),
        [
          _parkingNode(1, 43.0505, 18.05, {}),
          _parkingNode(2, 43.0510, 18.05, {}),
        ],
      );

      final lot = _stretches(result).single;
      expect(lot['kind'], 'lot');
      expect(lot['center'], [18.05, 43.0505]);
      // The matched area is the zone lot; only the other one is a place.
      expect(_places(result).map((p) => p['id']), ['osm:n2']);
    },
  );

  test('leaves out private parking and keeps customer parking marked', () {
    final result = _build(_config('      - { name: Kaptol }'), [
      _parkingNode(1, 43.05, 18.05, {'access': 'private'}),
      _parkingNode(2, 43.05, 18.05, {
        'access': 'customers',
        'parking': 'multi-storey',
        'building:levels': '4',
      }),
    ]);

    final place = _places(result).single;
    expect(place['id'], 'osm:n2');
    expect(place['type'], 'garage');
    expect(place['customersOnly'], true);
    expect(place['heightM'], 12.0);
  });

  test('curated values win over OpenStreetMap tags', () {
    final result = _build(
      _config(
        '      - { name: Kaptol }',
        places: '''
places:
  - osm: n7
    name: Garaža Vijećnica
    type: underground
    capacity: 155
    levels: null
    maxHeightCm: 210
    customersOnly: false
    openingHours: null
    tariff: null
    sources: [https://example.com]
    verifiedAt: null
''',
      ),
      [
        _parkingNode(7, 43.05, 18.05, {'capacity': '100', 'maxheight': '1.9'}),
      ],
    );

    final place = _places(result).single;
    expect(place['name'], 'Garaža Vijećnica');
    expect(place['capacity'], 155);
    expect(place['maxHeightCm'], 210);
    expect(place['curated'], true);
    expect(result.report, contains('Place "Garaža Vijećnica": no prices yet.'));
  });

  test('builds the query from the zone streets and curated places', () {
    final query = overpassQuery(
      _config(
        '      - { name: Valtera Perića, osmName: Vladimira Valtera Perića }',
        places: '''
places:
  - osm: w9
    name: X
    type: lot
    customersOnly: false
    sources: []
''',
      ),
    );

    expect(query, contains(r'"^(Vladimira Valtera Perića)$"'));
    expect(query, contains('way(9);'));
    expect(query, contains('(43.0,18.0,43.1,18.1)'));
  });
}
