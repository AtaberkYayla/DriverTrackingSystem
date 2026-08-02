import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../local/app_database.dart';
import '../local/local_store.dart';
import '../location/location_service.dart';
import '../sync/sync_service.dart';
import '../update/update_info.dart';
import '../update/update_service.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final localStoreProvider = Provider<LocalStore>((ref) {
  return LocalStore(ref.watch(appDatabaseProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());

final tripRepositoryProvider = Provider<TripRepository>((ref) => TripRepository());

final masterDataRepositoryProvider =
    Provider<MasterDataRepository>((ref) => MasterDataRepository());

final locationRepositoryProvider = Provider<LocationRepository>((ref) => LocationRepository());

/// Ilk okundugunda periyodik konum gonderimini baslatir (bkz. LocationService) -
/// tetikleme noktasi icin ActiveTripScreen'deki ref.watch(locationServiceProvider).
final locationServiceProvider = Provider<LocationService>((ref) {
  final service = LocationService(locationRepository: ref.watch(locationRepositoryProvider));
  service.start();
  ref.onDispose(service.dispose);
  return service;
});

final syncServiceProvider = Provider<SyncService>((ref) {
  final service = SyncService(
    localStore: ref.watch(localStoreProvider),
    tripRepository: ref.watch(tripRepositoryProvider),
    masterDataRepository: ref.watch(masterDataRepositoryProvider),
  );
  service.start();
  ref.onDispose(service.dispose);
  return service;
});

final pendingSyncCountProvider = StreamProvider<int>((ref) {
  return ref.watch(syncServiceProvider).pendingCountStream;
});

final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authRepositoryProvider).onAuthStateChange;
});

final currentProfileProvider = FutureProvider<Profile?>((ref) async {
  ref.watch(authStateChangesProvider);
  return ref.watch(authRepositoryProvider).fetchCurrentProfile();
});

final turkeyLocationsProvider = FutureProvider<TurkeyLocations>((ref) {
  return TurkeyLocations.load();
});

final activeTripProvider = StreamProvider.family<TripsCacheData?, String>((ref, driverId) {
  return ref.watch(localStoreProvider).aktifSeferIzle(driverId);
});

/// Verilen sefere (clientTripId) ait, henuz "Firma Cikis" yapilmamis
/// (acik) durak varsa onu yayinlar; sofor su an bir firmanin icindeyse
/// bunu belirlemek icin kullanilir.
final openStopProvider = StreamProvider.family<TripStopsCacheData?, String>((ref, clientTripId) {
  return ref.watch(localStoreProvider).acikDurakIzle(clientTripId);
});

final stopsForTripProvider =
    StreamProvider.family<List<TripStopsCacheData>, String>((ref, clientTripId) {
  return ref.watch(localStoreProvider).duraklariIzle(clientTripId);
});

/// Uygulama acilista/oturum sonrasi master veriyi (araclar, sefer turleri,
/// talep edenler, sirketler) sunucudan cekip yerel onbellege yazar.
final masterDataRefreshProvider = FutureProvider<void>((ref) {
  return ref.watch(syncServiceProvider).refreshMasterData();
});

final vehiclesProvider = FutureProvider<List<VehiclesCacheData>>((ref) async {
  await ref.watch(masterDataRefreshProvider.future);
  return ref.watch(localStoreProvider).araclar();
});

final tripTypesProvider = FutureProvider<List<TripTypesCacheData>>((ref) async {
  await ref.watch(masterDataRefreshProvider.future);
  return ref.watch(localStoreProvider).seferTurleri();
});

final requestersProvider = FutureProvider<List<RequestersCacheData>>((ref) async {
  await ref.watch(masterDataRefreshProvider.future);
  return ref.watch(localStoreProvider).talepEdenler();
});

final companiesProvider = FutureProvider<List<CompaniesCacheData>>((ref) async {
  await ref.watch(masterDataRefreshProvider.future);
  return ref.watch(localStoreProvider).sirketler();
});

/// `env/api.json`'daki `APK_VERSION_URL` - main.dart'ta gercek degerle
/// override edilir (bkz. initApiClient'in yanindaki env okuma).
final apkVersionUrlProvider = Provider<String>((ref) => '');

final updateServiceProvider = Provider<UpdateService>((ref) => const UpdateService());

/// Uygulama acilisinda bir kez calisip daha yeni bir surum olup olmadigini
/// kontrol eder (bkz. update_service.dart) - sadece Android'de anlamli
/// (APK sideload akisi), baglanti/kontrol hatasinda hicbir zaman uygulamayi
/// kilitlemeden null doner.
final updateCheckProvider = FutureProvider<UpdateInfo?>((ref) async {
  if (!Platform.isAndroid) return null;
  final versionUrl = ref.watch(apkVersionUrlProvider);
  if (versionUrl.isEmpty) return null;
  final packageInfo = await PackageInfo.fromPlatform();
  final currentVersionCode = int.tryParse(packageInfo.buildNumber) ?? 0;
  return ref.watch(updateServiceProvider).checkForUpdate(
        versionUrl: versionUrl,
        currentVersionCode: currentVersionCode,
      );
});
