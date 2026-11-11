import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parkomat/data/dtos/city_dto.dart';

void main() {
  Map<String, Object?> sarajevo() =>
      jsonDecode(File('assets/data/sarajevo.json').readAsStringSync())
          as Map<String, Object?>;

  test('reads the bundled Sarajevo file', () {
    final city = CityDto.fromJson(sarajevo());

    expect(city.id, 'sarajevo');
    expect(city.zones.map((z) => z.smsNumber), ['0832001', '0832002']);
    expect(city.places, isNotEmpty);
  });

  test('rejects a file that is not a city file', () {
    expect(
      () => CityDto.fromJson({...sarajevo(), 'format': 'something.else'}),
      throwsA(isA<CityFormatException>()),
    );
  });

  test('rejects a newer format than the app reads', () {
    expect(
      () => CityDto.fromJson({
        ...sarajevo(),
        'formatVersion': CityDto.formatVersion + 1,
      }),
      throwsA(isA<CityFormatException>()),
    );
  });
}
