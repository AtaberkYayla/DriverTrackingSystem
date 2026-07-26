import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:core/core.dart';

import '../local/app_database.dart';
import '../local/local_store.dart';

/// Baglanti gelince (veya elle tetiklendiginde) bekleyen sefer ve durak
/// kayitlarini Supabase'e upsert ederek gonderir. Basarisiz olan kayitlar
/// bir sonraki tetiklemede tekrar denenir; boylece sinyal sorunlarinda
/// veri kaybi yasanmaz. Duraklar, ait olduklari seferin sunucu id'sine
/// ihtiyac duydugu icin seferler once, duraklar sonra senkronize edilir.
class SyncService {
  SyncService({
    required LocalStore localStore,
    required TripRepository tripRepository,
    required MasterDataRepository masterDataRepository,
  })  : _localStore = localStore,
        _tripRepository = tripRepository,
        _masterDataRepository = masterDataRepository;

  final LocalStore _localStore;
  final TripRepository _tripRepository;
  final MasterDataRepository _masterDataRepository;

  final _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connSub;
  final _pendingCountController = StreamController<int>.broadcast();
  bool _isSyncing = false;

  Stream<int> get pendingCountStream => _pendingCountController.stream;

  void start() {
    _connSub = _connectivity.onConnectivityChanged.listen((results) {
      if (!results.contains(ConnectivityResult.none)) {
        drainOutbox();
      }
    });
    drainOutbox();
  }

  void dispose() {
    _connSub?.cancel();
    _pendingCountController.close();
  }

  Future<void> refreshMasterData() async {
    try {
      final results = await Future.wait([
        _masterDataRepository.fetchVehicles(),
        _masterDataRepository.fetchTripTypes(),
        _masterDataRepository.fetchRequesters(),
        _masterDataRepository.fetchCompanies(),
      ]);
      await _localStore.araclariGuncelle(results[0] as List<Vehicle>);
      await _localStore.seferTurleriniGuncelle(results[1] as List<TripType>);
      await _localStore.talepEdenleriGuncelle(results[2] as List<Requester>);
      await _localStore.sirketleriGuncelle(results[3] as List<Company>);
    } catch (_) {
      // Baglanti yoksa mevcut onbellek kullanilmaya devam eder.
    }
  }

  Future<void> drainOutbox() async {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      final pendingTrips = await _localStore.bekleyenSeferler();
      _pendingCountController.add(pendingTrips.length);
      for (final row in pendingTrips) {
        await _syncTrip(row);
      }

      final pendingStops = await _localStore.bekleyenDuraklar();
      for (final row in pendingStops) {
        await _syncStop(row);
      }

      final kalan = await _localStore.bekleyenSeferVeDurakSayisi();
      _pendingCountController.add(kalan);
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncTrip(TripsCacheData row) async {
    try {
      final trip = Trip(
        id: row.serverId ?? '',
        clientTripId: row.clientTripId,
        driverId: row.driverId,
        vehicleId: row.vehicleId,
        tarih: row.tarih,
        fabrikaCikisAt: row.fabrikaCikisAt,
        fabrikaGirisAt: row.fabrikaGirisAt,
      );
      final saved = await _tripRepository.upsertTrip(trip);
      await _localStore.senkronizeIsaretle(row.clientTripId, serverId: saved.id);
    } catch (e) {
      await _localStore.senkronizasyonHatasi(row.clientTripId, e.toString());
    }
  }

  Future<void> _syncStop(TripStopsCacheData row) async {
    try {
      final tripServerId = await _localStore.seferSunucuIdGetir(row.clientTripId);
      if (tripServerId == null) {
        // Ait oldugu sefer henuz senkronize olmadi; bir sonraki denemede tekrar bakilir.
        return;
      }
      final stop = TripStop(
        id: row.serverId ?? '',
        clientStopId: row.clientStopId,
        tripId: tripServerId,
        sira: row.sira,
        firmaGirisAt: row.firmaGirisAt,
        tripTypeId: row.tripTypeId,
        requesterId: row.requesterId,
        cikisNedeni: row.cikisNedeni,
        gidilenIl: row.gidilenIl,
        gidilenIlce: row.gidilenIlce,
        gidilenSirketId: row.gidilenSirketId,
        gidilenSirketFree: row.gidilenSirketFree,
        irsaliyeNo: row.irsaliyeNo,
        firmaCikisAt: row.firmaCikisAt,
        notlar: row.notlar,
      );
      final saved = await _tripRepository.upsertTripStop(stop);
      await _localStore.stopSenkronizeIsaretle(row.clientStopId, serverId: saved.id);
    } catch (e) {
      await _localStore.stopSenkronizasyonHatasi(row.clientStopId, e.toString());
    }
  }
}
