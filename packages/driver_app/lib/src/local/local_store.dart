import 'package:core/core.dart';
import 'package:drift/drift.dart';

import 'app_database.dart';

/// AppDatabase uzerindeki islemleri anlamli isimlerle sunan yardimci katman.
/// Ekranlar ve SyncService drift tablolarina dogrudan degil bu sinif
/// uzerinden erisir.
class LocalStore {
  LocalStore(this._db);

  final AppDatabase _db;

  // ---- Sefer (trip) oturumu outbox islemleri --------------------------------

  Future<void> upsertLocalTrip(TripsCacheCompanion row) {
    return _db.into(_db.tripsCache).insertOnConflictUpdate(row);
  }

  Future<TripsCacheData?> aktifSeferGetir(String driverId) {
    return (_db.select(_db.tripsCache)
          ..where((t) => t.driverId.equals(driverId) & t.fabrikaGirisAt.isNull()))
        .getSingleOrNull();
  }

  Stream<TripsCacheData?> aktifSeferIzle(String driverId) {
    return (_db.select(_db.tripsCache)
          ..where((t) => t.driverId.equals(driverId) & t.fabrikaGirisAt.isNull()))
        .watchSingleOrNull();
  }

  Future<List<TripsCacheData>> gecmisSeferler(String driverId, {int limit = 50}) {
    return (_db.select(_db.tripsCache)
          ..where((t) => t.driverId.equals(driverId) & t.fabrikaGirisAt.isNotNull())
          ..orderBy([(t) => OrderingTerm.desc(t.updatedLocallyAt)])
          ..limit(limit))
        .get();
  }

  Future<List<TripsCacheData>> bekleyenSeferler() {
    return (_db.select(_db.tripsCache)..where((t) => t.synced.equals(false))).get();
  }

  Future<void> senkronizeIsaretle(String clientTripId, {required String serverId}) {
    return (_db.update(_db.tripsCache)..where((t) => t.clientTripId.equals(clientTripId)))
        .write(TripsCacheCompanion(
      serverId: Value(serverId),
      synced: const Value(true),
      lastError: const Value(null),
    ));
  }

  Future<void> senkronizasyonHatasi(String clientTripId, String hata) async {
    final current = await (_db.select(_db.tripsCache)
          ..where((t) => t.clientTripId.equals(clientTripId)))
        .getSingleOrNull();
    final yeniDeneme = (current?.retryCount ?? 0) + 1;
    await (_db.update(_db.tripsCache)..where((t) => t.clientTripId.equals(clientTripId)))
        .write(TripsCacheCompanion(
      retryCount: Value(yeniDeneme),
      lastError: Value(hata),
    ));
  }

  /// Sofor, dogrudan "Firma Giris" ile baslattigi bir seferin detay
  /// formunu iptal ederse, henuz hicbir durak eklenmemis bu bos sefer
  /// kaydini geri alir.
  Future<void> localSeferiSil(String clientTripId) {
    return (_db.delete(_db.tripsCache)..where((t) => t.clientTripId.equals(clientTripId))).go();
  }

  Future<String?> seferSunucuIdGetir(String clientTripId) async {
    final row = await (_db.select(_db.tripsCache)
          ..where((t) => t.clientTripId.equals(clientTripId)))
        .getSingleOrNull();
    return row?.serverId;
  }

  // ---- Sefer duraklari (trip_stops) outbox islemleri -------------------------

  Future<void> upsertLocalStop(TripStopsCacheCompanion row) {
    return _db.into(_db.tripStopsCache).insertOnConflictUpdate(row);
  }

  Future<TripStopsCacheData?> acikDurakGetir(String clientTripId) {
    return (_db.select(_db.tripStopsCache)
          ..where((s) => s.clientTripId.equals(clientTripId) & s.firmaCikisAt.isNull()))
        .getSingleOrNull();
  }

  Stream<TripStopsCacheData?> acikDurakIzle(String clientTripId) {
    return (_db.select(_db.tripStopsCache)
          ..where((s) => s.clientTripId.equals(clientTripId) & s.firmaCikisAt.isNull()))
        .watchSingleOrNull();
  }

  Future<List<TripStopsCacheData>> duraklarGetir(String clientTripId) {
    return (_db.select(_db.tripStopsCache)
          ..where((s) => s.clientTripId.equals(clientTripId))
          ..orderBy([(s) => OrderingTerm.asc(s.sira)]))
        .get();
  }

  Stream<List<TripStopsCacheData>> duraklariIzle(String clientTripId) {
    return (_db.select(_db.tripStopsCache)
          ..where((s) => s.clientTripId.equals(clientTripId))
          ..orderBy([(s) => OrderingTerm.asc(s.sira)]))
        .watch();
  }

  Future<int> sonrakiDurakSirasi(String clientTripId) async {
    final mevcut = await duraklarGetir(clientTripId);
    return mevcut.length + 1;
  }

  Future<List<TripStopsCacheData>> bekleyenDuraklar() {
    return (_db.select(_db.tripStopsCache)..where((s) => s.synced.equals(false))).get();
  }

  Future<void> stopSenkronizeIsaretle(String clientStopId, {required String serverId}) {
    return (_db.update(_db.tripStopsCache)..where((s) => s.clientStopId.equals(clientStopId)))
        .write(TripStopsCacheCompanion(
      serverId: Value(serverId),
      synced: const Value(true),
      lastError: const Value(null),
    ));
  }

  Future<void> stopSenkronizasyonHatasi(String clientStopId, String hata) async {
    final current = await (_db.select(_db.tripStopsCache)
          ..where((s) => s.clientStopId.equals(clientStopId)))
        .getSingleOrNull();
    final yeniDeneme = (current?.retryCount ?? 0) + 1;
    await (_db.update(_db.tripStopsCache)..where((s) => s.clientStopId.equals(clientStopId)))
        .write(TripStopsCacheCompanion(
      retryCount: Value(yeniDeneme),
      lastError: Value(hata),
    ));
  }

  Future<int> bekleyenSeferVeDurakSayisi() async {
    final seferler = await bekleyenSeferler();
    final duraklar = await bekleyenDuraklar();
    return seferler.length + duraklar.length;
  }

  // ---- Master veri onbellegi ----------------------------------------------

  Future<void> araclariGuncelle(List<Vehicle> vehicles) async {
    await _db.batch((batch) {
      batch.deleteAll(_db.vehiclesCache);
      batch.insertAll(
        _db.vehiclesCache,
        vehicles.map((v) => VehiclesCacheCompanion.insert(
              id: v.id,
              plaka: v.plaka,
              aciklama: Value(v.aciklama),
              aktif: Value(v.aktif),
            )),
      );
    });
  }

  Future<void> seferTurleriniGuncelle(List<TripType> tripTypes) async {
    await _db.batch((batch) {
      batch.deleteAll(_db.tripTypesCache);
      batch.insertAll(
        _db.tripTypesCache,
        tripTypes.map((t) => TripTypesCacheCompanion.insert(
              id: t.id,
              code: t.code,
              label: t.label,
              requiresIrsaliye: Value(t.requiresIrsaliye),
              sira: Value(t.sira),
              aktif: Value(t.aktif),
            )),
      );
    });
  }

  Future<void> talepEdenleriGuncelle(List<Requester> requesters) async {
    await _db.batch((batch) {
      batch.deleteAll(_db.requestersCache);
      batch.insertAll(
        _db.requestersCache,
        requesters.map((r) => RequestersCacheCompanion.insert(
              id: r.id,
              fullName: r.fullName,
              aktif: Value(r.aktif),
            )),
      );
    });
  }

  Future<void> sirketleriGuncelle(List<Company> companies) async {
    await _db.batch((batch) {
      batch.deleteAll(_db.companiesCache);
      batch.insertAll(
        _db.companiesCache,
        companies.map((c) => CompaniesCacheCompanion.insert(
              id: c.id,
              name: c.name,
              sehir: Value(c.sehir),
              tripTypeIds: Value(c.tripTypeIds.join(',')),
              aktif: Value(c.aktif),
            )),
      );
    });
  }

  Future<List<VehiclesCacheData>> araclar() =>
      (_db.select(_db.vehiclesCache)..where((v) => v.aktif.equals(true))).get();

  Future<List<TripTypesCacheData>> seferTurleri() => (_db.select(_db.tripTypesCache)
        ..where((t) => t.aktif.equals(true))
        ..orderBy([(t) => OrderingTerm.asc(t.sira)]))
      .get();

  Future<List<RequestersCacheData>> talepEdenler() =>
      (_db.select(_db.requestersCache)..where((r) => r.aktif.equals(true))).get();

  Future<List<CompaniesCacheData>> sirketler() =>
      (_db.select(_db.companiesCache)..where((c) => c.aktif.equals(true))).get();
}
