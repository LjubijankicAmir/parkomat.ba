import 'dart:convert';

import 'package:yaml/yaml.dart';

/// One city's hand-written dataset: `city.yaml`, `zones.yaml` and
/// `places.yaml`.
class DatasetConfig {
  const DatasetConfig({
    required this.city,
    required this.zones,
    required this.places,
  });

  /// Reads the three files' contents. Throws a [DatasetException] that lists
  /// every problem found, not just the first.
  factory DatasetConfig.parse({
    required String cityYaml,
    required String zonesYaml,
    required String placesYaml,
  }) {
    final problems = <String>[];
    final reader = _Reader(problems);

    final city = reader.city(_load(cityYaml, 'city.yaml', problems));
    final zonesRoot = _load(zonesYaml, 'zones.yaml', problems);
    final zones = [
      for (final (i, zone)
          in reader.list(zonesRoot, 'zones', 'zones.yaml').indexed)
        reader.zone(zone, 'zones.yaml › zones[$i]'),
    ];
    final placesRoot = _load(placesYaml, 'places.yaml', problems);
    final places = [
      for (final (i, place)
          in reader.list(placesRoot, 'places', 'places.yaml').indexed)
        reader.place(place, 'places.yaml › places[$i]'),
    ];

    _checkUnique(problems, 'zone id', zones.map((z) => z?.id));
    _checkUnique(problems, 'zone number', zones.map((z) => z?.number));
    _checkUnique(problems, 'place osm ref', places.map((p) => p?.osm));

    if (problems.isNotEmpty || city == null) {
      throw DatasetException(problems);
    }
    return DatasetConfig(
      city: city,
      zones: zones.nonNulls.toList(),
      places: places.nonNulls.toList(),
    );
  }

  final CityConfig city;
  final List<ZoneConfig> zones;
  final List<PlaceConfig> places;
}

class DatasetException implements Exception {
  const DatasetException(this.problems);

  final List<String> problems;

  @override
  String toString() => 'The dataset has problems:\n- ${problems.join('\n- ')}';
}

class CityConfig {
  const CityConfig({
    required this.id,
    required this.name,
    required this.operator,
    required this.bbox,
    required this.camera,
    required this.holidays,
    required this.holidaysSource,
    required this.holidaysVerifiedAt,
  });

  final String id;
  final String name;
  final String operator;

  /// minLon, minLat, maxLon, maxLat.
  final List<double> bbox;
  final Map<String, num> camera;

  /// `yyyy-mm-dd`.
  final List<String> holidays;
  final String holidaysSource;
  final String? holidaysVerifiedAt;
}

/// When something applies: a set of weekdays and a time window. A window
/// whose end is before its start runs past midnight.
class ScheduleRange {
  const ScheduleRange({
    required this.days,
    required this.from,
    required this.to,
  });

  /// 1 = Monday … 7 = Sunday, as in `DateTime.weekday`.
  final List<int> days;

  /// `HH:MM`; [to] may be `24:00`.
  final String from;
  final String to;

  Map<String, Object?> toJson() => {'days': days, 'from': from, 'to': to};
}

class ZoneConfig {
  const ZoneConfig({
    required this.id,
    required this.number,
    required this.name,
    required this.smsNumber,
    required this.pricePerHour,
    required this.dailyTicket,
    required this.paidHours,
    required this.maxStayMinutes,
    required this.sources,
    required this.verifiedAt,
    required this.stretches,
  });

  final String id;
  final int number;
  final String name;
  final String smsNumber;

  /// In fenings (1 KM = 100).
  final int pricePerHour;
  final int? dailyTicket;
  final List<ScheduleRange> paidHours;
  final int? maxStayMinutes;
  final List<String> sources;
  final String? verifiedAt;
  final List<StretchConfig> stretches;
}

enum StretchKind { street, lot }

class StretchConfig {
  const StretchConfig({
    required this.name,
    required this.osmName,
    required this.kind,
    required this.spaces,
    required this.near,
  });

  /// As in the official list.
  final String name;

  /// The street's name in OpenStreetMap, when it differs from [name].
  final String osmName;
  final StretchKind kind;
  final int? spaces;
  final Anchor? near;
}

/// A point and a radius that pick the part of a street, or the lot, that a
/// stretch means.
class Anchor {
  const Anchor({required this.lat, required this.lon, required this.radiusM});

  final double lat;
  final double lon;
  final double radiusM;
}

enum PlaceType { garage, underground, lot }

class PlaceConfig {
  const PlaceConfig({
    required this.osm,
    required this.name,
    required this.type,
    required this.capacity,
    required this.levels,
    required this.maxHeightCm,
    required this.customersOnly,
    required this.openingHours,
    required this.tariff,
    required this.sources,
    required this.verifiedAt,
  });

  /// `n123`, `w123` or `r123`.
  final String osm;
  final String name;
  final PlaceType type;
  final int? capacity;
  final int? levels;
  final int? maxHeightCm;
  final bool customersOnly;
  final List<ScheduleRange>? openingHours;
  final TariffConfig? tariff;
  final List<String> sources;
  final String? verifiedAt;
}

class TariffConfig {
  const TariffConfig({
    required this.freeMinutes,
    required this.dailyTicket,
    required this.rates,
  });

  final int freeMinutes;
  final int? dailyTicket;
  final List<RateConfig> rates;

  Map<String, Object?> toJson() => {
    'freeMinutes': freeMinutes,
    'dailyTicket': dailyTicket,
    'rates': [for (final rate in rates) rate.toJson()],
  };
}

class RateConfig {
  const RateConfig({
    required this.window,
    required this.firstHour,
    required this.perHour,
  });

  final ScheduleRange window;

  /// In fenings; `null` when the first hour costs [perHour] like the rest.
  final int? firstHour;
  final int perHour;

  Map<String, Object?> toJson() => {
    ...window.toJson(),
    'firstHour': firstHour,
    'perHour': perHour,
  };
}

Object? _load(String yaml, String file, List<String> problems) {
  try {
    // A JSON round trip turns YamlMaps into plain maps and lists.
    return jsonDecode(jsonEncode(loadYaml(yaml)));
  } on Exception catch (error) {
    problems.add('$file: not valid YAML ($error)');
    return null;
  }
}

void _checkUnique(
  List<String> problems,
  String what,
  Iterable<Object?> values,
) {
  final seen = <Object>{};
  for (final value in values.nonNulls) {
    if (!seen.add(value)) problems.add('Duplicate $what: $value');
  }
}

const _days = {
  'mon': 1,
  'tue': 2,
  'wed': 3,
  'thu': 4,
  'fri': 5,
  'sat': 6,
  'sun': 7,
};

final _time = RegExp(r'^([01]\d|2[0-3]):[0-5]\d$|^24:00$');
final _date = RegExp(r'^\d{4}-\d{2}-\d{2}$');
final _smsNumber = RegExp(r'^\d{7}$');
final _osmRef = RegExp(r'^[nwr]\d+$');

/// Reads values out of decoded YAML, noting a problem (with where it is)
/// instead of throwing, so one run reports everything wrong at once.
class _Reader {
  _Reader(this.problems);

  final List<String> problems;

  T? _fail<T>(String at, String message) {
    problems.add('$at: $message');
    return null;
  }

  Map<String, Object?>? map(Object? value, String at) =>
      value is Map<String, Object?> ? value : _fail(at, 'expected a map');

  List<Object?> list(Object? root, String key, String at) {
    final value = map(root, at)?[key];
    if (value is List<Object?>) return value;
    _fail<void>(at, 'expected a list under "$key"');
    return const [];
  }

  String? string(Map<String, Object?> m, String key, String at) {
    final value = m[key];
    return value is String && value.trim().isNotEmpty
        ? value
        : _fail(at, '"$key" must be a non-empty string');
  }

  int? integer(
    Map<String, Object?> m,
    String key,
    String at, {
    bool optional = false,
  }) {
    final value = m[key];
    if (value == null && optional) return null;
    return value is int && value >= 0
        ? value
        : _fail(at, '"$key" must be a whole number of 0 or more');
  }

  /// A KM amount as fenings.
  int? money(
    Map<String, Object?> m,
    String key,
    String at, {
    bool optional = false,
  }) {
    final value = m[key];
    if (value == null && optional) return null;
    return value is num && value > 0
        ? (value * 100).round()
        : _fail(at, '"$key" must be an amount in KM above 0');
  }

  String? date(Map<String, Object?> m, String key, String at) {
    final value = m[key];
    if (value == null) return null;
    return value is String && _date.hasMatch(value)
        ? value
        : _fail(at, '"$key" must be a yyyy-mm-dd date or null');
  }

  List<String> strings(Map<String, Object?> m, String key, String at) {
    final value = m[key];
    if (value is List<Object?> && value.every((v) => v is String)) {
      return value.cast<String>();
    }
    _fail<void>(at, '"$key" must be a list of strings');
    return const [];
  }

  List<ScheduleRange>? schedule(
    Object? value,
    String at, {
    bool optional = false,
  }) {
    if (value == null && optional) return null;
    if (value is! List<Object?> || value.isEmpty) {
      return _fail(at, 'expected a non-empty list of {days, from, to}');
    }
    return [
      for (final (i, range) in value.indexed) ?scheduleRange(range, '$at[$i]'),
    ];
  }

  ScheduleRange? scheduleRange(Object? value, String at) {
    final m = map(value, at);
    if (m == null) return null;
    final days = m['days'];
    if (days is! List<Object?> ||
        days.isEmpty ||
        days.any((d) => !_days.containsKey(d))) {
      return _fail(at, '"days" must list some of ${_days.keys.join(', ')}');
    }
    final from = m['from'];
    final to = m['to'];
    if (from is! String || !_time.hasMatch(from) || from == '24:00') {
      return _fail(at, '"from" must be a time like "07:00"');
    }
    if (to is! String || !_time.hasMatch(to)) {
      return _fail(at, '"to" must be a time like "22:00" or "24:00"');
    }
    if (from == to) return _fail(at, '"from" and "to" are the same');
    return ScheduleRange(
      days: [for (final day in days) _days[day]!],
      from: from,
      to: to,
    );
  }

  CityConfig? city(Object? root) {
    const at = 'city.yaml';
    final m = map(root, at);
    if (m == null) return null;
    final bbox = m['bbox'];
    final camera = map(m['camera'], '$at › camera');
    final holidays = map(m['holidays'], '$at › holidays');
    final dates = holidays == null
        ? const <String>[]
        : strings(holidays, 'dates', '$at › holidays');
    for (final date in dates) {
      if (!_date.hasMatch(date)) {
        _fail<void>('$at › holidays', '"$date" is not a yyyy-mm-dd date');
      }
    }
    final id = string(m, 'id', at);
    final name = string(m, 'name', at);
    final operator = string(m, 'operator', at);
    final source = holidays == null
        ? null
        : string(holidays, 'source', '$at › holidays');
    if (bbox is! List<Object?> ||
        bbox.length != 4 ||
        bbox.any((v) => v is! num)) {
      return _fail(at, '"bbox" must be [minLon, minLat, maxLon, maxLat]');
    }
    const cameraKeys = ['lat', 'lon', 'zoom', 'pitch', 'bearing'];
    if (camera == null || cameraKeys.any((key) => camera[key] is! num)) {
      return _fail(at, '"camera" needs ${cameraKeys.join(', ')} as numbers');
    }
    if (id == null || name == null || operator == null || source == null) {
      return null;
    }
    return CityConfig(
      id: id,
      name: name,
      operator: operator,
      bbox: [for (final v in bbox) (v! as num).toDouble()],
      camera: {for (final key in cameraKeys) key: camera[key]! as num},
      holidays: dates,
      holidaysSource: source,
      holidaysVerifiedAt: date(holidays!, 'verifiedAt', '$at › holidays'),
    );
  }

  ZoneConfig? zone(Object? value, String at) {
    final m = map(value, at);
    if (m == null) return null;
    final id = string(m, 'id', at);
    final number = integer(m, 'number', at);
    final name = string(m, 'name', at);
    final sms = map(m['sms'], '$at › sms');
    final smsNumber = sms == null ? null : string(sms, 'number', '$at › sms');
    if (smsNumber != null && !_smsNumber.hasMatch(smsNumber)) {
      _fail<void>('$at › sms', '"number" must be 7 digits, like "0832001"');
    }
    final price = money(m, 'pricePerHour', at);
    final daily = money(m, 'dailyTicket', at, optional: true);
    final paidHours = schedule(m['paidHours'], '$at › paidHours');
    final maxStay = integer(m, 'maxStayMinutes', at, optional: true);
    final sources = strings(m, 'sources', at);
    if (sources.isEmpty) {
      _fail<void>(at, '"sources" must name where the values come from');
    }
    final stretchValues = m['stretches'];
    if (stretchValues is! List<Object?> || stretchValues.isEmpty) {
      return _fail(at, '"stretches" must be a non-empty list');
    }
    final stretches = [
      for (final (i, s) in stretchValues.indexed)
        ?stretch(s, '$at › stretches[$i]'),
    ];
    if (id == null ||
        number == null ||
        name == null ||
        smsNumber == null ||
        !_smsNumber.hasMatch(smsNumber) ||
        price == null ||
        paidHours == null ||
        stretches.length != stretchValues.length) {
      return null;
    }
    return ZoneConfig(
      id: id,
      number: number,
      name: name,
      smsNumber: smsNumber,
      pricePerHour: price,
      dailyTicket: daily,
      paidHours: paidHours,
      maxStayMinutes: maxStay,
      sources: sources,
      verifiedAt: date(m, 'verifiedAt', at),
      stretches: stretches,
    );
  }

  StretchConfig? stretch(Object? value, String at) {
    final m = map(value, at);
    if (m == null) return null;
    final name = string(m, 'name', at);
    final kindName = m['kind'] ?? 'street';
    final kind = StretchKind.values
        .where((k) => k.name == kindName)
        .firstOrNull;
    if (kind == null) return _fail(at, '"kind" must be street or lot');
    final spaces = integer(m, 'spaces', at, optional: true);
    Anchor? near;
    if (m['near'] != null) {
      final n = map(m['near'], '$at › near');
      if (n == null ||
          n['lat'] is! num ||
          n['lon'] is! num ||
          n['radius'] is! num) {
        return _fail(at, '"near" needs lat, lon and radius (metres)');
      }
      near = Anchor(
        lat: (n['lat']! as num).toDouble(),
        lon: (n['lon']! as num).toDouble(),
        radiusM: (n['radius']! as num).toDouble(),
      );
    }
    if (kind == StretchKind.lot && near == null) {
      return _fail(at, 'a lot needs "near" to find it');
    }
    if (name == null) return null;
    final osmName = m['osmName'];
    if (osmName != null && (osmName is! String || osmName.isEmpty)) {
      return _fail(at, '"osmName" must be a non-empty string');
    }
    return StretchConfig(
      name: name,
      osmName: (osmName as String?) ?? name,
      kind: kind,
      spaces: spaces,
      near: near,
    );
  }

  PlaceConfig? place(Object? value, String at) {
    final m = map(value, at);
    if (m == null) return null;
    final osm = string(m, 'osm', at);
    if (osm != null && !_osmRef.hasMatch(osm)) {
      _fail<void>(at, '"osm" must look like n123, w123 or r123');
    }
    final name = string(m, 'name', at);
    final type = PlaceType.values.where((t) => t.name == m['type']).firstOrNull;
    if (type == null) {
      _fail<void>(at, '"type" must be garage, underground or lot');
    }
    final capacity = integer(m, 'capacity', at, optional: true);
    final levels = integer(m, 'levels', at, optional: true);
    final maxHeight = integer(m, 'maxHeightCm', at, optional: true);
    final customersOnly = m['customersOnly'];
    if (customersOnly is! bool) {
      _fail<void>(at, '"customersOnly" must be true or false');
    }
    final hours = schedule(
      m['openingHours'],
      '$at › openingHours',
      optional: true,
    );
    final tariff = m['tariff'] == null
        ? null
        : this.tariff(m['tariff'], '$at › tariff');
    final sources = strings(m, 'sources', at);
    if (osm == null ||
        !_osmRef.hasMatch(osm) ||
        name == null ||
        type == null ||
        customersOnly is! bool) {
      return null;
    }
    if (m['tariff'] != null && tariff == null) return null;
    return PlaceConfig(
      osm: osm,
      name: name,
      type: type,
      capacity: capacity,
      levels: levels,
      maxHeightCm: maxHeight,
      customersOnly: customersOnly,
      openingHours: hours,
      tariff: tariff,
      sources: sources,
      verifiedAt: date(m, 'verifiedAt', at),
    );
  }

  TariffConfig? tariff(Object? value, String at) {
    final m = map(value, at);
    if (m == null) return null;
    final freeMinutes = integer(m, 'freeMinutes', at, optional: true) ?? 0;
    final daily = money(m, 'dailyTicket', at, optional: true);
    final rateValues = m['rates'];
    if (rateValues is! List<Object?> || rateValues.isEmpty) {
      return _fail(at, '"rates" must be a non-empty list');
    }
    final rates = <RateConfig>[];
    for (final (i, rateValue) in rateValues.indexed) {
      final rateAt = '$at › rates[$i]';
      final window = scheduleRange(rateValue, rateAt);
      final r = rateValue is Map<String, Object?> ? rateValue : null;
      final perHour = r == null ? null : money(r, 'perHour', rateAt);
      final firstHour = r == null
          ? null
          : money(r, 'firstHour', rateAt, optional: true);
      if (window != null && perHour != null) {
        rates.add(
          RateConfig(window: window, firstHour: firstHour, perHour: perHour),
        );
      }
    }
    if (rates.length != rateValues.length) return null;
    return TariffConfig(
      freeMinutes: freeMinutes,
      dailyTicket: daily,
      rates: rates,
    );
  }
}
