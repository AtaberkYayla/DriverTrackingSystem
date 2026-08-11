import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());

final tripRepositoryProvider = Provider<TripRepository>((ref) => TripRepository());

final masterDataRepositoryProvider =
    Provider<MasterDataRepository>((ref) => MasterDataRepository());

final accountRepositoryProvider = Provider<AccountRepository>((ref) => AccountRepository());

final mailSettingsRepositoryProvider =
    Provider<MailSettingsRepository>((ref) => MailSettingsRepository());

final locationRepositoryProvider = Provider<LocationRepository>((ref) => LocationRepository());

final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authRepositoryProvider).onAuthStateChange;
});

final currentProfileProvider = FutureProvider<Profile?>((ref) async {
  ref.watch(authStateChangesProvider);
  return ref.watch(authRepositoryProvider).fetchCurrentProfile();
});

/// Yonetici veya admin mi? Kullanici yonetimi, master data duzenleme/silme
/// ve sefer duzeltme/silme gibi islemler bu role gore acilir/kapanir.
final isManagerOrAdminProvider = Provider<bool>((ref) {
  final profile = ref.watch(currentProfileProvider).value;
  return profile != null && (profile.role == AppRole.manager || profile.role == AppRole.admin);
});

/// Sistem admini mi? Sadece admin baska yonetici/admin hesabi olusturup
/// duzenleyebilir.
final isAdminProvider = Provider<bool>((ref) {
  final profile = ref.watch(currentProfileProvider).value;
  return profile?.role == AppRole.admin;
});

/// Sadece yonetici mi (admin haric)? Master Veri Yonetimi ekrani
/// yoneticiden gizlenir; orada duzenleyebilecegi/yapabilecegi bir sey yoktur.
final isManagerProvider = Provider<bool>((ref) {
  final profile = ref.watch(currentProfileProvider).value;
  return profile?.role == AppRole.manager;
});

/// Onay Verici (office) hesabi artik olusturulmuyor (bkz. backend/README.md) -
/// bu provider hep false doner, geriye donuk uyumluluk icin duruyor.
final isOfficeProvider = Provider<bool>((ref) {
  final profile = ref.watch(currentProfileProvider).value;
  return profile?.role == AppRole.office;
});

/// Operator mu? Sadece admin_web'den elle sefer olusturup (yalnizca kendi
/// olusturdugu seferleri) duzenleyebilir ve rapor olusturabilir - hesap
/// yonetimi, master veri, mail ayarlari ve canli konuma erisemez.
final isOperatorProvider = Provider<bool>((ref) {
  final profile = ref.watch(currentProfileProvider).value;
  return profile?.role == AppRole.operator;
});

final accountsProvider = FutureProvider<List<Account>>((ref) {
  return ref.watch(accountRepositoryProvider).listAccounts();
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

final companiesProvider = FutureProvider<List<Company>>((ref) {
  return ref.watch(masterDataRepositoryProvider).fetchCompanies(sadeceAktif: false);
});

final turkeyLocationsProvider = FutureProvider<TurkeyLocations>((ref) {
  return TurkeyLocations.load();
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

/// Saat bilgisi olmadan bugunun tarihi; sefer listesi varsayilan olarak
/// bu gune filtrelenir (kullanici baska bir gun secebilir).
DateTime bugununTarihi() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

final tripFiltersProvider = StateProvider<TripFilters>(
  (ref) => TripFilters(baslangic: bugununTarihi(), bitis: bugununTarihi()),
);

/// PHP/MySQL backend'inde Postgres Realtime'in karsiligi yok (SSH/root
/// olmadan websocket sunucusu kurulamaz) - bunun yerine sefer listesi
/// periyodik polling ile tazelenir. Eskiden 6 saniyede birdi; sunucuyu
/// gereksiz yordugu icin varsayilan 30 dakikaya cikarildi - anlik guncelleme
/// icin ekrandaki manuel yenile butonu kullanilir (bkz. trip_list_screen).
final tripListAutoRefreshTickProvider = StreamProvider.autoDispose<int>((ref) {
  return Stream.periodic(const Duration(minutes: 30), (i) => i);
});

/// Canli harita icin ayri ve daha sik bir tik: konum takibi "canli" hissi
/// vermesi gerektigi icin sefer listesinden daha kisa tutuldu, ama yine de
/// eski 6 saniyeden cok daha seyrek (5 dakika) - anlik guncelleme icin
/// haritadaki manuel yenile butonu kullanilir (bkz. live_map_screen).
final mapAutoRefreshTickProvider = StreamProvider.autoDispose<int>((ref) {
  return Stream.periodic(const Duration(minutes: 5), (i) => i);
});

// Onay Verici (office) hesabi kaldirildigindan (bkz. isOfficeProvider)
// admin_web'e giren herkes (yonetici/admin) her seferi gorebilir; talep
// eden bazli kisitlama artik gerekmiyor.
final tripListProvider = FutureProvider.autoDispose<List<TripStopWithTrip>>((ref) async {
  ref.watch(tripListAutoRefreshTickProvider);
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

final mailSettingsProvider = FutureProvider<MailSettings>((ref) {
  return ref.watch(mailSettingsRepositoryProvider).fetch();
});

/// Canli harita ekrani icin - kendi (5 dakikalik) polling ritmini kullanir
/// (bkz. mapAutoRefreshTickProvider).
final driverLocationsProvider = FutureProvider.autoDispose<List<DriverLocation>>((ref) {
  ref.watch(mapAutoRefreshTickProvider);
  return ref.watch(locationRepositoryProvider).fetchDriverLocations();
});

final allDriversProvider = FutureProvider<List<Profile>>((ref) async {
  final rows = await api.get('/accounts_drivers.php') as List;
  return rows.cast<Map<String, dynamic>>().map((row) {
    return Profile(id: row['id'] as String, fullName: row['full_name'] as String, role: AppRole.driver);
  }).toList();
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
  ref.watch(tripListAutoRefreshTickProvider);
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
