import 'dart:math' as math;

/// A longitude/latitude pair, in GeoJSON order.
typedef LonLat = ({double lon, double lat});

const _earthRadiusM = 6371008.8;

/// Great-circle distance between [a] and [b], in metres.
double distanceM(LonLat a, LonLat b) {
  double rad(double degrees) => degrees * math.pi / 180;
  final dLat = rad(b.lat - a.lat);
  final dLon = rad(b.lon - a.lon);
  final h =
      math.pow(math.sin(dLat / 2), 2) +
      math.cos(rad(a.lat)) *
          math.cos(rad(b.lat)) *
          math.pow(math.sin(dLon / 2), 2);
  return 2 * _earthRadiusM * math.asin(math.sqrt(h));
}

/// The length of the line through [points], in metres.
double lengthM(List<LonLat> points) {
  var total = 0.0;
  for (var i = 1; i < points.length; i++) {
    total += distanceM(points[i - 1], points[i]);
  }
  return total;
}

/// The average of [points]: close enough to a center for small shapes.
LonLat centerOf(List<LonLat> points) {
  final lon = points.fold<double>(0, (sum, p) => sum + p.lon) / points.length;
  final lat = points.fold<double>(0, (sum, p) => sum + p.lat) / points.length;
  return (lon: lon, lat: lat);
}

/// [value] rounded to 6 decimals, about 10 cm: plenty for parking.
double round6(double value) => (value * 1e6).round() / 1e6;

List<double> encode(LonLat point) => [round6(point.lon), round6(point.lat)];
