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
    final isManager = ref.watch(isManagerProvider);

    // Onceki basariyla yuklenen veriyi elde tutup sadece arka planda tazeler;
    // boylece 1 dakikalik otomatik yenilemede tum liste CircularProgressIndicator
    // ile degistirilip ekran "titremez" - sadece ince bir yenileme cubugu gorunur.
    final refData = refDataAsync.value;
    final trips = tripsAsync.value;
    final ilkYukleme = refData == null || trips == null;
    final arkaPlandaYenileniyor =
        !ilkYukleme && (tripsAsync.isLoading || refDataAsync.isLoading);
    final hata = tripsAsync.error ?? refDataAsync.error;

    Widget body;
    if (ilkYukleme) {
      body = hata != null
          ? Center(child: Text('Veri yüklenemedi: $hata'))
          : const Center(child: CircularProgressIndicator());
    } else if (trips.isEmpty) {
      body = const Center(child: Text('Kayıtlı sefer bulunamadı.'));
    } else {
      final gruplar = _grupla(trips);
      body = ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: gruplar.length,
        itemBuilder: (context, index) =>
            _TripGroupCard(grup: gruplar[index], refData: refData, dateFormat: dateFormat),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(DedemBrand.faviconAssetPath, package: 'core', height: 28),
            const SizedBox(width: 12),
            const Text('Seferler'),
          ],
        ),
        actions: [
          if (isManagerOrAdmin)
            IconButton(
              icon: const Icon(Icons.people_outline),
              tooltip: 'Kullanıcılar',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AccountsScreen()),
              ),
            ),
          if (!isManager)
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
          if (arkaPlandaYenileniyor) const LinearProgressIndicator(minHeight: 2),
          const Divider(height: 1),
          Expanded(child: body),
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

  Future<void> _hizliOnayla(BuildContext context, WidgetRef ref, TripStop stop) async {
    final onayVerildi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ziyareti Onayla'),
        content: const Text('Bu firma ziyaretini onaylamak istediğinize emin misiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İptal')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Onayla')),
        ],
      ),
    );
    if (onayVerildi != true) return;
    final profile = await ref.read(currentProfileProvider.future);
    if (profile == null) return;
    await ref.read(tripRepositoryProvider).updateApproval(
          stopId: stop.id,
          onayDurumu: OnayDurumu.onaylandi,
          onaylayanId: profile.id,
          seferDurumu: stop.seferDurumu,
        );
    ref.invalidate(tripListProvider);
  }

  String _fabrikaOzet(Trip trip) {
    if (trip.fabrikaCikisAt == null) return 'Fabrika Çıkış: -';
    final cikis = 'Çıkış: ${dateFormat.format(trip.fabrikaCikisAt!)}';
    if (trip.fabrikaGirisAt == null) return cikis;
    return '$cikis  →  Giriş: ${dateFormat.format(trip.fabrikaGirisAt!)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trip = grup.trip;
    final isManagerOrAdmin = ref.watch(isManagerOrAdminProvider);
    final onayVerebilir = isManagerOrAdmin || ref.watch(isOfficeProvider);
    final aktif = trip.aktifMi;
    final durumRengi = aktif ? Colors.blue : Colors.green;

    final baslik = Row(
      children: [
        Icon(Icons.calendar_today_outlined, size: 15, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Expanded(
          flex: 2,
          child: Text(trip.tarih, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        Icon(Icons.local_shipping_outlined, size: 15, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Expanded(flex: 2, child: Text(refData.aracPlakasi(trip.vehicleId))),
        Icon(Icons.person_outline, size: 15, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Expanded(flex: 3, child: Text(refData.surucuAdi(trip.driverId))),
        Expanded(
          flex: 4,
          child: Text(
            _fabrikaOzet(trip),
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
          ),
        ),
        Chip(
          avatar: Icon(
            aktif ? Icons.autorenew : Icons.check_circle_outline,
            size: 16,
            color: durumRengi.shade800,
          ),
          label: Text(aktif ? 'Devam ediyor' : 'Kapandı'),
          labelStyle: TextStyle(color: durumRengi.shade800, fontWeight: FontWeight.w600),
          backgroundColor: durumRengi.withValues(alpha: 0.12),
          visualDensity: VisualDensity.compact,
          side: BorderSide.none,
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
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: durumRengi.withValues(alpha: 0.3)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: baslik,
          subtitle: trip.fabrikaCikisAt != null
              ? const Text('Firma girişi bekleniyor · henüz bir firmaya uğramadı.')
              : const Text('Henüz bir firmaya uğramadı (Fabrika Çıkış yapıldı, yolda).'),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: durumRengi.withValues(alpha: 0.3)),
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: baslik,
        subtitle: Text('${grup.stops.length} firma ziyareti'),
        children: grup.stops.map((stop) {
          final firmaAdi = stop.gidilenSirketId != null
              ? refData.sirketAdi(stop.gidilenSirketId)
              : (stop.gidilenSirketFree ?? '-');
          final gidilenYer = [
            stop.gidilenIl,
            stop.gidilenIlce,
          ].where((e) => e != null && e.isNotEmpty).join(' / ');
          final altBilgi = [
            if (gidilenYer.isNotEmpty) gidilenYer,
            refData.seferTuruAdi(stop.tripTypeId),
            refData.talepEdenAdi(stop.requesterId),
            'Giriş: ${dateFormat.format(stop.firmaGirisAt)}',
            if (stop.firmaCikisAt != null) 'Çıkış: ${dateFormat.format(stop.firmaCikisAt!)}',
          ].join(' · ');
          final hizliOnaylanabilir = onayVerebilir && stop.onayDurumu == OnayDurumu.beklemede;

          return ListTile(
            title: Text(firmaAdi, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(altBilgi),
            trailing: Wrap(
              spacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _OnayChip(durum: stop.onayDurumu),
                _SeferChip(durum: stop.seferDurumu),
                if (hizliOnaylanabilir)
                  IconButton(
                    icon: Icon(Icons.check_circle_outline, color: Colors.green.shade700),
                    tooltip: 'Hızlı Onayla',
                    onPressed: () => _hizliOnayla(context, ref, stop),
                  ),
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

  Future<void> _tarihSec(BuildContext context, WidgetRef ref, TripFilters filters) async {
    final secilen = await showDatePicker(
      context: context,
      initialDate: filters.baslangic ?? bugununTarihi(),
      firstDate: DateTime(2024),
      lastDate: bugununTarihi().add(const Duration(days: 365)),
      helpText: 'Sefer Tarihi',
    );
    if (secilen == null) return;
    ref.read(tripFiltersProvider.notifier).state =
        filters.copyWith(baslangic: secilen, bitis: secilen);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(tripFiltersProvider);
    final driversAsync = ref.watch(allDriversProvider);
    final dateFormat = DateFormat('dd.MM.yyyy');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          OutlinedButton.icon(
            icon: const Icon(Icons.calendar_today_outlined, size: 16),
            label: Text(
              filters.baslangic != null ? dateFormat.format(filters.baslangic!) : 'Tarih Seç',
            ),
            onPressed: () => _tarihSec(context, ref, filters),
          ),
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
            onPressed: () => ref.read(tripFiltersProvider.notifier).state =
                TripFilters(baslangic: bugununTarihi(), bitis: bugununTarihi()),
          ),
        ],
      ),
    );
  }
}

String _onayLabel(OnayDurumu d) => switch (d) {
      OnayDurumu.beklemede => 'Onay Bekleniyor',
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
