import 'package:flutter_test/flutter_test.dart';

import '../../tool/src/config.dart';

const _city = '''
id: testcity
name: Test City
operator: Test Operator
bbox: [18.0, 43.0, 18.1, 43.1]
camera: { lat: 43.05, lon: 18.05, zoom: 16, pitch: 56, bearing: -24 }
holidays:
  source: https://example.com/holidays
  verifiedAt: null
  dates: [2026-01-01]
''';

const _zones = '''
zones:
  - id: test-1
    number: 1
    name: Zona I
    sms: { number: "0832001" }
    pricePerHour: 3.00
    dailyTicket: 30.00
    paidHours:
      - { days: [mon, tue, wed, thu, fri, sat], from: "07:00", to: "22:00" }
    maxStayMinutes: null
    sources: [https://example.com/zones]
    verifiedAt: 2026-11-11
    stretches:
      - { name: Kaptol, spaces: 10 }
      - name: Stanica
        kind: lot
        near: { lat: 43.05, lon: 18.05, radius: 200 }
''';

const _places = '''
places:
  - osm: w1
    name: Garaža
    type: garage
    capacity: 100
    levels: 3
    maxHeightCm: 210
    customersOnly: false
    openingHours: null
    tariff:
      freeMinutes: 15
      dailyTicket: 30
      rates:
        - { days: [mon], from: "22:00", to: "08:00", perHour: 1.00 }
    sources: []
    verifiedAt: null
''';

DatasetConfig _parse({
  String city = _city,
  String zones = _zones,
  String places = _places,
}) => DatasetConfig.parse(cityYaml: city, zonesYaml: zones, placesYaml: places);

Matcher _problem(String text) => isA<DatasetException>().having(
  (e) => e.problems.join('\n'),
  'problems',
  contains(text),
);

void main() {
  test('reads a valid dataset', () {
    final config = _parse();

    expect(config.city.id, 'testcity');
    expect(config.city.holidays, ['2026-01-01']);
    final zone = config.zones.single;
    expect(zone.pricePerHour, 300);
    expect(zone.dailyTicket, 3000);
    expect(zone.paidHours.single.days, [1, 2, 3, 4, 5, 6]);
    expect(zone.verifiedAt, '2026-11-11');
    expect(zone.stretches.first.osmName, 'Kaptol');
    expect(zone.stretches.last.kind, StretchKind.lot);
    final place = config.places.single;
    expect(place.type, PlaceType.garage);
    expect(place.tariff!.rates.single.perHour, 100);
    expect(place.tariff!.rates.single.window.to, '08:00');
  });

  test('rejects an SMS number that is not 7 digits', () {
    expect(
      () => _parse(zones: _zones.replaceFirst('"0832001"', '"083 20 01"')),
      throwsA(_problem('"number" must be 7 digits')),
    );
  });

  test('rejects unknown weekdays and malformed times', () {
    expect(
      () => _parse(zones: _zones.replaceFirst('days: [mon,', 'days: [monday,')),
      throwsA(_problem('"days" must list some of')),
    );
    expect(
      () => _parse(zones: _zones.replaceFirst('from: "07:00"', 'from: "7"')),
      throwsA(_problem('"from" must be a time')),
    );
  });

  test('rejects a lot without a near anchor', () {
    final zones = _zones.replaceFirst(
      '        near: { lat: 43.05, lon: 18.05, radius: 200 }\n',
      '',
    );
    expect(() => _parse(zones: zones), throwsA(_problem('a lot needs "near"')));
  });

  test('rejects zones without sources', () {
    expect(
      () => _parse(
        zones: _zones.replaceFirst(
          'sources: [https://example.com/zones]',
          'sources: []',
        ),
      ),
      throwsA(_problem('"sources" must name where the values come from')),
    );
  });

  test('rejects bad place references and types', () {
    expect(
      () => _parse(places: _places.replaceFirst('osm: w1', 'osm: way1')),
      throwsA(_problem('"osm" must look like n123')),
    );
    expect(
      () => _parse(places: _places.replaceFirst('type: garage', 'type: tent')),
      throwsA(_problem('"type" must be garage, underground or lot')),
    );
  });

  test('rejects duplicate zone ids', () {
    final second = _zones.replaceFirst('zones:\n', '');
    expect(
      () => _parse(zones: '$_zones$second'),
      throwsA(_problem('Duplicate zone id: test-1')),
    );
  });

  test('reports every problem at once', () {
    final zones = _zones
        .replaceFirst('"0832001"', '"1"')
        .replaceFirst('pricePerHour: 3.00', 'pricePerHour: -1');
    expect(
      () => _parse(zones: zones),
      throwsA(
        isA<DatasetException>().having(
          (e) => e.problems,
          'problems',
          hasLength(2),
        ),
      ),
    );
  });

  test('reports YAML that does not parse', () {
    expect(
      () => _parse(zones: 'zones: [unclosed'),
      throwsA(_problem('zones.yaml: not valid YAML')),
    );
  });
}
