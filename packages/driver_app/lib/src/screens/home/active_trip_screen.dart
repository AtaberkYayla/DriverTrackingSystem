import 'package:core/core.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../local/app_database.dart';
import '../../providers/app_providers.dart';
import '../../widgets/autocomplete_options_view.dart';
import '../../widgets/sync_status_banner.dart';
import '../history/trip_history_screen.dart';
import 'trip_detail_form.dart';

class ActiveTripScreen extends ConsumerStatefulWidget {
  const ActiveTripScreen({super.key});

  @override
  ConsumerState<ActiveTripScreen> createState() => _ActiveTripScreenState();
}

class _ActiveTripScreenState extends ConsumerState<ActiveTripScreen> {
  static const _uuid = Uuid();
  VehiclesCacheData? _seciliArac;
  bool _islemDevamEdiyor = false;

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentProfileProvider);
    // Canli harita takibi icin periyodik konum gonderimini baslatir (bkz.
    // LocationService) - oturum acikken sadece bir kez olusturulup calisir.
    ref.watch(locationServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aktif Sefer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Sefer Geçmişi',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TripHistoryScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış Yap',
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Profil yüklenemedi: $e')),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('Oturum bulunamadı.'));
          }
          return Column(
            children: [
              const SyncStatusBanner(),
              Expanded(child: _icerik(profile)),
            ],
          );
        },
      ),
    );
  }

  Widget _icerik(Profile profile) {
    final activeTripAsync = ref.watch(activeTripProvider(profile.id));

    return activeTripAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Sefer bilgisi yüklenemedi: $e')),
      data: (trip) {
        if (trip == null) return _yeniSeferBaslat(profile);
        return _aktifSeferGorunumu(profile, trip);
      },
    );
  }

  Widget _yeniSeferBaslat(Profile profile) {
    final vehiclesAsync = ref.watch(vehiclesProvider);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.directions_car_outlined, size: 64),
          const SizedBox(height: 16),
          Text(
            'Aktif seferiniz yok. Aracı seçip fabrikadan çıkıyorsanız\n'
            '"Fabrika Çıkış", doğrudan bir firmaya gidiyorsanız\n'
            '"Firma Giriş" butonuna basın.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          vehiclesAsync.when(
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => Text('Araçlar yüklenemedi: $e'),
            data: (vehicles) => Autocomplete<VehiclesCacheData>(
              displayStringForOption: (v) => v.plaka,
              optionsBuilder: (value) {
                if (value.text.isEmpty) return vehicles;
                final q = value.text.toLowerCase();
                return vehicles.where((v) => v.plaka.toLowerCase().contains(q));
              },
              optionsViewBuilder: (context, onSelected, options) => buildAutocompleteOptionsView(
                options: options,
                onSelected: onSelected,
                displayStringForOption: (v) => v.plaka,
              ),
              onSelected: (v) => setState(() => _seciliArac = v),
              fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: 'Araç Plakası',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) {
                    if (_seciliArac != null && _seciliArac!.plaka != v) {
                      setState(() => _seciliArac = null);
                    }
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            icon: const Icon(Icons.factory_outlined),
            label: const Text('Fabrika Çıkış'),
            onPressed: (_seciliArac == null || _islemDevamEdiyor)
                ? null
                : () => _fabrikaCikisIleBaslat(profile),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.business_outlined),
            label: const Text('Doğrudan Firma Giriş'),
            onPressed: (_seciliArac == null || _islemDevamEdiyor)
                ? null
                : () => _firmaGirisIleBaslat(profile),
          ),
        ],
      ),
    );
  }

  String _bugunTarih(DateTime now) {
    final ay = now.month.toString().padLeft(2, '0');
    final gun = now.day.toString().padLeft(2, '0');
    return '${now.year}-$ay-$gun';
  }

  Future<void> _fabrikaCikisIleBaslat(Profile profile) async {
    setState(() => _islemDevamEdiyor = true);
    final now = DateTime.now();
    final clientTripId = _uuid.v4();
    await ref.read(localStoreProvider).upsertLocalTrip(TripsCacheCompanion.insert(
          clientTripId: clientTripId,
          driverId: profile.id,
          vehicleId: _seciliArac!.id,
          tarih: _bugunTarih(now),
          fabrikaCikisAt: Value(now),
          updatedLocallyAt: now,
        ));
    ref.read(syncServiceProvider).drainOutbox();
    if (mounted) setState(() => _islemDevamEdiyor = false);
  }

  Future<void> _firmaGirisIleBaslat(Profile profile) async {
    final vehicleId = _seciliArac!.id;
    final now = DateTime.now();
    final clientTripId = _uuid.v4();

    setState(() => _islemDevamEdiyor = true);
    await ref.read(localStoreProvider).upsertLocalTrip(TripsCacheCompanion.insert(
          clientTripId: clientTripId,
          driverId: profile.id,
          vehicleId: vehicleId,
          tarih: _bugunTarih(now),
          updatedLocallyAt: now,
        ));
    if (mounted) setState(() => _islemDevamEdiyor = false);

    if (!mounted) return;
    final sonuc = await showTripDetailForm(context);
    if (sonuc == null) {
      // Form iptal edildi; bos sefer kaydini geri al.
      await ref.read(localStoreProvider).localSeferiSil(clientTripId);
      return;
    }
    await _durakEkle(clientTripId, sonuc);
  }

  Widget _aktifSeferGorunumu(Profile profile, TripsCacheData trip) {
    final openStopAsync = ref.watch(openStopProvider(trip.clientTripId));
    final stopsAsync = ref.watch(stopsForTripProvider(trip.clientTripId));
    final dateFormat = DateFormat('HH:mm');

    return openStopAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Durak bilgisi yüklenemedi: $e')),
      data: (openStop) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sefer devam ediyor', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    if (trip.fabrikaCikisAt != null)
                      Text('Fabrika Çıkış: ${dateFormat.format(trip.fabrikaCikisAt!)}'),
                    if (trip.fabrikaCikisAt == null)
                      const Text('Fabrika Çıkış yapılmadı (doğrudan firmaya gidildi).'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            stopsAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (e, _) => Text('Duraklar yüklenemedi: $e'),
              data: (stops) => Column(
                children: stops
                    .map((s) => Card(
                          child: ListTile(
                            leading: Icon(
                              s.firmaCikisAt == null ? Icons.pending_outlined : Icons.check_circle_outline,
                              color: s.firmaCikisAt == null ? Colors.orange : Colors.green,
                            ),
                            title: Text(s.gidilenSirketFree ?? '${s.sira}. durak'),
                            subtitle: Text(
                              s.firmaCikisAt == null
                                  ? 'Giriş: ${dateFormat.format(s.firmaGirisAt)} - hâlâ içeride'
                                  : 'Giriş: ${dateFormat.format(s.firmaGirisAt)} - Çıkış: ${dateFormat.format(s.firmaCikisAt!)}',
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 24),
            if (openStop != null)
              FilledButton(
                onPressed: _islemDevamEdiyor ? null : () => _firmaCikisYap(trip, openStop),
                child: const Text('Firma Çıkış'),
              )
            else ...[
              FilledButton.icon(
                icon: const Icon(Icons.business_outlined),
                label: const Text('Firma Giriş'),
                onPressed: _islemDevamEdiyor ? null : () => _firmaGirisYap(trip),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.factory_outlined),
                label: const Text('Fabrika Giriş (Seferi Bitir)'),
                onPressed: _islemDevamEdiyor ? null : () => _fabrikaGirisYap(trip),
              ),
            ],
          ],
        );
      },
    );
  }

  Future<void> _firmaGirisYap(TripsCacheData trip) async {
    final sonuc = await showTripDetailForm(context);
    if (sonuc == null) return;
    await _durakEkle(trip.clientTripId, sonuc);
  }

  Future<void> _durakEkle(String clientTripId, TripDetailFormResult sonuc) async {
    setState(() => _islemDevamEdiyor = true);
    final now = DateTime.now();
    final sira = await ref.read(localStoreProvider).sonrakiDurakSirasi(clientTripId);
    await ref.read(localStoreProvider).upsertLocalStop(TripStopsCacheCompanion.insert(
          clientStopId: _uuid.v4(),
          clientTripId: clientTripId,
          sira: sira,
          firmaGirisAt: now,
          tripTypeId: Value(sonuc.tripTypeId),
          requesterId: Value(sonuc.requesterId),
          cikisNedeni: Value(sonuc.cikisNedeni),
          gidilenIl: Value(sonuc.gidilenIl),
          gidilenIlce: Value(sonuc.gidilenIlce),
          gidilenSirketId: Value(sonuc.gidilenSirketId),
          gidilenSirketFree: Value(sonuc.gidilenSirketFree),
          irsaliyeNoGiris: Value(sonuc.irsaliyeNoGiris),
          notlar: Value(sonuc.notlar),
          updatedLocallyAt: now,
        ));
    ref.read(syncServiceProvider).drainOutbox();
    if (mounted) setState(() => _islemDevamEdiyor = false);
  }

  Future<void> _firmaCikisYap(TripsCacheData trip, TripStopsCacheData openStop) async {
    var irsaliyeNoCikis = openStop.irsaliyeNoCikis;
    final tripTypes = await ref.read(tripTypesProvider.future);
    TripTypesCacheData? tripType;
    for (final t in tripTypes) {
      if (t.id == openStop.tripTypeId) {
        tripType = t;
        break;
      }
    }
    // İrsaliye no zorunlu değil, ama bu 3 sefer türünde yine de sorulur -
    // sofor isterse boş geçebilir.
    if (tripType?.requiresIrsaliye ?? false) {
      if (!mounted) return;
      irsaliyeNoCikis = await _irsaliyeNoIste(context, mevcut: irsaliyeNoCikis);
    }

    setState(() => _islemDevamEdiyor = true);
    final now = DateTime.now();
    await ref.read(localStoreProvider).upsertLocalStop(TripStopsCacheCompanion(
          clientStopId: Value(openStop.clientStopId),
          clientTripId: Value(openStop.clientTripId),
          sira: Value(openStop.sira),
          firmaGirisAt: Value(openStop.firmaGirisAt),
          tripTypeId: Value(openStop.tripTypeId),
          requesterId: Value(openStop.requesterId),
          cikisNedeni: Value(openStop.cikisNedeni),
          gidilenIl: Value(openStop.gidilenIl),
          gidilenIlce: Value(openStop.gidilenIlce),
          gidilenSirketId: Value(openStop.gidilenSirketId),
          gidilenSirketFree: Value(openStop.gidilenSirketFree),
          irsaliyeNoGiris: Value(openStop.irsaliyeNoGiris),
          irsaliyeNoCikis: Value(irsaliyeNoCikis),
          notlar: Value(openStop.notlar),
          firmaCikisAt: Value(now),
          synced: const Value(false),
          updatedLocallyAt: Value(now),
        ));
    ref.read(syncServiceProvider).drainOutbox();
    if (mounted) setState(() => _islemDevamEdiyor = false);
  }

  /// İrsaliye no zorunlu değildir - sofor "Boş Geç" ile atlayabilir ya da
  /// pencereyi kapatabilir, her durumda firma çıkışı normal şekilde devam eder.
  Future<String?> _irsaliyeNoIste(BuildContext context, {String? mevcut}) {
    final controller = TextEditingController(text: mevcut ?? '');
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İrsaliye No (Çıkış)'),
        content: TextFormField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'İrsaliye No',
            helperText: 'Biliyorsanız girin, zorunlu değil',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Boş Geç'),
          ),
          FilledButton(
            onPressed: () {
              final text = controller.text.trim();
              Navigator.of(context).pop(text.isEmpty ? null : text);
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  Future<void> _fabrikaGirisYap(TripsCacheData trip) async {
    setState(() => _islemDevamEdiyor = true);
    final now = DateTime.now();
    await ref.read(localStoreProvider).upsertLocalTrip(TripsCacheCompanion(
          clientTripId: Value(trip.clientTripId),
          driverId: Value(trip.driverId),
          vehicleId: Value(trip.vehicleId),
          tarih: Value(trip.tarih),
          fabrikaCikisAt: Value(trip.fabrikaCikisAt),
          fabrikaGirisAt: Value(now),
          synced: const Value(false),
          updatedLocallyAt: Value(now),
        ));
    ref.read(syncServiceProvider).drainOutbox();
    if (mounted) setState(() => _islemDevamEdiyor = false);
  }
}
