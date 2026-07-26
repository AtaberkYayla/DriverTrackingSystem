import '../models/enums.dart';
import '../models/trip.dart';
import '../models/trip_stop.dart';
import '../supabase/supabase_config.dart';

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
  /// kayit olusturmaz.
  Future<Trip> upsertTrip(Trip trip) async {
    final row = await supabase
        .from('trips')
        .upsert(trip.toJson(), onConflict: 'client_trip_id')
        .select()
        .single();
    return Trip.fromJson(row);
  }

  Future<Trip?> fetchActiveTripForDriver(String driverId) async {
    final row = await supabase
        .from('trips')
        .select()
        .eq('driver_id', driverId)
        .isFilter('fabrika_giris_at', null)
        .maybeSingle();
    if (row == null) return null;
    return Trip.fromJson(row);
  }

  Future<List<Trip>> fetchTripsForDriver(String driverId, {int limit = 50}) async {
    final rows = await supabase
        .from('trips')
        .select()
        .eq('driver_id', driverId)
        .order('created_at', ascending: false)
        .limit(limit);
    return rows.map(Trip.fromJson).toList();
  }

  // ---- Sefer duraklari (trip_stops) -----------------------------------------

  Future<TripStop> upsertTripStop(TripStop stop) async {
    final row = await supabase
        .from('trip_stops')
        .upsert(stop.toJson(), onConflict: 'client_stop_id')
        .select()
        .single();
    return TripStop.fromJson(row);
  }

  Future<TripStop?> fetchOpenStopForTrip(String tripId) async {
    final row = await supabase
        .from('trip_stops')
        .select()
        .eq('trip_id', tripId)
        .isFilter('firma_cikis_at', null)
        .maybeSingle();
    if (row == null) return null;
    return TripStop.fromJson(row);
  }

  Future<List<TripStop>> fetchStopsForTrip(String tripId) async {
    final rows = await supabase
        .from('trip_stops')
        .select()
        .eq('trip_id', tripId)
        .order('sira');
    return rows.map(TripStop.fromJson).toList();
  }

  /// Yonetim paneli icin: Excel'deki gibi duz bir liste - her satir bir
  /// firma ziyareti (trip_stop), ait oldugu seferin (trip) bilgileriyle
  /// birlikte. onay/sefer durumu sunucuda, sofor/arac/tarih istemci
  /// tarafinda filtrelenir (kucuk veri hacmi icin yeterli).
  ///
  /// Sorgu 'trips' tablosundan baslar (trip_stops!inner degil) ki henuz
  /// hicbir firmaya ugramamis (durak kaydi olmayan) aktif seferler de
  /// listede gorunsun; sadece onay/sefer durumu filtrelendiginde (bu
  /// alanlar durak bazinda oldugundan) durak zorunlu hale gelir.
  Future<List<TripStopWithTrip>> fetchAllStopsWithTrip({
    String? driverId,
    String? vehicleId,
    OnayDurumu? onayDurumu,
    SeferDurumu? seferDurumu,
    DateTime? baslangic,
    DateTime? bitis,
    int limit = 500,
  }) async {
    final stopFiltresiVar = onayDurumu != null || seferDurumu != null;
    final duraklarSecimi = stopFiltresiVar ? 'trip_stops!inner(*)' : 'trip_stops(*)';
    var query = supabase.from('trips').select('*, $duraklarSecimi');
    if (onayDurumu != null) {
      query = query.eq('trip_stops.onay_durumu', onayDurumu.toJson());
    }
    if (seferDurumu != null) {
      query = query.eq('trip_stops.sefer_durumu', seferDurumu.toJson());
    }

    final rows = await query.order('created_at', ascending: false).limit(limit);

    final results = <TripStopWithTrip>[];
    for (final row in rows) {
      final tripJson = Map<String, dynamic>.from(row)..remove('trip_stops');
      final trip = Trip.fromJson(tripJson);
      final stopRows = (row['trip_stops'] as List).cast<Map<String, dynamic>>();
      if (stopRows.isEmpty) {
        results.add(TripStopWithTrip(trip: trip));
      } else {
        for (final stopJson in stopRows) {
          results.add(TripStopWithTrip(trip: trip, stop: TripStop.fromJson(stopJson)));
        }
      }
    }

    return results.where((r) {
      if (driverId != null && r.trip.driverId != driverId) return false;
      if (vehicleId != null && r.trip.vehicleId != vehicleId) return false;
      if (baslangic != null && r.trip.tarih.compareTo(_dateStr(baslangic)) < 0) return false;
      if (bitis != null && r.trip.tarih.compareTo(_dateStr(bitis)) > 0) return false;
      return true;
    }).toList();
  }

  /// Sadece onay/degerlendirme sutunlarini gunceller (RLS + trigger bunu zorunlu kilar).
  Future<TripStop> updateApproval({
    required String stopId,
    required OnayDurumu onayDurumu,
    required String onaylayanId,
    required SeferDurumu seferDurumu,
    String? notlar,
  }) async {
    final row = await supabase
        .from('trip_stops')
        .update({
          'onay_durumu': onayDurumu.toJson(),
          'onaylayan_id': onaylayanId,
          'onaylandi_at': DateTime.now().toIso8601String(),
          'sefer_durumu': seferDurumu.toJson(),
          if (notlar != null) 'notlar': notlar,
        })
        .eq('id', stopId)
        .select()
        .single();
    return TripStop.fromJson(row);
  }

  /// Soforden gelen sefer/durak detaylarini duzeltir (yalnizca yonetici/admin
  /// icin acik; RLS + trigger bunu zorunlu kilar, bkz. migration_002).
  Future<TripStop> updateTripStopDetails(TripStop stop) async {
    final payload = stop.toJson()
      ..remove('client_stop_id')
      ..remove('trip_id')
      ..remove('id');
    final row = await supabase
        .from('trip_stops')
        .update(payload)
        .eq('id', stop.id)
        .select()
        .single();
    return TripStop.fromJson(row);
  }

  /// Sefer (trip) seviyesindeki alanlari (arac, tarih, fabrika cikis/giris)
  /// duzeltir (yalnizca yonetici/admin icin acik).
  Future<Trip> updateTrip(Trip trip) async {
    final payload = trip.toJson()
      ..remove('client_trip_id')
      ..remove('id');
    final row = await supabase
        .from('trips')
        .update(payload)
        .eq('id', trip.id)
        .select()
        .single();
    return Trip.fromJson(row);
  }

  /// Yanlislikla olusturulmus/mukerrer bir seferi tamamen siler (durak
  /// kayitlari cascade ile birlikte gider). Yalnizca yonetici/admin icin acik.
  Future<void> deleteTrip(String id) async {
    await supabase.from('trips').delete().eq('id', id);
  }

  /// Yanlislikla olusturulmus/mukerrer bir duragi tamamen siler. Yalnizca
  /// yonetici/admin icin acik.
  Future<void> deleteTripStop(String id) async {
    await supabase.from('trip_stops').delete().eq('id', id);
  }

  String _dateStr(DateTime date) => date.toIso8601String().substring(0, 10);
}
