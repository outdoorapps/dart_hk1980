import 'dart:math';

import 'package:dart_hk1980/hk1980_converter.dart';
import 'package:test/test.dart';
import 'package:vector_math/vector_math.dart';

const testCases2326to4326 = {
  [838901.9031000007, 832049.1549000014]: [22.427811, 114.2024588],
  [836888.9900000012, 814572.5205000024]: [22.2699892, 114.1828995],
  [833323.6430000011, 811368.1415000018]: [22.2410491, 114.1483124],
  [821433.5894000009, 833941.5874000024]: [22.4448383, 114.032763],
  [834325.0596000012, 816007.4568000026]: [22.2829465, 114.1580211],
  [820335.068500001, 834049.1483000014]: [22.4457998, 114.0220902],
  [835671.6273000007, 812192.2427000012]: [22.2484937, 114.1710889],
  [835132.8591000009, 814520.3010000009]: [22.2695173, 114.1658606],
  [835132.8089000005, 814520.2785000019]: [22.2695171, 114.1658601],
  [821430.8181000007, 833941.6470000017]: [22.4448388, 114.0327361],
  [837363.7108000005, 813773.7413000017]: [22.2627754, 114.187505],
};

const toleranceMeters = 2.0;

void main() {
  test('HK1980 → WGS84 converter within 2m tolerance', () {
    testCases2326to4326.forEach((en, expected) {
      final result = Hk1980Converter.toWgs84(easting: en[0], northing: en[1]);

      final errors = _degErrorToMeters(
        dLatDeg: result[0] - expected[0],
        dLonDeg: result[1] - expected[1],
        latRefDeg: expected[0],
      );

      expect(
        errors[0].abs(),
        lessThan(toleranceMeters),
        reason: 'Latitude error too large for input $en: ${errors[0]} meters',
      );

      expect(
        errors[1].abs(),
        lessThan(toleranceMeters),
        reason: 'Longitude error too large for input $en: ${errors[1]} meters',
      );
    });
  });
}

/// Convert degree differences into actual meter offsets.
List<double> _degErrorToMeters({
  required double dLatDeg,
  required double dLonDeg,
  required double latRefDeg,
}) {
  const metersPerDegLat = 111132.0; // approx constant
  final metersPerDegLon = 111320.0 * cos(radians(latRefDeg));

  final latMeters = dLatDeg * metersPerDegLat;
  final lonMeters = dLonDeg * metersPerDegLon;
  return [latMeters, lonMeters];
}
