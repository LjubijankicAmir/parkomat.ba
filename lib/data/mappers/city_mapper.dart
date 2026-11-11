import 'package:parkomat/data/dtos/city_dto.dart';
import 'package:parkomat/domain/entities/city.dart';
import 'package:parkomat/domain/entities/parking_place.dart';
import 'package:parkomat/domain/entities/zone.dart';
import 'package:parkomat/domain/entities/zone_stretch.dart';
import 'package:parkomat/domain/value_objects/city_camera.dart';
import 'package:parkomat/domain/value_objects/geo_point.dart';
import 'package:parkomat/domain/value_objects/height_limit.dart';
import 'package:parkomat/domain/value_objects/money.dart';
import 'package:parkomat/domain/value_objects/parking_type.dart';
import 'package:parkomat/domain/value_objects/provenance.dart';
import 'package:parkomat/domain/value_objects/schedule_range.dart';
import 'package:parkomat/domain/value_objects/stretch_kind.dart';
import 'package:parkomat/domain/value_objects/tariff.dart';

extension CityDtoMapper on CityDto {
  City toEntity() {
    return City(
      id: id,
      name: name,
      operator: operator,
      camera: CityCamera(
        center: GeoPoint(lat: camera.lat, lon: camera.lon),
        zoom: camera.zoom,
        pitch: camera.pitch,
        bearing: camera.bearing,
      ),
      holidays: {
        for (final day in holidays) DateTime(day.year, day.month, day.day),
      },
      zones: [for (final zone in zones) zone.toEntity()],
      places: [for (final place in places) place.toEntity()],
      dataUpdatedAt: generatedAt,
    );
  }
}

extension ZoneDtoMapper on ZoneDto {
  Zone toEntity() {
    return Zone(
      id: id,
      number: number,
      name: name,
      smsNumber: smsNumber,
      pricePerHour: Money(pricePerHour),
      dailyTicket: dailyTicket == null ? null : Money(dailyTicket!),
      maxStay: maxStayMinutes == null
          ? null
          : Duration(minutes: maxStayMinutes!),
      paidHours: [for (final range in paidHours) range.toEntity()],
      stretches: [for (final stretch in stretches) stretch.toEntity()],
      provenance: _provenance(sources, verifiedAt),
    );
  }
}

extension StretchDtoMapper on StretchDto {
  ZoneStretch toEntity() {
    return ZoneStretch(
      name: name,
      kind: StretchKind.values.byName(kind),
      spaces: spaces,
      center: center.toPoint(),
      lines: [
        for (final line in lines) [for (final point in line) point.toPoint()],
      ],
      area: area?.map((point) => point.toPoint()).toList(),
    );
  }
}

extension PlaceDtoMapper on PlaceDto {
  ParkingPlace toEntity() {
    final type = ParkingType.values.byName(this.type);
    if (type == ParkingType.street) {
      throw const CityFormatException('A place cannot be street parking.');
    }
    return ParkingPlace(
      id: id,
      name: name,
      type: type,
      capacity: capacity,
      levels: levels,
      heightMetres: heightM,
      maxHeight: maxHeightCm == null
          ? null
          : HeightLimit(centimetres: maxHeightCm!),
      customersOnly: customersOnly,
      fee: fee,
      openingHours: openingHours?.map((range) => range.toEntity()).toList(),
      tariff: tariff?.toEntity(),
      center: center.toPoint(),
      footprint: footprint?.map((point) => point.toPoint()).toList(),
      provenance: _provenance(sources, verifiedAt),
      curated: curated,
    );
  }
}

extension TariffDtoMapper on TariffDto {
  Tariff toEntity() {
    return Tariff(
      freeMinutes: freeMinutes,
      dailyTicket: dailyTicket == null ? null : Money(dailyTicket!),
      rates: [
        for (final rate in rates)
          TariffRate(
            window: rate.window.toEntity(),
            perHour: Money(rate.perHour),
            firstHour: rate.firstHour == null ? null : Money(rate.firstHour!),
          ),
      ],
    );
  }
}

extension ScheduleRangeDtoMapper on ScheduleRangeDto {
  ScheduleRange toEntity() {
    return ScheduleRange(
      weekdays: days.toSet(),
      fromMinute: _minutes(from),
      toMinute: _minutes(to),
    );
  }
}

extension on Coordinate {
  GeoPoint toPoint() => GeoPoint(lat: lat, lon: lon);
}

/// `HH:MM` as minutes after midnight; `24:00` is 1440.
int _minutes(String time) {
  final [hours, minutes] = time.split(':').map(int.parse).toList();
  return hours * 60 + minutes;
}

Provenance _provenance(List<String> sources, DateTime? verifiedAt) {
  return Provenance(
    sources: [for (final source in sources) Uri.parse(source)],
    verifiedAt: verifiedAt,
  );
}
