/// The contents of a city's data file, as written by
/// `tool/build_dataset.dart`.
///
/// Coordinates are `[lon, lat]`, as in GeoJSON. Money is in fenings.
class CityDto {
  const CityDto({
    required this.generatedAt,
    required this.id,
    required this.name,
    required this.operator,
    required this.camera,
    required this.holidays,
    required this.zones,
    required this.places,
  });

  /// Reads a data file's JSON. Throws a [CityFormatException] when it isn't
  /// a city file this app can read, and the usual errors when it's damaged.
  factory CityDto.fromJson(Map<String, Object?> json) {
    if (json['format'] != format) {
      throw const CityFormatException('Not a city data file.');
    }
    final version = json['formatVersion'];
    if (version is! int || version > formatVersion) {
      throw CityFormatException('Unsupported format version $version.');
    }
    final city = json['city']! as Map<String, Object?>;
    return CityDto(
      generatedAt: DateTime.parse(json['generatedAt']! as String),
      id: city['id']! as String,
      name: city['name']! as String,
      operator: city['operator']! as String,
      camera: CameraDto.fromJson(city['camera']! as Map<String, Object?>),
      holidays: [
        for (final date in city['holidays']! as List<Object?>)
          DateTime.parse(date! as String),
      ],
      zones: [
        for (final zone in json['zones']! as List<Object?>)
          ZoneDto.fromJson(zone! as Map<String, Object?>),
      ],
      places: [
        for (final place in json['places']! as List<Object?>)
          PlaceDto.fromJson(place! as Map<String, Object?>),
      ],
    );
  }

  static const format = 'parkomat.city';

  /// The newest format this app reads.
  static const formatVersion = 1;

  final DateTime generatedAt;
  final String id;
  final String name;
  final String operator;
  final CameraDto camera;
  final List<DateTime> holidays;
  final List<ZoneDto> zones;
  final List<PlaceDto> places;
}

class CityFormatException implements Exception {
  const CityFormatException(this.message);

  final String message;

  @override
  String toString() => 'CityFormatException: $message';
}

/// `[lon, lat]`.
typedef Coordinate = ({double lon, double lat});

Coordinate _coordinate(Object? value) {
  final pair = value! as List<Object?>;
  return (lon: (pair[0]! as num).toDouble(), lat: (pair[1]! as num).toDouble());
}

List<Coordinate> _coordinates(Object? value) => [
  for (final point in value! as List<Object?>) _coordinate(point),
];

List<String> _strings(Object? value) => [
  for (final item in value! as List<Object?>) item! as String,
];

DateTime? _date(Object? value) =>
    value == null ? null : DateTime.parse(value as String);

class CameraDto {
  const CameraDto({
    required this.lat,
    required this.lon,
    required this.zoom,
    required this.pitch,
    required this.bearing,
  });

  factory CameraDto.fromJson(Map<String, Object?> json) => CameraDto(
    lat: (json['lat']! as num).toDouble(),
    lon: (json['lon']! as num).toDouble(),
    zoom: (json['zoom']! as num).toDouble(),
    pitch: (json['pitch']! as num).toDouble(),
    bearing: (json['bearing']! as num).toDouble(),
  );

  final double lat;
  final double lon;
  final double zoom;
  final double pitch;
  final double bearing;
}

class ScheduleRangeDto {
  const ScheduleRangeDto({
    required this.days,
    required this.from,
    required this.to,
  });

  factory ScheduleRangeDto.fromJson(Map<String, Object?> json) =>
      ScheduleRangeDto(
        days: [for (final day in json['days']! as List<Object?>) day! as int],
        from: json['from']! as String,
        to: json['to']! as String,
      );

  /// 1 = Monday … 7 = Sunday.
  final List<int> days;

  /// `HH:MM`; [to] may be `24:00`.
  final String from;
  final String to;
}

List<ScheduleRangeDto> _schedule(Object? value) => [
  for (final range in value! as List<Object?>)
    ScheduleRangeDto.fromJson(range! as Map<String, Object?>),
];

class ZoneDto {
  const ZoneDto({
    required this.id,
    required this.number,
    required this.name,
    required this.smsNumber,
    required this.pricePerHour,
    required this.dailyTicket,
    required this.maxStayMinutes,
    required this.paidHours,
    required this.sources,
    required this.verifiedAt,
    required this.stretches,
  });

  factory ZoneDto.fromJson(Map<String, Object?> json) => ZoneDto(
    id: json['id']! as String,
    number: json['number']! as int,
    name: json['name']! as String,
    smsNumber: json['smsNumber']! as String,
    pricePerHour: json['pricePerHour']! as int,
    dailyTicket: json['dailyTicket'] as int?,
    maxStayMinutes: json['maxStayMinutes'] as int?,
    paidHours: _schedule(json['paidHours']),
    sources: _strings(json['sources']),
    verifiedAt: _date(json['verifiedAt']),
    stretches: [
      for (final stretch in json['stretches']! as List<Object?>)
        StretchDto.fromJson(stretch! as Map<String, Object?>),
    ],
  );

  final String id;
  final int number;
  final String name;
  final String smsNumber;
  final int pricePerHour;
  final int? dailyTicket;
  final int? maxStayMinutes;
  final List<ScheduleRangeDto> paidHours;
  final List<String> sources;
  final DateTime? verifiedAt;
  final List<StretchDto> stretches;
}

class StretchDto {
  const StretchDto({
    required this.name,
    required this.kind,
    required this.spaces,
    required this.center,
    required this.lines,
    required this.area,
  });

  factory StretchDto.fromJson(Map<String, Object?> json) => StretchDto(
    name: json['name']! as String,
    kind: json['kind']! as String,
    spaces: json['spaces'] as int?,
    center: _coordinate(json['center']),
    lines: [
      for (final line in json['lines']! as List<Object?>) _coordinates(line),
    ],
    area: json['area'] == null ? null : _coordinates(json['area']),
  );

  final String name;

  /// `street` or `lot`.
  final String kind;
  final int? spaces;
  final Coordinate center;
  final List<List<Coordinate>> lines;
  final List<Coordinate>? area;
}

class PlaceDto {
  const PlaceDto({
    required this.id,
    required this.name,
    required this.type,
    required this.capacity,
    required this.levels,
    required this.heightM,
    required this.maxHeightCm,
    required this.customersOnly,
    required this.fee,
    required this.openingHours,
    required this.tariff,
    required this.center,
    required this.footprint,
    required this.sources,
    required this.verifiedAt,
    required this.curated,
  });

  factory PlaceDto.fromJson(Map<String, Object?> json) => PlaceDto(
    id: json['id']! as String,
    name: json['name'] as String?,
    type: json['type']! as String,
    capacity: json['capacity'] as int?,
    levels: json['levels'] as int?,
    heightM: (json['heightM'] as num?)?.toDouble(),
    maxHeightCm: json['maxHeightCm'] as int?,
    customersOnly: json['customersOnly']! as bool,
    fee: json['fee'] as bool?,
    openingHours: json['openingHours'] == null
        ? null
        : _schedule(json['openingHours']),
    tariff: json['tariff'] == null
        ? null
        : TariffDto.fromJson(json['tariff']! as Map<String, Object?>),
    center: _coordinate(json['center']),
    footprint: json['footprint'] == null
        ? null
        : _coordinates(json['footprint']),
    sources: _strings(json['sources']),
    verifiedAt: _date(json['verifiedAt']),
    curated: json['curated']! as bool,
  );

  final String id;
  final String? name;

  /// `garage`, `underground` or `lot`.
  final String type;
  final int? capacity;
  final int? levels;
  final double? heightM;
  final int? maxHeightCm;
  final bool customersOnly;
  final bool? fee;
  final List<ScheduleRangeDto>? openingHours;
  final TariffDto? tariff;
  final Coordinate center;
  final List<Coordinate>? footprint;
  final List<String> sources;
  final DateTime? verifiedAt;
  final bool curated;
}

class TariffDto {
  const TariffDto({
    required this.freeMinutes,
    required this.dailyTicket,
    required this.rates,
  });

  factory TariffDto.fromJson(Map<String, Object?> json) => TariffDto(
    freeMinutes: json['freeMinutes']! as int,
    dailyTicket: json['dailyTicket'] as int?,
    rates: [
      for (final rate in json['rates']! as List<Object?>)
        RateDto.fromJson(rate! as Map<String, Object?>),
    ],
  );

  final int freeMinutes;
  final int? dailyTicket;
  final List<RateDto> rates;
}

class RateDto {
  const RateDto({
    required this.window,
    required this.firstHour,
    required this.perHour,
  });

  factory RateDto.fromJson(Map<String, Object?> json) => RateDto(
    window: ScheduleRangeDto.fromJson(json),
    firstHour: json['firstHour'] as int?,
    perHour: json['perHour']! as int,
  );

  final ScheduleRangeDto window;
  final int? firstHour;
  final int perHour;
}
