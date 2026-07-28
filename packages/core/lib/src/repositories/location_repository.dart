import '../api/api_client.dart';
import '../models/driver_location.dart';

class LocationRepository {
  /// driver_app tarafindan cagrilir - oturum sahibinin (token'daki kullanici)
  /// konumunu gunceller.
  Future<void> updateMyLocation({required double lat, required double lng}) =>
      api.post('/driver_location_update.php', body: {'lat': lat, 'lng': lng});

  /// admin_web'deki canli harita ekrani icin - tum aktif soforlerin en son
  /// bilinen konumu (yonetici/admin, bkz. backend/driver_locations_list.php).
  Future<List<DriverLocation>> fetchDriverLocations() async {
    final rows = await api.get('/driver_locations_list.php') as List;
    return rows.cast<Map<String, dynamic>>().map(DriverLocation.fromJson).toList();
  }
}
