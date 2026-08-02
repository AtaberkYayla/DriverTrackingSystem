import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../providers/app_providers.dart';
import '../../widgets/tarih_saat_secici.dart';

const _uuid = Uuid();
final _dateFormat = DateFormat('dd.MM.yyyy HH:mm');

/// Bir şoförün tüm seferlerini (tarih filtresi olmadan) çekip sefer id'sine
/// göre tekilleştirir; `trips_list.php` her durak için ayrı bir satır
/// döndürdüğünden (bkz. TripRepository.fetchAllStopsWithTrip) aynı sefer
/// birden fazla kez gelebilir.
Future<({Map<String, Trip> tripler, Map<String, int> durakSayilari})> _soforunSeferleri(
  WidgetRef ref,
  String driverId,
) async {
  final rows = await ref
      .read(tripRepositoryProvider)
      .fetchAllStopsWithTrip(driverId: driverId, limit: 500);
  final tripler = <String, Trip>{};
  final durakSayilari = <String, int>{};
  for (final row in rows) {
    tripler[row.trip.id] = row.trip;
    if (row.stop != null) {
      durakSayilari[row.trip.id] = (durakSayilari[row.trip.id] ?? 0) + 1;
    }
  }
  return (tripler: tripler, durakSayilari: durakSayilari);
}

/// Verilen zaman anında açık olan (fabrika çıkışı yapılmış, henüz fabrika
/// girişi olmamış ya da girişi bu zamandan sonra olan) seferi bulur;
/// birden fazlaysa en yakın zamanda çıkış yapılanı seçer.
Trip? _oAndaAcikSeferiBul(Map<String, Trip> tripler, DateTime zaman) {
  Trip? bulunan;
  for (final trip in tripler.values) {
    final cikis = trip.fabrikaCikisAt;
    if (cikis == null || cikis.isAfter(zaman)) continue;
    final giris = trip.fabrikaGirisAt;
    if (giris != null && giris.isBefore(zaman)) continue;
    if (bulunan == null || cikis.isAfter(bulunan.fabrikaCikisAt!)) bulunan = trip;
  }
  return bulunan;
}

/// Şoförün şu an açık (henüz fabrika girişi yapılmamış) en güncel seferi.
Trip? _acikSeferiBul(Map<String, Trip> tripler) {
  final acikSeferler = tripler.values.where((t) => t.aktifMi).toList()
    ..sort((a, b) {
      final ac = a.fabrikaCikisAt;
      final bc = b.fabrikaCikisAt;
      if (ac == null && bc == null) return 0;
      if (ac == null) return 1;
      if (bc == null) return -1;
      return bc.compareTo(ac);
    });
  return acikSeferler.isEmpty ? null : acikSeferler.first;
}

Future<void> showDurakEkleDialog(BuildContext context, WidgetRef ref) {
  return showDialog<void>(context: context, builder: (context) => const _DurakEkleDialog());
}

Future<void> showFabrikaBolmeDialog(BuildContext context, WidgetRef ref) {
  return showDialog<void>(context: context, builder: (context) => const _FabrikaBolmeDialog());
}

/// Sefer listesinin üstündeki genel "Durak Ekle" hızlı işlemi: hangi
/// sefere ait olduğu seçilmez, şoför + zaman girilince o an açık olan
/// sefer otomatik bulunup durak oraya eklenir (bkz. plan md §5).
class _DurakEkleDialog extends ConsumerStatefulWidget {
  const _DurakEkleDialog();

  @override
  ConsumerState<_DurakEkleDialog> createState() => _DurakEkleDialogState();
}

class _DurakEkleDialogState extends ConsumerState<_DurakEkleDialog> {
  String? _seciliDriverId;
  DateTime? _firmaGirisAt = DateTime.now();
  DateTime? _firmaCikisAt;
  String? _tripTypeId;
  String? _requesterId;
  final _cikisNedeniController = TextEditingController();
  final _gidilenIlController = TextEditingController();
  final _gidilenIlceController = TextEditingController();
  String? _sirketId;
  final _sirketFreeController = TextEditingController();
  final _irsaliyeNoGirisController = TextEditingController();
  final _notlarController = TextEditingController();
  bool _kaydediliyor = false;
  String? _hata;

  @override
  void dispose() {
    _cikisNedeniController.dispose();
    _gidilenIlController.dispose();
    _gidilenIlceController.dispose();
    _sirketFreeController.dispose();
    _irsaliyeNoGirisController.dispose();
    _notlarController.dispose();
    super.dispose();
  }

  Future<void> _kaydet() async {
    setState(() => _hata = null);
    if (_seciliDriverId == null || _firmaGirisAt == null) {
      setState(() => _hata = 'Şoför ve Firma Giriş zamanı zorunlu.');
      return;
    }
    setState(() => _kaydediliyor = true);
    try {
      final sonuc = await _soforunSeferleri(ref, _seciliDriverId!);
      final sefer = _oAndaAcikSeferiBul(sonuc.tripler, _firmaGirisAt!);
      if (sefer == null) {
        setState(() => _hata =
            'Bu şoför için ${_dateFormat.format(_firmaGirisAt!)} anında açık bir sefer bulunamadı. Önce "Sefer Oluştur" ile bir sefer açın.');
        return;
      }
      final repo = ref.read(tripRepositoryProvider);
      await repo.upsertTripStop(TripStop(
        id: '',
        clientStopId: _uuid.v4(),
        tripId: sefer.id,
        sira: sonuc.durakSayilari[sefer.id] ?? 0,
        firmaGirisAt: _firmaGirisAt!,
        tripTypeId: _tripTypeId,
        requesterId: _requesterId,
        cikisNedeni:
            _cikisNedeniController.text.trim().isEmpty ? null : _cikisNedeniController.text.trim(),
        gidilenIl: _gidilenIlController.text.trim().isEmpty ? null : _gidilenIlController.text.trim(),
        gidilenIlce:
            _gidilenIlceController.text.trim().isEmpty ? null : _gidilenIlceController.text.trim(),
        gidilenSirketId: _sirketId,
        gidilenSirketFree:
            _sirketFreeController.text.trim().isEmpty ? null : _sirketFreeController.text.trim(),
        irsaliyeNoGiris: _irsaliyeNoGirisController.text.trim().isEmpty
            ? null
            : _irsaliyeNoGirisController.text.trim(),
        firmaCikisAt: _firmaCikisAt,
        notlar: _notlarController.text.trim().isEmpty ? null : _notlarController.text.trim(),
      ));
      ref.invalidate(tripListProvider);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Durak ${sefer.tarih} tarihli sefere eklendi.')),
        );
      }
    } catch (e) {
      setState(() => _hata = 'Kaydedilemedi: $e');
    } finally {
      if (mounted) setState(() => _kaydediliyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final driversAsync = ref.watch(allDriversProvider);
    final tripTypesAsync = ref.watch(tripTypesProvider);
    final requestersAsync = ref.watch(requestersProvider);
    final companiesAsync = ref.watch(companiesProvider);

    return AlertDialog(
      title: const Text('Durak Ekle (Hızlı)'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Şoför ve zamanı girin; sistem o an açık olan seferi bulup durağı otomatik oraya ekler.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              driversAsync.maybeWhen(
                data: (drivers) => DropdownButtonFormField<String>(
                  initialValue: _seciliDriverId,
                  decoration: const InputDecoration(labelText: 'Şoför', border: OutlineInputBorder()),
                  items:
                      drivers.map((d) => DropdownMenuItem(value: d.id, child: Text(d.fullName))).toList(),
                  onChanged: (v) => setState(() => _seciliDriverId = v),
                ),
                orElse: () => const LinearProgressIndicator(),
              ),
              const SizedBox(height: 16),
              TarihSaatSecici(
                label: 'Firma Giriş *',
                deger: _firmaGirisAt,
                onChanged: (v) => setState(() => _firmaGirisAt = v),
              ),
              const SizedBox(height: 16),
              TarihSaatSecici(
                label: 'Firma Çıkış',
                deger: _firmaCikisAt,
                onChanged: (v) => setState(() => _firmaCikisAt = v),
              ),
              const SizedBox(height: 16),
              tripTypesAsync.maybeWhen(
                data: (tripTypes) => DropdownButtonFormField<String?>(
                  initialValue: _tripTypeId,
                  decoration:
                      const InputDecoration(labelText: 'Seyahat Türü', border: OutlineInputBorder()),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('-')),
                    ...tripTypes.map((t) => DropdownMenuItem(value: t.id, child: Text(t.label))),
                  ],
                  onChanged: (v) => setState(() => _tripTypeId = v),
                ),
                orElse: () => const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),
              requestersAsync.maybeWhen(
                data: (requesters) => DropdownButtonFormField<String?>(
                  initialValue: _requesterId,
                  decoration:
                      const InputDecoration(labelText: 'Talep Eden Kişi', border: OutlineInputBorder()),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('-')),
                    ...requesters.map((r) => DropdownMenuItem(value: r.id, child: Text(r.fullName))),
                  ],
                  onChanged: (v) => setState(() => _requesterId = v),
                ),
                orElse: () => const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cikisNedeniController,
                decoration:
                    const InputDecoration(labelText: 'Çıkış Nedeni / Görev', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _gidilenIlController,
                decoration: const InputDecoration(labelText: 'Gidilen İl', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _gidilenIlceController,
                decoration: const InputDecoration(labelText: 'Gidilen İlçe', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              companiesAsync.maybeWhen(
                data: (companies) => DropdownButtonFormField<String?>(
                  initialValue: _sirketId,
                  decoration:
                      const InputDecoration(labelText: 'Gidilen Şirket', border: OutlineInputBorder()),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Listede yok / serbest metin')),
                    ...companies.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                  ],
                  onChanged: (v) => setState(() => _sirketId = v),
                ),
                orElse: () => const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _sirketFreeController,
                decoration: const InputDecoration(
                    labelText: 'Gidilen Şirket (serbest metin)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _irsaliyeNoGirisController,
                decoration:
                    const InputDecoration(labelText: 'İrsaliye No (Giriş)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notlarController,
                decoration:
                    const InputDecoration(labelText: 'Not / Açıklama', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              if (_hata != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(_hata!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
        FilledButton(
          onPressed: _kaydediliyor ? null : _kaydet,
          child: _kaydediliyor
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Ekle'),
        ),
      ],
    );
  }
}

/// "Fabrika Giriş/Çıkış" bölme aracı: fabrika giriş/çıkışı unutulup
/// ertesi gün mobilde direkt yeni bir fabrika çıkışıyla devam edilen
/// durumu düzeltir. Şoförün açık seferini girilen "Fabrika Giriş" zamanıyla
/// kapatır, aynı şoför/araçla girilen "Fabrika Çıkış" zamanıyla yeni bir
/// sefer açar (bkz. plan md §6).
class _FabrikaBolmeDialog extends ConsumerStatefulWidget {
  const _FabrikaBolmeDialog();

  @override
  ConsumerState<_FabrikaBolmeDialog> createState() => _FabrikaBolmeDialogState();
}

class _FabrikaBolmeDialogState extends ConsumerState<_FabrikaBolmeDialog> {
  String? _seciliDriverId;
  String? _seciliVehicleId;
  DateTime? _fabrikaGirisAt;
  DateTime? _fabrikaCikisAt;
  bool _seferAraniyor = false;
  Trip? _eskiSefer;
  bool _kaydediliyor = false;
  String? _hata;

  Future<void> _soforSecildi(String? driverId) async {
    setState(() {
      _seciliDriverId = driverId;
      _eskiSefer = null;
      _hata = null;
      _seciliVehicleId = null;
    });
    if (driverId == null) return;
    setState(() => _seferAraniyor = true);
    try {
      final sonuc = await _soforunSeferleri(ref, driverId);
      final eskiSefer = _acikSeferiBul(sonuc.tripler);
      if (!mounted) return;
      setState(() {
        _eskiSefer = eskiSefer;
        _seciliVehicleId = eskiSefer?.vehicleId;
        if (eskiSefer == null) _hata = 'Bu şoför için açık bir sefer bulunamadı.';
      });
    } finally {
      if (mounted) setState(() => _seferAraniyor = false);
    }
  }

  Future<void> _kaydet() async {
    setState(() => _hata = null);
    final eskiSefer = _eskiSefer;
    if (eskiSefer == null) {
      setState(() => _hata = 'Önce açık bir sefer bulunmalı.');
      return;
    }
    if (_fabrikaGirisAt == null || _fabrikaCikisAt == null || _seciliVehicleId == null) {
      setState(() => _hata = 'Fabrika Giriş, Fabrika Çıkış ve araç zorunlu.');
      return;
    }
    if (eskiSefer.fabrikaCikisAt != null && _fabrikaGirisAt!.isBefore(eskiSefer.fabrikaCikisAt!)) {
      setState(() => _hata = 'Fabrika Giriş zamanı, eski seferin Fabrika Çıkış zamanından önce olamaz.');
      return;
    }
    if (_fabrikaCikisAt!.isBefore(_fabrikaGirisAt!)) {
      setState(() => _hata = 'Yeni seferin Fabrika Çıkış zamanı, Fabrika Giriş zamanından önce olamaz.');
      return;
    }

    setState(() => _kaydediliyor = true);
    try {
      final repo = ref.read(tripRepositoryProvider);
      await repo.updateTrip(Trip(
        id: eskiSefer.id,
        clientTripId: eskiSefer.clientTripId,
        driverId: eskiSefer.driverId,
        vehicleId: eskiSefer.vehicleId,
        tarih: eskiSefer.tarih,
        fabrikaCikisAt: eskiSefer.fabrikaCikisAt,
        fabrikaGirisAt: _fabrikaGirisAt,
      ));
      await repo.upsertTrip(Trip(
        id: '',
        clientTripId: _uuid.v4(),
        driverId: eskiSefer.driverId,
        vehicleId: _seciliVehicleId!,
        tarih: DateFormat('yyyy-MM-dd').format(_fabrikaCikisAt!),
        fabrikaCikisAt: _fabrikaCikisAt,
        fabrikaGirisAt: null,
      ));
      ref.invalidate(tripListProvider);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sefer bölündü: eski sefer kapatıldı, yeni sefer açıldı.')),
        );
      }
    } catch (e) {
      setState(() => _hata = 'Kaydedilemedi: $e');
    } finally {
      if (mounted) setState(() => _kaydediliyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final driversAsync = ref.watch(allDriversProvider);
    final vehiclesAsync = ref.watch(vehiclesProvider);

    return AlertDialog(
      title: const Text('Fabrika Giriş/Çıkış (Sefer Böl)'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Fabrika giriş/çıkışı unutulmuş bir seferi ikiye böler: şoförün açık '
                'seferini "Fabrika Giriş" ile kapatır, aynı şoför/araçla "Fabrika Çıkış" '
                'ile yeni bir sefer açar.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              driversAsync.maybeWhen(
                data: (drivers) => DropdownButtonFormField<String>(
                  initialValue: _seciliDriverId,
                  decoration: const InputDecoration(labelText: 'Şoför', border: OutlineInputBorder()),
                  items:
                      drivers.map((d) => DropdownMenuItem(value: d.id, child: Text(d.fullName))).toList(),
                  onChanged: _soforSecildi,
                ),
                orElse: () => const LinearProgressIndicator(),
              ),
              if (_seferAraniyor) ...[
                const SizedBox(height: 12),
                const LinearProgressIndicator(),
              ],
              if (!_seferAraniyor && _eskiSefer != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Açık sefer bulundu: ${_eskiSefer!.tarih}'
                  '${_eskiSefer!.fabrikaCikisAt != null ? ' (Çıkış: ${_dateFormat.format(_eskiSefer!.fabrikaCikisAt!)})' : ''}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
              const SizedBox(height: 16),
              TarihSaatSecici(
                label: 'Fabrika Giriş (eski seferi kapatır) *',
                deger: _fabrikaGirisAt,
                onChanged: (v) => setState(() => _fabrikaGirisAt = v),
              ),
              const SizedBox(height: 16),
              TarihSaatSecici(
                label: 'Fabrika Çıkış (yeni sefer başlar) *',
                deger: _fabrikaCikisAt,
                onChanged: (v) => setState(() => _fabrikaCikisAt = v),
              ),
              const SizedBox(height: 16),
              vehiclesAsync.maybeWhen(
                data: (vehicles) => DropdownButtonFormField<String>(
                  initialValue: _seciliVehicleId,
                  decoration: const InputDecoration(
                      labelText: 'Araç Plakası (yeni sefer)', border: OutlineInputBorder()),
                  items: vehicles.map((v) => DropdownMenuItem(value: v.id, child: Text(v.plaka))).toList(),
                  onChanged: (v) => setState(() => _seciliVehicleId = v),
                ),
                orElse: () => const LinearProgressIndicator(),
              ),
              if (_hata != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(_hata!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
        FilledButton(
          onPressed: _kaydediliyor ? null : _kaydet,
          child: _kaydediliyor
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Böl'),
        ),
      ],
    );
  }
}
