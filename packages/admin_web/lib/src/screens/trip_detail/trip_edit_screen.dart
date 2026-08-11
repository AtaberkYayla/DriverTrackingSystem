import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../providers/app_providers.dart';
import '../../widgets/durak_form_alanlari.dart';
import '../../widgets/tarih_saat_secici.dart';

const _uuid = Uuid();

final _gunAyYilFormat = DateFormat('dd.MM.yyyy');
final _dateFormat = DateFormat('dd.MM.yyyy HH:mm');

/// "GG.AA.YYYY" metnini DateTime'a cevirir, gecersiz/eksikse null doner.
DateTime? _gunAyYiliAyristir(String metin) {
  try {
    return _gunAyYilFormat.parseStrict(metin.trim());
  } catch (_) {
    return null;
  }
}

/// Bir durağın (trip_stop) düzenleme formundaki alanları tutar. `id` doluysa
/// var olan bir durağı, boşsa (create_trip_screen'deki _StopForm gibi) yeni
/// eklenen bir durağı temsil eder.
class _StopEditForm {
  _StopEditForm.yeni()
      : id = null,
        clientStopId = null,
        originalOnayDurumu = null,
        originalSeferDurumu = null,
        onayDurumu = OnayDurumu.beklemede,
        seferDurumu = SeferDurumu.devamEdiyor;

  _StopEditForm.mevcut(TripStop stop)
      : id = stop.id,
        clientStopId = stop.clientStopId,
        originalOnayDurumu = stop.onayDurumu,
        originalSeferDurumu = stop.seferDurumu,
        onayDurumu = stop.onayDurumu,
        seferDurumu = stop.seferDurumu {
    tripTypeId = stop.tripTypeId;
    requesterId = stop.requesterId;
    cikisNedeniController.text = stop.cikisNedeni ?? '';
    gidilenIlController.text = stop.gidilenIl ?? '';
    gidilenIlceController.text = stop.gidilenIlce ?? '';
    sirketId = stop.gidilenSirketId;
    sirketFreeController.text = stop.gidilenSirketFree ?? '';
    irsaliyeNoGirisController.text = stop.irsaliyeNoGiris ?? '';
    irsaliyeNoCikisController.text = stop.irsaliyeNoCikis ?? '';
    notlarController.text = stop.notlar ?? '';
    notlarCikisController.text = stop.notlarCikis ?? '';
    firmaGirisAt = stop.firmaGirisAt;
    firmaCikisAt = stop.firmaCikisAt;
  }

  final String? id;
  final String? clientStopId;
  final OnayDurumu? originalOnayDurumu;
  final SeferDurumu? originalSeferDurumu;

  String? tripTypeId;
  String? requesterId;
  final cikisNedeniController = TextEditingController();
  final gidilenIlController = TextEditingController();
  final gidilenIlceController = TextEditingController();
  String? sirketId;
  final sirketFreeController = TextEditingController();
  final irsaliyeNoGirisController = TextEditingController();
  final irsaliyeNoCikisController = TextEditingController();
  final notlarController = TextEditingController();
  final notlarCikisController = TextEditingController();
  DateTime? firmaGirisAt;
  DateTime? firmaCikisAt;
  OnayDurumu onayDurumu;
  SeferDurumu seferDurumu;

  bool get onayDegisti =>
      id != null && (onayDurumu != originalOnayDurumu || seferDurumu != originalSeferDurumu);

  void dispose() {
    cikisNedeniController.dispose();
    gidilenIlController.dispose();
    gidilenIlceController.dispose();
    sirketFreeController.dispose();
    irsaliyeNoGirisController.dispose();
    irsaliyeNoCikisController.dispose();
    notlarController.dispose();
    notlarCikisController.dispose();
  }
}

/// Var olan bir seferi (Trip) ve tüm duraklarını (TripStop) tek bir ekranda,
/// tek Kaydet ile düzenler. create_trip_screen.dart'ın çok-duraklı form
/// yaklaşımının aynısını kullanır; eskiden her durak trip_detail_screen'de
/// ayrı ayrı açılıp kaydediliyordu.
class TripEditScreen extends ConsumerStatefulWidget {
  const TripEditScreen({super.key, required this.trip, required this.initialStops});

  final Trip trip;
  final List<TripStop> initialStops;

  @override
  ConsumerState<TripEditScreen> createState() => _TripEditScreenState();
}

class _TripEditScreenState extends ConsumerState<TripEditScreen> {
  late String _seciliVehicleId = widget.trip.vehicleId;
  late final _tarihController =
      TextEditingController(text: _gunAyYilFormat.format(DateTime.parse(widget.trip.tarih)));
  late DateTime? _fabrikaCikisAt = widget.trip.fabrikaCikisAt;
  late DateTime? _fabrikaGirisAt = widget.trip.fabrikaGirisAt;
  late final List<_StopEditForm> _duraklar =
      widget.initialStops.map(_StopEditForm.mevcut).toList();
  final List<String> _silinecekStopIdleri = [];
  bool _kaydediliyor = false;
  String? _hata;

  @override
  void dispose() {
    _tarihController.dispose();
    for (final durak in _duraklar) {
      durak.dispose();
    }
    super.dispose();
  }

  Future<void> _kaydet() async {
    setState(() => _hata = null);
    final seciliTarih = _gunAyYiliAyristir(_tarihController.text);
    if (seciliTarih == null) {
      setState(() => _hata = 'Tarih GG.AA.YYYY formatında olmalı (ör. 30.07.2026).');
      return;
    }
    for (final durak in _duraklar) {
      if (durak.firmaGirisAt == null) {
        setState(() => _hata = 'Her durak için Firma Giriş tarihi/saati zorunlu.');
        return;
      }
    }

    setState(() => _kaydediliyor = true);
    try {
      final repo = ref.read(tripRepositoryProvider);
      final isManagerOrAdmin = ref.read(isManagerOrAdminProvider);

      await repo.updateTrip(Trip(
        id: widget.trip.id,
        clientTripId: widget.trip.clientTripId,
        driverId: widget.trip.driverId,
        vehicleId: _seciliVehicleId,
        tarih: DateFormat('yyyy-MM-dd').format(seciliTarih),
        fabrikaCikisAt: _fabrikaCikisAt,
        fabrikaGirisAt: _fabrikaGirisAt,
      ));

      for (var i = 0; i < _duraklar.length; i++) {
        final durak = _duraklar[i];
        if (durak.id == null) {
          await repo.upsertTripStop(TripStop(
            id: '',
            clientStopId: _uuid.v4(),
            tripId: widget.trip.id,
            sira: i,
            firmaGirisAt: durak.firmaGirisAt!,
            tripTypeId: durak.tripTypeId,
            requesterId: durak.requesterId,
            cikisNedeni: durak.cikisNedeniController.text.trim().isEmpty
                ? null
                : durak.cikisNedeniController.text.trim(),
            gidilenIl: durak.gidilenIlController.text.trim().isEmpty
                ? null
                : durak.gidilenIlController.text.trim(),
            gidilenIlce: durak.gidilenIlceController.text.trim().isEmpty
                ? null
                : durak.gidilenIlceController.text.trim(),
            gidilenSirketId: durak.sirketId,
            gidilenSirketFree: durak.sirketFreeController.text.trim().isEmpty
                ? null
                : durak.sirketFreeController.text.trim(),
            irsaliyeNoGiris: durak.irsaliyeNoGirisController.text.trim().isEmpty
                ? null
                : durak.irsaliyeNoGirisController.text.trim(),
            irsaliyeNoCikis: durak.irsaliyeNoCikisController.text.trim().isEmpty
                ? null
                : durak.irsaliyeNoCikisController.text.trim(),
            firmaCikisAt: durak.firmaCikisAt,
            notlar: durak.notlarController.text.trim().isEmpty
                ? null
                : durak.notlarController.text.trim(),
            notlarCikis: durak.notlarCikisController.text.trim().isEmpty
                ? null
                : durak.notlarCikisController.text.trim(),
          ));
        } else {
          await repo.updateTripStopDetails(TripStop(
            id: durak.id!,
            clientStopId: durak.clientStopId!,
            tripId: widget.trip.id,
            sira: i,
            firmaGirisAt: durak.firmaGirisAt!,
            tripTypeId: durak.tripTypeId,
            requesterId: durak.requesterId,
            cikisNedeni: durak.cikisNedeniController.text.trim().isEmpty
                ? null
                : durak.cikisNedeniController.text.trim(),
            gidilenIl: durak.gidilenIlController.text.trim().isEmpty
                ? null
                : durak.gidilenIlController.text.trim(),
            gidilenIlce: durak.gidilenIlceController.text.trim().isEmpty
                ? null
                : durak.gidilenIlceController.text.trim(),
            gidilenSirketId: durak.sirketId,
            gidilenSirketFree: durak.sirketFreeController.text.trim().isEmpty
                ? null
                : durak.sirketFreeController.text.trim(),
            irsaliyeNoGiris: durak.irsaliyeNoGirisController.text.trim().isEmpty
                ? null
                : durak.irsaliyeNoGirisController.text.trim(),
            irsaliyeNoCikis: durak.irsaliyeNoCikisController.text.trim().isEmpty
                ? null
                : durak.irsaliyeNoCikisController.text.trim(),
            firmaCikisAt: durak.firmaCikisAt,
            notlar: durak.notlarController.text.trim().isEmpty
                ? null
                : durak.notlarController.text.trim(),
            notlarCikis: durak.notlarCikisController.text.trim().isEmpty
                ? null
                : durak.notlarCikisController.text.trim(),
          ));
          if (isManagerOrAdmin && durak.onayDegisti) {
            final profile = await ref.read(currentProfileProvider.future);
            if (profile != null) {
              await repo.updateApproval(
                stopId: durak.id!,
                onayDurumu: durak.onayDurumu,
                onaylayanId: profile.id,
                seferDurumu: durak.seferDurumu,
                notlar: durak.notlarController.text.trim().isEmpty
                    ? null
                    : durak.notlarController.text.trim(),
              );
            }
          }
        }
      }

      for (final stopId in _silinecekStopIdleri) {
        await repo.deleteTripStop(stopId);
      }

      ref.invalidate(tripListProvider);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _hata = 'Kaydedilemedi: $e');
    } finally {
      if (mounted) setState(() => _kaydediliyor = false);
    }
  }

  Future<void> _seferiSil() async {
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
    await ref.read(tripRepositoryProvider).deleteTrip(widget.trip.id);
    ref.invalidate(tripListProvider);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isManagerOrAdmin = ref.watch(isManagerOrAdminProvider);
    final isOperator = ref.watch(isOperatorProvider);
    final currentUserId = ref.watch(currentProfileProvider).value?.id;
    final duzenleyebilir = isManagerOrAdmin ||
        (isOperator &&
            widget.trip.createdByUserId != null &&
            widget.trip.createdByUserId == currentUserId);

    return Scaffold(
      appBar: AppBar(
        title: Text('Sefer - ${widget.trip.tarihGosterim}'),
        actions: [
          if (isManagerOrAdmin)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Seferi Sil',
              onPressed: _seferiSil,
            ),
        ],
      ),
      body: duzenleyebilir ? _duzenlemeFormu(context) : _salOkunurGorunum(context),
    );
  }

  Widget _salOkunurGorunum(BuildContext context) {
    final refDataAsync = ref.watch(referenceDataProvider);
    return refDataAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Referans veri yüklenemedi: $e')),
      data: (refData) => ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _bilgiSatiri('Şoför', refData.surucuAdi(widget.trip.driverId)),
          _bilgiSatiri('Araç Plakası', refData.aracPlakasi(widget.trip.vehicleId)),
          _bilgiSatiri('Tarih', widget.trip.tarihGosterim),
          _bilgiSatiri(
            'Fabrika Çıkış',
            _fabrikaCikisAt == null ? '-' : _dateFormat.format(_fabrikaCikisAt!),
          ),
          _bilgiSatiri(
            'Fabrika Giriş (sefer kapanışı)',
            _fabrikaGirisAt == null ? '-' : _dateFormat.format(_fabrikaGirisAt!),
          ),
          for (final durak in _duraklar) ...[
            const Divider(height: 32),
            _bilgiSatiri('Seyahat Türü', refData.seferTuruAdi(durak.tripTypeId)),
            _bilgiSatiri('Talep Eden Kişi', refData.talepEdenAdi(durak.requesterId)),
            _bilgiSatiri(
              'Gidilen Şirket',
              durak.sirketId != null
                  ? refData.sirketAdi(durak.sirketId)
                  : (durak.sirketFreeController.text.isEmpty ? '-' : durak.sirketFreeController.text),
            ),
            _bilgiSatiri(
              'Firma Giriş',
              durak.firmaGirisAt == null ? '-' : _dateFormat.format(durak.firmaGirisAt!),
            ),
            _bilgiSatiri(
              'Firma Çıkış',
              durak.firmaCikisAt == null ? '-' : _dateFormat.format(durak.firmaCikisAt!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _duzenlemeFormu(BuildContext context) {
    final driversAsync = ref.watch(allDriversProvider);
    final vehiclesAsync = ref.watch(vehiclesProvider);
    final refDataAsync = ref.watch(referenceDataProvider);

    return refDataAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Referans veri yüklenemedi: $e')),
      data: (refData) => ListView(
        padding: const EdgeInsets.all(24),
        children: [
          driversAsync.maybeWhen(
            data: (drivers) => _bilgiSatiri('Şoför', refData.surucuAdi(widget.trip.driverId)),
            orElse: () => const LinearProgressIndicator(),
          ),
          const SizedBox(height: 16),
          vehiclesAsync.maybeWhen(
            data: (vehicles) => DropdownButtonFormField<String>(
              initialValue: _seciliVehicleId,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Araç Plakası', border: OutlineInputBorder()),
              items: vehicles.map((v) => DropdownMenuItem(value: v.id, child: Text(v.plaka))).toList(),
              onChanged: (v) => setState(() => _seciliVehicleId = v ?? _seciliVehicleId),
            ),
            orElse: () => const LinearProgressIndicator(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _tarihController,
            decoration: InputDecoration(
              labelText: 'Tarih (GG.AA.YYYY)',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.calendar_today_outlined),
                tooltip: 'Takvimden Seç',
                onPressed: () async {
                  final secilen = await showDatePicker(
                    context: context,
                    initialDate: _gunAyYiliAyristir(_tarihController.text) ?? bugununTarihi(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (secilen == null) return;
                  setState(() => _tarihController.text = _gunAyYilFormat.format(secilen));
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          TarihSaatSecici(
            label: 'Fabrika Çıkış',
            deger: _fabrikaCikisAt,
            onChanged: (v) => setState(() => _fabrikaCikisAt = v),
          ),
          const SizedBox(height: 16),
          TarihSaatSecici(
            label: 'Fabrika Giriş (sefer kapanışı)',
            deger: _fabrikaGirisAt,
            onChanged: (v) => setState(() => _fabrikaGirisAt = v),
          ),
          const Divider(height: 40),
          Text('Firma Ziyaretleri (Duraklar)', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          if (_duraklar.isEmpty)
            OutlinedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Durak Ekle'),
              onPressed: () => setState(() => _duraklar.add(_StopEditForm.yeni())),
            ),
          // "Durak Ekle" butonu bilinçli olarak 1. durağın hemen altında
          // (create_trip_screen.dart ile tutarlı).
          for (var i = 0; i < _duraklar.length; i++) ...[
            _durakKarti(i, _duraklar[i]),
            const SizedBox(height: 12),
            if (i == 0) ...[
              OutlinedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Durak Ekle'),
                onPressed: () => setState(() => _duraklar.add(_StopEditForm.yeni())),
              ),
              const SizedBox(height: 12),
            ],
          ],
          if (_hata != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(_hata!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _kaydediliyor ? null : _kaydet,
            child: _kaydediliyor
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Seferi Kaydet'),
          ),
        ],
      ),
    );
  }

  Widget _durakKarti(int index, _StopEditForm durak) {
    final tripTypesAsync = ref.watch(tripTypesProvider);
    final requestersAsync = ref.watch(requestersProvider);
    final companiesAsync = ref.watch(companiesProvider);
    final turkeyAsync = ref.watch(turkeyLocationsProvider);
    final isManagerOrAdmin = ref.watch(isManagerOrAdminProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Durak ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Durağı Kaldır',
                  onPressed: () => setState(() {
                    if (durak.id != null) _silinecekStopIdleri.add(durak.id!);
                    durak.dispose();
                    _duraklar.removeAt(index);
                  }),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TarihSaatSecici(
              label: 'Firma Giriş *',
              deger: durak.firmaGirisAt,
              onChanged: (v) => setState(() => durak.firmaGirisAt = v),
            ),
            const SizedBox(height: 16),
            TarihSaatSecici(
              label: 'Firma Çıkış',
              deger: durak.firmaCikisAt,
              onChanged: (v) => setState(() => durak.firmaCikisAt = v),
            ),
            const SizedBox(height: 16),
            tripTypesAsync.maybeWhen(
              data: (tripTypes) => DropdownButtonFormField<String?>(
                initialValue: durak.tripTypeId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Seyahat Türü', border: OutlineInputBorder()),
                items: [
                  const DropdownMenuItem(value: null, child: Text('-')),
                  ...tripTypes.map((t) => DropdownMenuItem(value: t.id, child: Text(t.label))),
                ],
                onChanged: (v) => setState(() {
                  durak.tripTypeId = v;
                  final uyumlular = turUyumluSirketler(companiesAsync.value ?? const [], v);
                  if (durak.sirketId != null && !uyumlular.any((c) => c.id == durak.sirketId)) {
                    durak.sirketId = null;
                  }
                }),
              ),
              orElse: () => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            requestersAsync.maybeWhen(
              data: (requesters) => DropdownButtonFormField<String?>(
                initialValue: durak.requesterId,
                isExpanded: true,
                decoration:
                    const InputDecoration(labelText: 'Talep Eden Kişi', border: OutlineInputBorder()),
                items: [
                  const DropdownMenuItem(value: null, child: Text('-')),
                  ...requesters.map((r) => DropdownMenuItem(value: r.id, child: Text(r.fullName))),
                ],
                onChanged: (v) => setState(() => durak.requesterId = v),
              ),
              orElse: () => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: durak.cikisNedeniController,
              decoration:
                  const InputDecoration(labelText: 'Çıkış Nedeni / Görev', border: OutlineInputBorder()),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            turkeyAsync.maybeWhen(
              data: (turkey) => IlIlceSecici(
                turkey: turkey,
                ilController: durak.gidilenIlController,
                ilceController: durak.gidilenIlceController,
              ),
              orElse: () => const LinearProgressIndicator(),
            ),
            const SizedBox(height: 16),
            companiesAsync.maybeWhen(
              data: (companies) => DropdownButtonFormField<String?>(
                initialValue: durak.sirketId,
                isExpanded: true,
                decoration:
                    const InputDecoration(labelText: 'Gidilen Şirket', border: OutlineInputBorder()),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Listede yok / serbest metin')),
                  ...turUyumluSirketler(companies, durak.tripTypeId)
                      .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                ],
                onChanged: (v) => setState(() => durak.sirketId = v),
              ),
              orElse: () => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: durak.sirketFreeController,
              decoration: const InputDecoration(
                  labelText: 'Gidilen Şirket (serbest metin)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: durak.irsaliyeNoGirisController,
              decoration:
                  const InputDecoration(labelText: 'İrsaliye No (Giriş)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: durak.irsaliyeNoCikisController,
              decoration:
                  const InputDecoration(labelText: 'İrsaliye No (Çıkış)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: durak.notlarController,
              decoration: const InputDecoration(
                  labelText: 'Not / Açıklama (Giriş)', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: durak.notlarCikisController,
              decoration: const InputDecoration(
                  labelText: 'Not / Açıklama (Çıkış)', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            // Onay/değerlendirme sadece var olan (zaten kaydedilmiş) duraklar
            // için ve sadece yönetici/admin'e gösterilir (bkz.
            // backend/trip_stops_update_approval.php requireRole).
            if (isManagerOrAdmin && durak.id != null) ...[
              const Divider(height: 32),
              Text('Onay / Değerlendirme', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 12),
              DropdownButtonFormField<OnayDurumu>(
                initialValue: durak.onayDurumu,
                isExpanded: true,
                decoration:
                    const InputDecoration(labelText: 'Onay Durumu', border: OutlineInputBorder()),
                items: OnayDurumu.values
                    .map((d) => DropdownMenuItem(
                          value: d,
                          child: Text(d == OnayDurumu.onaylandi ? 'Onaylandı' : 'Onay Bekleniyor'),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => durak.onayDurumu = v!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<SeferDurumu>(
                initialValue: durak.seferDurumu,
                isExpanded: true,
                decoration:
                    const InputDecoration(labelText: 'Sefer Durumu', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: SeferDurumu.devamEdiyor, child: Text('Devam Ediyor')),
                  DropdownMenuItem(value: SeferDurumu.basarili, child: Text('Başarılı')),
                  DropdownMenuItem(value: SeferDurumu.basarisiz, child: Text('Başarısız')),
                ],
                onChanged: (v) => setState(() => durak.seferDurumu = v!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _bilgiSatiri(String label, String deger) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 200,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(deger)),
        ],
      ),
    );
  }
}
