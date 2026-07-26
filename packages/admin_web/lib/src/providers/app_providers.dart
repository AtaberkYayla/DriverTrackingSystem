import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthState;

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());

final tripRepositoryProvider = Provider<TripRepository>((ref) => TripRepository());

final masterDataRepositoryProvider =
    Provider<MasterDataRepository>((ref) => MasterDataRepository());

final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authRepositoryProvider).onAuthStateChange;
});

final currentProfileProvider = FutureProvider<Profile?>((ref) async {
  ref.watch(authStateChangesProvider);
  return ref.watch(authRepositoryProvider).fetchCurrentProfile();
});

final vehiclesProvider = FutureProvider<List<Vehicle>>((ref) {
  return ref.watch(masterDataRepositoryProvider).fetchVehicles(sadeceAktif: false);
});

final tripTypesProvider = FutureProvider<List<TripType>>((ref) {
  return ref.watch(masterDataRepositoryProvider).fetchTripTypes(sadeceAktif: false);
});

final requestersProvider = FutureProvider<List<Requester>>((ref) {
  return ref.watch(masterDataRepositoryProvider).fetchRequesters(sadeceAktif: false);
});

final managersProvider = FutureProvider<List<Manager>>((ref) {
  return ref.watch(masterDataRepositoryProvider).fetchManagers(sadeceAktif: false);
});

final companiesProvider = FutureProvider<List<Company>>((ref) {
  return ref.watch(masterDataRepositoryProvider).fetchCompanies(sadeceAktif: false);
});

class TripFilters {
  const TripFilters({
    this.driverId,
    this.vehicleId,
    this.onayDurumu,
    this.seferDurumu,
    this.baslangic,
    this.bitis,
  });

  final String? driverId;
  final String? vehicleId;
  final OnayDurumu? onayDurumu;
  final SeferDurumu? seferDurumu;
  final DateTime? baslangic;
  final DateTime? bitis;

  TripFilters copyWith({
    String? driverId,
    String? vehicleId,
    OnayDurumu? onayDurumu,
    SeferDurumu? seferDurumu,
    DateTime? baslangic,
    DateTime? bitis,
    bool clearDriver = false,
    bool clearVehicle = false,
    bool clearOnay = false,
    bool clearSefer = false,
    bool clearBaslangic = false,
    bool clearBitis = false,
  }) {
    return TripFilters(
      driverId: clearDriver ? null : (driverId ?? this.driverId),
      vehicleId: clearVehicle ? null : (vehicleId ?? this.vehicleId),
      onayDurumu: clearOnay ? null : (onayDurumu ?? this.onayDurumu),
      seferDurumu: clearSefer ? null : (seferDurumu ?? this.seferDurumu),
      baslangic: clearBaslangic ? null : (baslangic ?? this.baslangic),
      bitis: clearBitis ? null : (bitis ?? this.bitis),
    );
  }
}

final tripFiltersProvider = StateProvider<TripFilters>((ref) => const TripFilters());

final tripListProvider = FutureProvider.autoDispose<List<TripStopWithTrip>>((ref) {
  final filters = ref.watch(tripFiltersProvider);
  return ref.watch(tripRepositoryProvider).fetchAllStopsWithTrip(
        driverId: filters.driverId,
        vehicleId: filters.vehicleId,
        onayDurumu: filters.onayDurumu,
        seferDurumu: filters.seferDurumu,
        baslangic: filters.baslangic,
        bitis: filters.bitis,
      );
});

final allDriversProvider = FutureProvider<List<Profile>>((ref) async {
  final rows = await supabase.from('profiles').select().eq('role', 'driver');
  return rows.map(Profile.fromJson).toList();
});

/// Sefer listesinde id'leri okunabilir isimlere cevirmek icin kullanilan
/// referans veri haritalari.
class ReferenceData {
  const ReferenceData({
    required this.suruculer,
    required this.araclar,
    required this.seferTurleri,
    required this.talepEdenler,
    required this.sirketler,
  });

  final Map<String, String> suruculer;
  final Map<String, String> araclar;
  final Map<String, TripType> seferTurleri;
  final Map<String, String> talepEdenler;
  final Map<String, String> sirketler;

  String surucuAdi(String id) => suruculer[id] ?? id;
  String aracPlakasi(String id) => araclar[id] ?? id;
  String seferTuruAdi(String? id) => id == null ? '-' : (seferTurleri[id]?.label ?? id);
  String talepEdenAdi(String? id) => id == null ? '-' : (talepEdenler[id] ?? id);
  String sirketAdi(String? id) => id == null ? '-' : (sirketler[id] ?? id);
}

final referenceDataProvider = FutureProvider<ReferenceData>((ref) async {
  final drivers = await ref.watch(allDriversProvider.future);
  final vehicles = await ref.watch(vehiclesProvider.future);
  final tripTypes = await ref.watch(tripTypesProvider.future);
  final requesters = await ref.watch(requestersProvider.future);
  final companies = await ref.watch(companiesProvider.future);

  return ReferenceData(
    suruculer: {for (final d in drivers) d.id: d.fullName},
    araclar: {for (final v in vehicles) v.id: v.plaka},
    seferTurleri: {for (final t in tripTypes) t.id: t},
    talepEdenler: {for (final r in requesters) r.id: r.fullName},
    sirketler: {for (final c in companies) c.id: c.name},
  );
});
