# dart_hk1980

A converter for transforming **Hong Kong 1980 Grid (HK1980 / EPSG:2326)** coordinates
into **WGS84 latitude/longitude (EPSG:4326)**.

---

## ✨ Features

- 🔁 Convert **HK1980 Grid (EPSG:2326)** → **WGS84 (EPSG:4326)**
- 🎯 Geographic accuracy: within 2 meters
- 📐 Uses:
    - International 1924 ellipsoid
    - Official Hong Kong LandsD TM parameters
    - HK80 → WGS84 offsets (–5.5″ latitude, +8.8″ longitude)
- 🧩 Pure Dart implementation (no native dependencies)

## Usage Example

```dart
import 'package:dart_hk1980/dart_hk1980.dart';

void main() {
  // HK1980 Grid coordinates (X = easting, Y = northing)
  final hk1980 = [838901.9031, 832049.1549];

  // Convert to WGS84 latitude/longitude
  final wgs84 = Hk1980Converter.toWgs84(
    easting: hk1980[0],
    northing: hk1980[1],
  );

  print('HK1980 $hk1980 → WGS84 $wgs84');
}
```

---

## 📦 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  dart_hk1980: ^1.0.0+2
