import 'dart:async';

import 'package:core/core.dart';
import 'package:geolocator/geolocator.dart';

/// Uygulama acikken (foreground) soforun konumunu periyodik olarak sunucuya
/// gonderir - admin_web'deki canli harita ekrani icin. Uygulama kapatilir/arka
/// plana alinirsa gonderim durur (arka plan takibi bilerek yapilmiyor, bkz.
/// backend/driver_locations_list.php).
class LocationService {
  LocationService({required this._locationRepository});

  final LocationRepository _locationRepository;
  Timer? _timer;

  void start() {
    _gonder();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _gonder());
  }

  void dispose() {
    _timer?.cancel();
  }

  Future<void> _gonder() async {
    try {
      var izin = await Geolocator.checkPermission();
      if (izin == LocationPermission.denied) {
        izin = await Geolocator.requestPermission();
      }
      if (izin == LocationPermission.denied || izin == LocationPermission.deniedForever) {
        return;
      }
      if (!await Geolocator.isLocationServiceEnabled()) {
        return;
      }
      final konum = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      await _locationRepository.updateMyLocation(lat: konum.latitude, lng: konum.longitude);
    } catch (_) {
      // Izin verilmedi/GPS kapali/internet yok - bir sonraki denemede tekrar dener.
    }
  }
}
