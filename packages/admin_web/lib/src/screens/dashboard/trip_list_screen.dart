import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/app_providers.dart';
import '../accounts/accounts_screen.dart';
import '../master_data/master_data_screen.dart';
import '../profile/my_profile_screen.dart';
import '../trip_detail/trip_detail_screen.dart';

class TripListScreen extends ConsumerWidget {
  const TripListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(tripListProvider);
    final refDataAsync = ref.watch(referenceDataProvider);
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');
    final isManagerOrAdmin = ref.watch(isManagerOrAdminProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seferler'),
        actions: [
          if (isManagerOrAdmin)
            IconButton(
              icon: const Icon(Icons.people_outline),
              tooltip: 'Kullanıcılar',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AccountsScreen()),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.storage_outlined),
            tooltip: 'Master Veri Yönetimi',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MasterDataScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profilim',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MyProfileScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış Yap',
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          const _FilterBar(),
          const Divider(height: 1),
          Expanded(
            child: refDataAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Referans veri yüklenemedi: $e')),
              data: (refData) => tripsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Seferler yüklenemedi: $e')),
                data: (trips) {
                  if (trips.isEmpty) {
                    return const Center(child: Text('Kayıtlı sefer bulunamadı.'));
                  }
                  final gruplar = _grupla(trips);
                  return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: gruplar.length,
                    itemBuilder: (context, index) =>
                        _TripGroupCard(grup: gruplar[index], refData: refData, dateFormat: dateFormat),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Duz durak listesini (her satir bir firma ziyareti) sefer (Trip)
/// bazinda gruplar; boylece ayni seferdeki birden fazla firma girisi
/// tek bir sefer karti altinda gorunur.
class _TripGroup {
  _TripGroup(this.trip) : stops = [];

  final Trip trip;
  final List<TripStop> stops;
}

List<_TripGroup> _grupla(List<TripStopWithTrip> rows) {
  final gruplar = <String, _TripGroup>{};
  final sira = <String>[];
  for (final row in rows) {
    final grup = gruplar.putIfAbsent(row.trip.id, () {
      sira.add(row.trip.id);
      return _TripGroup(row.trip);
    });
    if (row.stop != null) grup.stops.add(row.stop!);
  }
  return [for (final id in sira) gruplar[id]!];
}

class _TripGroupCard extends ConsumerWidget {
  const _TripGroupCard({required this.grup, required this.refData, required this.dateFormat});

  final _TripGroup grup;
  final ReferenceData refData;
  final DateFormat dateFormat;

  Future<void> _seferiSil(BuildContext context, WidgetRef ref) async {
    final onayVerildi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seferi Sil'),
        content: const Text(
            'Bu seferi (ve varsa tüm firma ziyaretlerini) tamamen silmek istediğinize emin misiniz? Bu işlem geri alınamaz.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İptal')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sil')),
        ],
      ),
    );
    if (onayVerildi != true) return;
    await ref.read(tripRepositoryProvider).deleteTrip(grup.trip.id);
    ref.invalidate(tripListProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trip = grup.trip;
    final isManagerOrAdmin = ref.watch(isManagerOrAdminProvider);
    final baslik = Row(
      children: [
        Expanded(flex: 2, child: Text(trip.tarih)),
        Expanded(flex: 2, child: Text(refData.aracPlakasi(trip.vehicleId))),
        Expanded(flex: 3, child: Text(refData.surucuAdi(trip.driverId))),
        Expanded(
          flex: 3,
          child: Text(
            trip.fabrikaCikisAt == null
                ? 'Fabrika Çıkış: -'
                : 'Fabrika Çıkış: ${dateFormat.format(trip.fabrikaCikisAt!)}',
          ),
        ),
        Expanded(
          flex: 2,
          child: trip.aktifMi
              ? const Chip(label: Text('Devam ediyor'))
              : const Chip(label: Text('Kapandı')),
        ),
        if (isManagerOrAdmin)
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Seferi Sil',
            onPressed: () => _seferiSil(context, ref),
          ),
      ],
    );

    if (grup.stops.isEmpty) {
      return Card(
        child: ListTile(
          title: baslik,
          subtitle: const Text('Henüz bir firmaya uğramadı (Fabrika Çıkış yapıldı, yolda).'),
        ),
      );
    }

    return Card(
      child: ExpansionTile(
        initiallyExpanded: true,
        title: baslik,
        subtitle: Text('${grup.stops.length} firma ziyareti'),
        children: grup.stops.map((stop) {
          final gidilenYer = [
            stop.gidilenIl,
            stop.gidilenIlce,
          ].where((e) => e != null && e.isNotEmpty).join(' / ');
          return ListTile(
            title: Text(gidilenYer.isEmpty ? (stop.gidilenSirketFree ?? '-') : gidilenYer),
            subtitle: Text(
              '${refData.seferTuruAdi(stop.tripTypeId)} · ${refData.talepEdenAdi(stop.requesterId)} · '
              'Giriş: ${dateFormat.format(stop.firmaGirisAt)}',
            ),
            trailing: Wrap(
              spacing: 8,
              children: [
                _OnayChip(durum: stop.onayDurumu),
                _SeferChip(durum: stop.seferDurumu),
              ],
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TripDetailScreen(stopWithTrip: TripStopWithTrip(trip: trip, stop: stop)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FilterBar extends ConsumerWidget {
  const _FilterBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(tripFiltersProvider);
    final driversAsync = ref.watch(allDriversProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          driversAsync.maybeWhen(
            data: (drivers) => DropdownButton<String?>(
              hint: const Text('Şoför'),
              value: filters.driverId,
              items: [
                const DropdownMenuItem(value: null, child: Text('Tüm şoförler')),
                ...drivers.map((d) => DropdownMenuItem(value: d.id, child: Text(d.fullName))),
              ],
              onChanged: (v) => ref.read(tripFiltersProvider.notifier).state =
                  filters.copyWith(driverId: v, clearDriver: v == null),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          DropdownButton<OnayDurumu?>(
            hint: const Text('Onay Durumu'),
            value: filters.onayDurumu,
            items: [
              const DropdownMenuItem(value: null, child: Text('Tümü')),
              ...OnayDurumu.values.map(
                (d) => DropdownMenuItem(value: d, child: Text(_onayLabel(d))),
              ),
            ],
            onChanged: (v) => ref.read(tripFiltersProvider.notifier).state =
                filters.copyWith(onayDurumu: v, clearOnay: v == null),
          ),
          DropdownButton<SeferDurumu?>(
            hint: const Text('Sefer Durumu'),
            value: filters.seferDurumu,
            items: [
              const DropdownMenuItem(value: null, child: Text('Tümü')),
              ...SeferDurumu.values.map(
                (d) => DropdownMenuItem(value: d, child: Text(_seferLabel(d))),
              ),
            ],
            onChanged: (v) => ref.read(tripFiltersProvider.notifier).state =
                filters.copyWith(seferDurumu: v, clearSefer: v == null),
          ),
          TextButton.icon(
            icon: const Icon(Icons.filter_alt_off_outlined),
            label: const Text('Filtreleri Temizle'),
            onPressed: () =>
                ref.read(tripFiltersProvider.notifier).state = const TripFilters(),
          ),
        ],
      ),
    );
  }
}

String _onayLabel(OnayDurumu d) => switch (d) {
      OnayDurumu.beklemede => 'Beklemede',
      OnayDurumu.onaylandi => 'Onaylandı',
    };

String _seferLabel(SeferDurumu d) => switch (d) {
      SeferDurumu.devamEdiyor => 'Devam Ediyor',
      SeferDurumu.basarili => 'Başarılı',
      SeferDurumu.basarisiz => 'Başarısız',
    };

class _OnayChip extends StatelessWidget {
  const _OnayChip({required this.durum});

  final OnayDurumu durum;

  @override
  Widget build(BuildContext context) {
    final onaylandi = durum == OnayDurumu.onaylandi;
    return Chip(
      label: Text(_onayLabel(durum)),
      backgroundColor: (onaylandi ? Colors.green : Colors.orange).withValues(alpha: 0.15),
      labelStyle: TextStyle(color: onaylandi ? Colors.green.shade800 : Colors.orange.shade800),
    );
  }
}

class _SeferChip extends StatelessWidget {
  const _SeferChip({required this.durum});

  final SeferDurumu durum;

  @override
  Widget build(BuildContext context) {
    final renk = switch (durum) {
      SeferDurumu.devamEdiyor => Colors.blueGrey,
      SeferDurumu.basarili => Colors.green,
      SeferDurumu.basarisiz => Colors.red,
    };
    return Chip(
      label: Text(_seferLabel(durum)),
      backgroundColor: renk.withValues(alpha: 0.15),
      labelStyle: TextStyle(color: renk.shade800),
    );
  }
}
