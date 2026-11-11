import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parkomat/core/error/failure.dart';
import 'package:parkomat/data/datasources/asset/city_asset_source.dart';
import 'package:parkomat/data/repositories/city_repository_impl.dart';
import 'package:parkomat/domain/value_objects/money.dart';
import 'package:parkomat/domain/value_objects/parking_type.dart';
import 'package:parkomat/domain/value_objects/schedule_range.dart';

/// Serves files from the project folder, or [text] for every asset.
class _Bundle extends CachingAssetBundle {
  _Bundle([this.text]);

  final String? text;

  @override
  Future<ByteData> load(String key) async {
    final bytes = text == null
        ? File(key).readAsBytesSync()
        : Uint8List.fromList(text!.codeUnits);
    return ByteData.sublistView(bytes);
  }
}

void main() {
  CityRepositoryImpl repository([String? text]) =>
      CityRepositoryImpl(CityAssetSource(_Bundle(text)));

  test('loads Sarajevo with both zones and its places', () async {
    final result = await repository().load('sarajevo');
    final city = result.getOrElse((failure) => fail('$failure'));

    expect(city.name, 'Sarajevo');
    expect(city.operator, 'KJKP Rad');
    expect(city.camera.pitch, 56);
    expect(city.holidays, contains(DateTime(2026, 11, 25)));

    final [zone1, zone2] = city.zones;
    expect(zone1.number, 1);
    expect(zone1.smsNumber, '0832001');
    expect(zone1.pricePerHour, const Money(300));
    expect(
      zone1.paidHours.single,
      const ScheduleRange(
        weekdays: {1, 2, 3, 4, 5, 6},
        fromMinute: 420,
        toMinute: 1320,
      ),
    );
    expect(zone2.pricePerHour, const Money(200));
    expect(zone1.stretches, isNotEmpty);
    expect(
      zone1.stretches.every((s) => s.lines.isNotEmpty || s.center.lat > 0),
      isTrue,
    );

    final scc = city.places.singleWhere(
      (p) => p.name == 'Sarajevo City Center',
    );
    expect(scc.type, ParkingType.underground);
    expect(scc.tariff!.freeMinutes, 15);
    expect(scc.tariff!.rates.last.window.crossesMidnight, isTrue);
    expect(city.places.map((p) => p.type), isNot(contains(ParkingType.street)));
  });

  test('fails with a data failure when the file is damaged', () async {
    final result = await repository('{not json').load('sarajevo');

    expect(result.getLeft().toNullable(), isA<DataFailure>());
  });

  test('fails with a data failure when the city is unknown', () async {
    final result = await repository().load('atlantis');

    expect(result.getLeft().toNullable(), isA<DataFailure>());
  });
}
