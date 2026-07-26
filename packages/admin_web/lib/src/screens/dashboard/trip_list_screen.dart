import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/app_providers.dart';
import '../master_data/master_data_screen.dart';
import '../trip_detail/trip_detail_screen.dart';

class TripListScreen extends ConsumerWidget {
  const TripListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(tripListProvider);
    final refDataAsync = ref.watch(referenceDataProvider);
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seferler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.storage_outlined),
            tooltip: 'Master Veri Yonetimi',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MasterDataScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(tripListProvider);
              ref.invalidate(referenceDataProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cikis Yap',
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
              error: (e, _) => Center(child: Text('Referans veri yuklenemedi: $e')),
              data: (refData) => tripsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Seferler yuklenemedi: $e')),
                data: (trips) {
                  if (trips.isEmpty) {
                    return const Center(child: Text('Kayitli sefer bulunamadi.'));
                  }
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Tarih')),
                        DataColumn(label: Text('Plaka')),
                        DataColumn(label: Text('Sofor')),
                        DataColumn(label: Text('Seyahat Turu')),
                        DataColumn(label: Text('Talep Eden')),
                        DataColumn(label: Text('Gidilen Yer')),
                        DataColumn(label: Text('Firma Giris')),
                        DataColumn(label: Text('Onay Durumu')),
                        DataColumn(label: Text('Sefer Durumu')),
                      ],
                      rows: trips.map((row) {
                        final stop = row.stop;
                        final gidilenYer = [
                          stop.gidilenIl,
                          stop.gidilenIlce,
                        ].where((e) => e != null && e.isNotEmpty).join(' / ');
                        return DataRow(
                          onSelectChanged: (_) => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => TripDetailScreen(stopWithTrip: row)),
                          ),
                          cells: [
                            DataCell(Text(row.trip.tarih)),
                            DataCell(Text(refData.aracPlakasi(row.trip.vehicleId))),
                            DataCell(Text(refData.surucuAdi(row.trip.driverId))),
                            DataCell(Text(refData.seferTuruAdi(stop.tripTypeId))),
                            DataCell(Text(refData.talepEdenAdi(stop.requesterId))),
                            DataCell(Text(gidilenYer.isEmpty
                                ? (stop.gidilenSirketFree ?? '-')
                                : gidilenYer)),
                            DataCell(Text(dateFormat.format(stop.firmaGirisAt))),
                            DataCell(_OnayChip(durum: stop.onayDurumu)),
                            DataCell(_SeferChip(durum: stop.seferDurumu)),
                          ],
                        );
                      }).toList(),
                    ),
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
              hint: const Text('Sofor'),
              value: filters.driverId,
              items: [
                const DropdownMenuItem(value: null, child: Text('Tum soforler')),
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
              const DropdownMenuItem(value: null, child: Text('Tumu')),
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
              const DropdownMenuItem(value: null, child: Text('Tumu')),
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
      OnayDurumu.onaylandi => 'Onaylandi',
    };

String _seferLabel(SeferDurumu d) => switch (d) {
      SeferDurumu.devamEdiyor => 'Devam Ediyor',
      SeferDurumu.basarili => 'Basarili',
      SeferDurumu.basarisiz => 'Basarisiz',
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
