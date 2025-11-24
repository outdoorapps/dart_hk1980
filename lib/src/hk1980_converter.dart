import 'dart:math';

import 'package:vector_math/vector_math_64.dart';

import 'constants/espg2326.dart';
import 'constants/intl1924.dart';

/// Convert HK1980 Grid (EPSG:2326) to WGS84 geographic (lat, lon in degrees).
class Hk1980Converter {
  // Series coefficients
  static const _e2Sq = Intl1924.e2 * Intl1924.e2;
  static const _a0 = 1 - (Intl1924.e2 / 4) - (3 * _e2Sq / 64);
  static const _a2 = (3 / 8) * (Intl1924.e2 + _e2Sq / 4);
  static const _a4 = (15 / 256) * _e2Sq;

  // HK80 GEO → WGS84 GEO offsets (seconds of arc)
  // lat_WGS = lat_HK80 - 5.5"
  // lon_WGS = lon_HK80 + 8.8"
  static const _latOffsetSec = 5.5;
  static const _lonOffsetSec = 8.8;

  static final _lambda0Rad = radians(Epsg2326.lon0Deg);
  static final _phi0 = radians(Epsg2326.lat0Deg);
  static final _m0 =
      Intl1924.a * (_a0 * _phi0 - _a2 * sin(2 * _phi0) + _a4 * sin(4 * _phi0));

  /// Converts HK1980 Grid coordinates (EPSG:2326) to WGS84 geographic
  /// coordinates (EPSG:4326), returning [latitude, longitude] in degrees.
  /// Accuracy < 2 m.
  ///
  /// [easting]  — X value in the HK1980 Transverse Mercator grid (meters)
  /// [northing] — Y value in the HK1980 Transverse Mercator grid (meters)
  ///
  /// This uses the Hong Kong Lands Department’s official HK80 → WGS84
  /// 2D transformation (−5.5″ latitude, +8.8″ longitude), providing
  /// sub-meter accuracy and matching the results from EPSG.io.
  static List<double> toWgs84({
    required double easting,
    required double northing,
  }) {
    final hk80 = _hk1980GridToHk80Geo(northing: northing, easting: easting);
    final wgs84 = _hk80GeoToWgs84Geo(latDeg: hk80[0], lonDeg: hk80[1]);
    return wgs84; // [lat, lon]
  }

  /// Step 1: HK1980 Grid (N,E) → HK80 geographic (φ, λ in degrees).
  static List<double> _hk1980GridToHk80Geo({
    required double northing,
    required double easting,
  }) {
    final deltaN = northing - Epsg2326.n0;
    final deltaE = easting - Epsg2326.e0;

    // fm(x) = (((ΔN + M0)/m0)/a + A2*sin(2x) - A4*sin(4x)) / A0
    fm(x) =>
        (((deltaN + _m0) / Epsg2326.k0) / Intl1924.a +
            _a2 * sin(2 * x) -
            _a4 * sin(4 * x)) /
        _a0;

    iterate(x0, tol) {
      var a = x0;
      var b = fm(a);
      var k = 0;
      while ((a - b).abs() > tol) {
        a = b;
        b = fm(a);
        k++;
        if (k > 1000) throw StateError('HK1980 iteration did not converge');
      }
      return b;
    }

    // Solve for φ̄ (phi_rou) by iteration (Page C9)
    final phiBar = iterate(0.5, 1e-30);

    final sinPhi = sin(phiBar);
    final cosPhi = cos(phiBar);
    final t = tan(phiBar);

    final nu = Intl1924.a / sqrt(1 - Intl1924.e2 * sinPhi * sinPhi); // ν
    final rho = Intl1924.a *
        (1 - Intl1924.e2) /
        pow(1 - Intl1924.e2 * sinPhi * sinPhi, 1.5); // ρ
    final psi = nu / rho; // ψ

    // Equation (4): longitude λ (radians)
    final term1 = deltaE / (Epsg2326.k0 * nu);
    final term3 = pow(deltaE, 3) /
        (6 * Epsg2326.k0 * Epsg2326.k0 * Epsg2326.k0 * nu * nu * nu) *
        (psi + 2 * t * t);
    final lambdaRad = _lambda0Rad + (term1 - term3) / cosPhi;

    // Equation (5): latitude φ (radians)
    final phiRad = phiBar -
        t / (Epsg2326.k0 * rho) * (deltaE * deltaE / (2 * Epsg2326.k0 * nu));

    final latDeg = degrees(phiRad);
    final lonDeg = degrees(lambdaRad);

    return [latDeg, lonDeg]; // HK80 geographic
  }

  /// Step 2: HK80 geographic → WGS84 geographic (simple offset, Page B6).
  static List<double> _hk80GeoToWgs84Geo({
    required double latDeg,
    required double lonDeg,
  }) {
    final lat = latDeg - _latOffsetSec / 3600.0;
    final lon = lonDeg + _lonOffsetSec / 3600.0;
    return [lat, lon];
  }
}
