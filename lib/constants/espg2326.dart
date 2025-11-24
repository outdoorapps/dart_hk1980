/// Projection parameters (EPSG:2326)
/// https://epsg.io/2326
///
/// +proj=tmerc +lat_0=22.3121333333333 +lon_0=114.178555555556
/// +k=1 +x_0=836694.05 +y_0=819069.8 +ellps=intl
/// +towgs84=-162.619,-276.959,-161.764,-0.067753,2.243648,1.158828,-1.094246
/// +units=m +no_defs +type=crs
///
class Epsg2326 {
  static const double lat0Deg = 22.3121333333333; // φ0
  static const double lon0Deg = 114.178555555556; // λ0
  static const double k0 = 1.0;
  static const double e0 = 836694.05; // false easting
  static const double n0 = 819069.80; // false northing

  // === 7-parameter Helmert transform ===
  static const double dx = -162.619;
  static const double dy = -276.959;
  static const double dz = -161.764;
  static const double rxSec = -0.067753; // arc-seconds
  static const double rySec = 2.243648;
  static const double rzSec = 1.158828;
  static const double sPpm = -1.094246; // ppm
}