import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:parkomat/data/dtos/city_dto.dart';

/// The city data bundled with the app, so the map works offline from the
/// first launch.
@lazySingleton
class CityAssetSource {
  CityAssetSource(this._bundle);

  final AssetBundle _bundle;

  /// Throws when the file is missing, damaged or not a city file.
  Future<CityDto> read(String cityId) async {
    final text = await _bundle.loadString('assets/data/$cityId.json');
    // A few hundred kilobytes: parsed off the UI thread where possible.
    return await compute(_parse, text);
  }
}

CityDto _parse(String text) =>
    CityDto.fromJson(jsonDecode(text) as Map<String, Object?>);
