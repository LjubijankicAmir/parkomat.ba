// Builds a city's bundled parking data from its hand-written YAML and
// OpenStreetMap.
//
//   dart run tool/build_dataset.dart sarajevo
//
// Reads dataset/<city>/{city,zones,places}.yaml, asks the Overpass API for
// the streets, garages and lots, and writes assets/data/<city>.json plus
// dataset/<city>/REPORT.md, which lists everything still to resolve or
// verify. Commit both.
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'src/builder.dart';
import 'src/config.dart';
import 'src/osm.dart';

const _overpassUrl = 'https://overpass-api.de/api/interpreter';

Future<void> main(List<String> args) async {
  if (args.length != 1) {
    stderr.writeln('Usage: dart run tool/build_dataset.dart <city>');
    exitCode = 64;
    return;
  }
  final cityId = args.single;
  final dir = Directory('dataset/$cityId');
  if (!dir.existsSync()) {
    stderr.writeln('No dataset folder at ${dir.path}.');
    exitCode = 66;
    return;
  }

  final DatasetConfig config;
  try {
    config = DatasetConfig.parse(
      cityYaml: File('${dir.path}/city.yaml').readAsStringSync(),
      zonesYaml: File('${dir.path}/zones.yaml').readAsStringSync(),
      placesYaml: File('${dir.path}/places.yaml').readAsStringSync(),
    );
  } on DatasetException catch (error) {
    stderr.writeln(error);
    exitCode = 65;
    return;
  }

  stdout.writeln('Asking OpenStreetMap…');
  final response = await _overpass(overpassQuery(config));
  if (response.statusCode != 200) {
    stderr.writeln(
      'Overpass answered ${response.statusCode}: ${response.body}',
    );
    exitCode = 69;
    return;
  }
  final overpass =
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, Object?>;
  final elements = [
    for (final e in overpass['elements']! as List<Object?>)
      OsmElement.fromJson(e! as Map<String, Object?>),
  ];
  final osmTimestamp =
      (overpass['osm3s'] as Map<String, Object?>?)?['timestamp_osm_base']
          as String?;

  final result = build(
    config,
    elements,
    generatedAt: DateTime.now(),
    osmTimestamp: osmTimestamp,
  );

  final asset = File('assets/data/$cityId.json')
    ..createSync(recursive: true)
    ..writeAsStringSync(
      '${const JsonEncoder.withIndent(' ').convert(result.json)}\n',
    );
  File('${dir.path}/REPORT.md').writeAsStringSync(
    '# ${config.city.name}: what to resolve or verify\n\n'
    'Written by `dart run tool/build_dataset.dart $cityId`. Do not edit by hand.\n\n'
    '${result.report.map((line) => '- $line').join('\n')}\n',
  );

  stdout
    ..writeln('Wrote ${asset.path} (${asset.lengthSync() ~/ 1024} KB).')
    ..writeln('${result.report.length} notes in ${dir.path}/REPORT.md.');
}

/// Posts [query] to Overpass, retrying with a growing wait while the public
/// server is busy.
Future<http.Response> _overpass(String query) async {
  var wait = const Duration(seconds: 5);
  for (var attempt = 1; ; attempt++) {
    final response = await http.post(
      Uri.parse(_overpassUrl),
      headers: {'User-Agent': 'parkomat.ba dataset builder'},
      body: {'data': query},
    );
    const busy = {429, 502, 503, 504};
    if (!busy.contains(response.statusCode) || attempt == 5) return response;
    stdout.writeln(
      'Overpass is busy (${response.statusCode}); retrying in ${wait.inSeconds} s…',
    );
    await Future<void>.delayed(wait);
    wait *= 2;
  }
}
