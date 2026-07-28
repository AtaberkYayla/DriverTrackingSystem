import '../api/api_client.dart';
import '../models/enums.dart';
import '../models/trip.dart';
import '../models/trip_stop.dart';

/// Bir sefer durumu (trip_stop) ve ait oldugu sefer oturumu (trip) birlikte.
/// Yonetim panelinde Excel'deki gibi duz bir liste gostermek icin kullanilir.
class TripStopWithTrip {
  const TripStopWithTrip({required this.trip, this.stop});

  /// Sefer henuz hicbir firmaya ugramadiysa (orn. sadece Fabrika Cikis
  /// yapildiysa) durak kaydi olmadigindan null olabilir.
  final TripStop? stop;
  final Trip trip;
}

class TripRepository {
  // ---- Sefer (trip) oturumu ------------------------------------------------

  /// `client_trip_id` uzerinden upsert eder; cihazda uretilen bu kimlik
  /// sayesinde baglanti kesintisinde tekrar denenen yazmalar mukerrer
  /// kayit olusturmaz. driver_id her zaman sunucuda token'daki kullaniciya
  /// sabitlenir (backend/trips_upsert.php), client'tan gelen deger
  /// hicbir zaman guvenilmez.
  Future<Trip> upsertTrip(Trip trip) async {
    final row = await api.post('/trips_upsert.php', body: trip.toJson()) as Map<String, dynamic>;
    return Trip.fromJson(row);
  }

  Future<Trip?> fetchActiveTripForDriver(String driverId) async {
    final row = await api.get('/trips_active_for_driver.php');
    if (row == null) return null;
    return Trip.fromJson(row as Map<String, dynamic>);
  }

  Future<List<Trip>> fetchTripsForDriver(String driverId, {int limit = 50}) async {
    final rows = await api.get('/trips_for_driver.php', query: {'limit': limit}) as List;
    return rows.cast<Map<String, dynamic>>().map(Trip.fromJson).toList();
  }

  // ---- Sefer duraklari (trip_stops) -----------------------------------------

  Future<TripStop> upsertTripStop(TripStop stop) async {
    final row =
        await api.post('/trip_stops_upsert.php', body: stop.toJson()) as Map<String, dynamic>;
    return TripStop.fromJson(row);
  }

  Future<TripStop?> fetchOpenStopForTrip(String tripId) async {
    final row = await api.get('/trip_stops_open_for_trip.php', query: {'trip_id': tripId});
    if (row == null) return null;
    return TripStop.fromJson(row as Map<String, dynamic>);
  }

  Future<List<TripStop>> fetchStopsForTrip(String tripId) async {
    final rows =
        await api.get('/trip_stops_for_trip.php', query: {'trip_id': tripId}) as List;
    return rows.cast<Map<String, dynamic>>().map(TripStop.fromJson).toList();
  }

  /// Yonetim paneli icin: Excel'deki gibi duz bir liste - her satir bir
  /// firma ziyareti (trip_stop), ait oldugu seferin (trip) bilgileriyle
  /// birlikte. Eski Postgrest embedded-resource sorgusunun ve client-side
  /// post-filter'in yerini backend/trips_list.php'deki gercek bir SQL
  /// JOIN + WHERE alir.
  Future<List<TripStopWithTrip>> fetchAllStopsWithTrip({
    String? driverId,
    String? vehicleId,
    OnayDurumu? onayDurumu,
    SeferDurumu? seferDurumu,
    DateTime? baslangic,
    DateTime? bitis,
    List<String>? allowedRequesterIds,
    int limit = 500,
  }) async {
    final rows = await api.get('/trips_list.php', query: {
      if (driverId != null) 'driver_id': driverId,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (onayDurumu != null) 'onay_durumu': onayDurumu.toJson(),
      if (seferDurumu != null) 'sefer_durumu': seferDurumu.toJson(),
      if (baslangic != null) 'baslangic': _dateStr(baslangic),
      if (bitis != null) 'bitis': _dateStr(bitis),
      'limit': limit,
    }) as List;

    return rows.cast<Map<String, dynamic>>().map((row) {
      final trip = Trip.fromJson(row['trip'] as Map<String, dynamic>);
      final stopJson = row['stop'] as Map<String, dynamic>?;
      return TripStopWithTrip(trip: trip, stop: stopJson == null ? null : TripStop.fromJson(stopJson));
    }).toList();
  }

  /// Sadece onay/degerlendirme sutunlarini gunceller. onaylayanId artik
  /// sunucuda token'daki kullanicidan alinir (guvenlik icin), parametre
  /// sadece cagiran taraflarda degisiklik olmamasi icin korunuyor.
  Future<TripStop> updateApproval({
    required String stopId,
    required OnayDurumu onayDurumu,
    required String onaylayanId,
    required SeferDurumu seferDurumu,
    String? notlar,
  }) async {
    final row = await api.post('/trip_stops_update_approval.php', body: {
      'stop_id': stopId,
      'onay_durumu': onayDurumu.toJson(),
      'sefer_durumu': seferDurumu.toJson(),
      if (notlar != null) 'notlar': notlar,
    }) as Map<String, dynamic>;
    return TripStop.fromJson(row);
  }

  /// Soforden gelen sefer/durak detaylarini duzeltir (yalnizca yonetici/admin
  /// icin acik; bkz. backend/trip_stops_update_details.php).
  Future<TripStop> updateTripStopDetails(TripStop stop) async {
    final row = await api.post('/trip_stops_update_details.php', body: stop.toJson())
        as Map<String, dynamic>;
    return TripStop.fromJson(row);
  }

  /// Sefer (trip) seviyesindeki alanlari (arac, tarih, fabrika cikis/giris)
  /// duzeltir (yalnizca yonetici/admin icin acik).
  Future<Trip> updateTrip(Trip trip) async {
    final row = await api.post('/trips_update.php', body: trip.toJson()) as Map<String, dynamic>;
    return Trip.fromJson(row);
  }

  /// Yanlislikla olusturulmus/mukerrer bir seferi tamamen siler (durak
  /// kayitlari FK ON DELETE CASCADE ile birlikte gider). Yalnizca yonetici/admin.
  Future<void> deleteTrip(String id) => api.delete('/trips_delete.php', query: {'id': id});

  /// Yanlislikla olusturulmus/mukerrer bir duragi tamamen siler. Yalnizca
  /// yonetici/admin icin acik.
  Future<void> deleteTripStop(String id) =>
      api.delete('/trip_stops_delete.php', query: {'id': id});

  String _dateStr(DateTime date) => date.toIso8601String().substring(0, 10);
}
