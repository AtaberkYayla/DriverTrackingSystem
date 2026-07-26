import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthState;

import '../local/app_database.dart';
import '../local/local_store.dart';
import '../sync/sync_service.dart';

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
