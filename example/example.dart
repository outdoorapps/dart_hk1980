import 'package:dart_hk1980/src/hk1980_converter.dart';

void main() {
  // Sample HK1980 Grid (EPSG:2326) coordinate pair.
  // Easting (X), Northing (Y) in meters.
  final hk1980 = [838901.9031000007, 832049.1549000014];

  // Convert HK1980 grid → WGS84 latitude/longitude.
  final wgs84 = Hk1980Converter.toWgs84(
    easting: hk1980[0],
    northing: hk1980[1],
  );

  print('HK1980 $hk1980 → WGS84 $wgs84');
}
