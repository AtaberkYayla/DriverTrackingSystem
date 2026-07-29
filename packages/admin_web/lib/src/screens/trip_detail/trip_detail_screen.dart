import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/app_providers.dart';

/// Gidilebilecek lokasyonlar bu sekiz il ile sinirlidir (bkz. driver_app'teki
/// ayni isimli/amacli liste, trip_detail_form.dart, ve create_trip_screen.dart).
const _izinVerilenIller = <String>[
  'İzmir',
  'Manisa',
  'İstanbul',
  'Bursa',
  'Konya',
  'Aydın',
  'Aksaray',
  'Tekirdağ',
];

final _gunAyYilFormat = DateFormat('dd.MM.yyyy');

/// "GG.AA.YYYY" metnini DateTime'a cevirir, gecersiz/eksikse null doner.
DateTime? _gunAyYiliAyristir(String metin) {
  try {
    return _gunAyYilFormat.parseStrict(metin.trim());
  } catch (_) {
    return null;
  }
}

class TripDetailScreen extends ConsumerStatefulWidget {
  const TripDetailScreen({super.key, required this.stopWithTrip});

  final TripStopWithTrip stopWithTrip;

  @override
  ConsumerState<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends ConsumerState<TripDetailScreen> {
  // Bu ekran sadece durak kaydi olan seferler icin acilir (bkz.
  // TripListScreen'de stop == null olan satirlarda onSelectChanged yok).
  TripStop get _stop => widget.stopWithTrip.stop!;
  Trip get _trip => widget.stopWithTrip.trip;

  late OnayDurumu _onayDurumu = _stop.onayDurumu;
  late SeferDurumu _seferDurumu = _stop.seferDurumu;
  late final _notlarController = TextEditingController(text: _stop.notlar);
  bool _kaydediliyor = false;

  bool _duzenlemeAcik = false;
  late String? _seciliTripTypeId = _stop.tripTypeId;
  late String? _seciliRequesterId = _stop.requesterId;
  late final _cikisNedeniController = TextEditingController(text: _stop.cikisNedeni);
  late final _gidilenIlController = TextEditingController(text: _stop.gidilenIl);
  late final _gidilenIlceController = TextEditingController(text: _stop.gidilenIlce);
  // Kayitli il, _izinVerilenIller listesinden gecerli bir secimle mi
  // eslesiyor - ilceyi (zorunlu/serbest) buna gore belirlemek icin.
  late String? _seciliIl = _izinVerilenIller.contains(_stop.gidilenIl) ? _stop.gidilenIl : null;
  late String? _seciliSirketId = _stop.gidilenSirketId;
  late final _gidilenSirketFreeController = TextEditingController(text: _stop.gidilenSirketFree);
  late final _irsaliyeNoGirisController = TextEditingController(text: _stop.irsaliyeNoGiris);
  late final _irsaliyeNoCikisController = TextEditingController(text: _stop.irsaliyeNoCikis);
  late final _notlarCikisController = TextEditingController(text: _stop.notlarCikis);
  late String _seciliVehicleId = _trip.vehicleId;
  late final _tarihController =
      TextEditingController(text: _gunAyYilFormat.format(DateTime.parse(_trip.tarih)));
  late DateTime? _fabrikaCikisAt = _trip.fabrikaCikisAt;
  late DateTime? _fabrikaGirisAt = _trip.fabrikaGirisAt;
  bool _detayKaydediliyor = false;

  @override
  void dispose() {
    _notlarController.dispose();
    _cikisNedeniController.dispose();
    _gidilenIlController.dispose();
    _gidilenIlceController.dispose();
    _gidilenSirketFreeController.dispose();
    _irsaliyeNoGirisController.dispose();
    _irsaliyeNoCikisController.dispose();
    _notlarCikisController.dispose();
    _tarihController.dispose();
    super.dispose();
  }

  Future<void> _kaydet() async {
    final profile = await ref.read(currentProfileProvider.future);
    if (profile == null) return;
    setState(() => _kaydediliyor = true);
    try {
      await ref.read(tripRepositoryProvider).updateApproval(
            stopId: _stop.id,
            onayDurumu: _onayDurumu,
            onaylayanId: profile.id,
            seferDurumu: _seferDurumu,
            notlar: _notlarController.text.trim().isEmpty ? null : _notlarController.text.trim(),
          );
      ref.invalidate(tripListProvider);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _kaydediliyor = false);
    }
  }

  Future<void> _detaylariKaydet() async {
    final seciliTarih = _gunAyYiliAyristir(_tarihController.text);
    if (seciliTarih == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tarih GG.AA.YYYY formatında olmalı (ör. 30.07.2026).')),
      );
      return;
    }
    setState(() => _detayKaydediliyor = true);
    try {
      final repo = ref.read(tripRepositoryProvider);
      // copyWith kullanilmiyor: nullable alanlari (ör. talep eden kisiyi
      // "-" secerek temizlemek) copyWith'in "??" mantigi geri eski degere
      // dusurur, bu yuzden burada TripStop dogrudan tum alanlarla kuruluyor.
      await repo.updateTripStopDetails(TripStop(
        id: _stop.id,
        clientStopId: _stop.clientStopId,
        tripId: _stop.tripId,
        sira: _stop.sira,
        firmaGirisAt: _stop.firmaGirisAt,
        tripTypeId: _seciliTripTypeId,
        requesterId: _seciliRequesterId,
        cikisNedeni:
            _cikisNedeniController.text.trim().isEmpty ? null : _cikisNedeniController.text.trim(),
        gidilenIl: _gidilenIlController.text.trim().isEmpty ? null : _gidilenIlController.text.trim(),
        gidilenIlce:
            _gidilenIlceController.text.trim().isEmpty ? null : _gidilenIlceController.text.trim(),
        gidilenSirketId: _seciliSirketId,
        gidilenSirketFree: _gidilenSirketFreeController.text.trim().isEmpty
            ? null
            : _gidilenSirketFreeController.text.trim(),
        irsaliyeNoGiris: _irsaliyeNoGirisController.text.trim().isEmpty
            ? null
            : _irsaliyeNoGirisController.text.trim(),
        irsaliyeNoCikis: _irsaliyeNoCikisController.text.trim().isEmpty
            ? null
            : _irsaliyeNoCikisController.text.trim(),
        firmaCikisAt: _stop.firmaCikisAt,
        onayDurumu: _stop.onayDurumu,
        onaylayanId: _stop.onaylayanId,
        onaylandiAt: _stop.onaylandiAt,
        seferDurumu: _stop.seferDurumu,
        notlar: _stop.notlar,
        notlarCikis: _notlarCikisController.text.trim().isEmpty
            ? null
            : _notlarCikisController.text.trim(),
      ));
      await repo.updateTrip(Trip(
        id: _trip.id,
        clientTripId: _trip.clientTripId,
        driverId: _trip.driverId,
        vehicleId: _seciliVehicleId,
        tarih: DateFormat('yyyy-MM-dd').format(seciliTarih),
        fabrikaCikisAt: _fabrikaCikisAt,
        fabrikaGirisAt: _fabrikaGirisAt,
      ));
      ref.invalidate(tripListProvider);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _detayKaydediliyor = false);
    }
  }

  Future<void> _sil() async {
    final secim = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sil'),
        content: const Text(
            'Sadece bu durağı mı, yoksa seferin tamamını mı silmek istiyorsunuz? Bu işlem geri alınamaz.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('İptal')),
          TextButton(
              onPressed: () => Navigator.pop(context, 'stop'), child: const Text('Durağı Sil')),
          FilledButton(
              onPressed: () => Navigator.pop(context, 'trip'),
              child: const Text('Seferin Tamamını Sil')),
        ],
      ),
    );
    if (secim == null) return;
    final repo = ref.read(tripRepositoryProvider);
    if (secim == 'stop') {
      await repo.deleteTripStop(_stop.id);
    } else {
      await repo.deleteTrip(_trip.id);
    }
    ref.invalidate(tripListProvider);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final trip = _trip;
    final stop = _stop;
    final refDataAsync = ref.watch(referenceDataProvider);
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');
    final isManagerOrAdmin = ref.watch(isManagerOrAdminProvider);
    final isOperator = ref.watch(isOperatorProvider);
    final currentUserId = ref.watch(currentProfileProvider).value?.id;
    // Operator sadece admin_web'den kendi olusturdugu (created_by_user_id)
    // seferi duzenleyebilir; manager/admin icin kisitlama yok (bkz.
    // backend/lib_auth.php requireTripOwnershipIfOperator).
    final duzenleyebilir =
        isManagerOrAdmin || (isOperator && trip.createdByUserId != null && trip.createdByUserId == currentUserId);

    return Scaffold(
      appBar: AppBar(
        title: Text('Sefer Detayı - ${trip.tarih}'),
        actions: [
          if (isManagerOrAdmin)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Sil',
              onPressed: _sil,
            ),
        ],
      ),
      body: refDataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Referans veri yüklenemedi: $e')),
        data: (refData) {
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _bilgiSatiri('Şoför', refData.surucuAdi(trip.driverId)),
              if (!_duzenlemeAcik) ...[
                _bilgiSatiri('Araç Plakası', refData.aracPlakasi(trip.vehicleId)),
                _bilgiSatiri('Seyahat Türü', refData.seferTuruAdi(stop.tripTypeId)),
                _bilgiSatiri('Talep Eden Kişi', refData.talepEdenAdi(stop.requesterId)),
                _bilgiSatiri('Çıkış Nedeni / Görev', stop.cikisNedeni ?? '-'),
                _bilgiSatiri(
                  'Gidilen Lokasyon',
                  [stop.gidilenIl, stop.gidilenIlce].whereType<String>().join(' / '),
                ),
                _bilgiSatiri(
                  'Gidilen Şirket',
                  stop.gidilenSirketId != null
                      ? refData.sirketAdi(stop.gidilenSirketId)
                      : (stop.gidilenSirketFree ?? '-'),
                ),
                _bilgiSatiri('İrsaliye No (Giriş)', stop.irsaliyeNoGiris ?? '-'),
                _bilgiSatiri('İrsaliye No (Çıkış)', stop.irsaliyeNoCikis ?? '-'),
                _bilgiSatiri('Not / Açıklama (Giriş)', stop.notlar ?? '-'),
                _bilgiSatiri('Not / Açıklama (Çıkış)', stop.notlarCikis ?? '-'),
                _bilgiSatiri(
                  'Fabrika Çıkış',
                  _fabrikaCikisAt == null ? '-' : dateFormat.format(_fabrikaCikisAt!),
                ),
                _bilgiSatiri(
                  'Fabrika Giriş (sefer kapanışı)',
                  _fabrikaGirisAt == null ? '-' : dateFormat.format(_fabrikaGirisAt!),
                ),
              ] else
                _detayDuzenlemeFormu(context, refData),
              if (duzenleyebilir) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: Icon(_duzenlemeAcik ? Icons.close : Icons.edit_outlined),
                  label: Text(
                      _duzenlemeAcik ? 'Düzenlemeyi İptal Et' : 'Sefer Detaylarını Düzenle'),
                  onPressed: () => setState(() => _duzenlemeAcik = !_duzenlemeAcik),
                ),
                if (_duzenlemeAcik) ...[
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _detayKaydediliyor ? null : _detaylariKaydet,
                    child: _detayKaydediliyor
                        ? const SizedBox(
                            width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Sefer Detaylarını Kaydet'),
                  ),
                ],
              ],
              const Divider(height: 32),
              _bilgiSatiri('Firma Giriş', dateFormat.format(stop.firmaGirisAt)),
              _bilgiSatiri(
                'Firma Çıkış',
                stop.firmaCikisAt == null ? '-' : dateFormat.format(stop.firmaCikisAt!),
              ),
              const Divider(height: 32),
              Text('Onay / Değerlendirme', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              // Onay verme yetkisi sadece yonetici/admin'de - operator (ve
              // yanlislikla buraya erisen sofor gibi diger roller) bu
              // degerleri sadece salt-okunur gorur.
              if (isManagerOrAdmin) ...[
                DropdownButtonFormField<OnayDurumu>(
                  initialValue: _onayDurumu,
                  decoration: const InputDecoration(
                    labelText: 'Onay Durumu',
                    border: OutlineInputBorder(),
                  ),
                  items: OnayDurumu.values
                      .map((d) => DropdownMenuItem(
                            value: d,
                            child: Text(d == OnayDurumu.onaylandi ? 'Onaylandı' : 'Onay Bekleniyor'),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _onayDurumu = v!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<SeferDurumu>(
                  initialValue: _seferDurumu,
                  decoration: const InputDecoration(
                    labelText: 'Sefer Durumu',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: SeferDurumu.devamEdiyor, child: Text('Devam Ediyor')),
                    DropdownMenuItem(value: SeferDurumu.basarili, child: Text('Başarılı')),
                    DropdownMenuItem(value: SeferDurumu.basarisiz, child: Text('Başarısız')),
                  ],
                  onChanged: (v) => setState(() => _seferDurumu = v!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notlarController,
                  decoration: const InputDecoration(
                    labelText: 'Notlar / Açıklamalar',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _kaydediliyor ? null : _kaydet,
                  child: _kaydediliyor
                      ? const SizedBox(
                          width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Kaydet'),
                ),
              ] else ...[
                _bilgiSatiri('Onay Durumu', _onayDurumu == OnayDurumu.onaylandi ? 'Onaylandı' : 'Onay Bekleniyor'),
                _bilgiSatiri('Sefer Durumu', switch (_seferDurumu) {
                  SeferDurumu.devamEdiyor => 'Devam Ediyor',
                  SeferDurumu.basarili => 'Başarılı',
                  SeferDurumu.basarisiz => 'Başarısız',
                }),
                _bilgiSatiri('Notlar / Açıklamalar', _notlarController.text.isEmpty ? '-' : _notlarController.text),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _detayDuzenlemeFormu(BuildContext context, ReferenceData refData) {
    final vehiclesAsync = ref.watch(vehiclesProvider);
    final tripTypesAsync = ref.watch(tripTypesProvider);
    final requestersAsync = ref.watch(requestersProvider);
    final companiesAsync = ref.watch(companiesProvider);
    final turkeyAsync = ref.watch(turkeyLocationsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        vehiclesAsync.maybeWhen(
          data: (vehicles) => DropdownButtonFormField<String>(
            initialValue: _seciliVehicleId,
            decoration: const InputDecoration(labelText: 'Araç Plakası', border: OutlineInputBorder()),
            items: vehicles.map((v) => DropdownMenuItem(value: v.id, child: Text(v.plaka))).toList(),
            onChanged: (v) => setState(() => _seciliVehicleId = v ?? _seciliVehicleId),
          ),
          orElse: () => const SizedBox.shrink(),
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
        tripTypesAsync.maybeWhen(
          data: (tripTypes) => DropdownButtonFormField<String?>(
            initialValue: _seciliTripTypeId,
            decoration: const InputDecoration(labelText: 'Seyahat Türü', border: OutlineInputBorder()),
            items: [
              const DropdownMenuItem(value: null, child: Text('-')),
              ...tripTypes.map((t) => DropdownMenuItem(value: t.id, child: Text(t.label))),
            ],
            onChanged: (v) => setState(() => _seciliTripTypeId = v),
          ),
          orElse: () => const SizedBox.shrink(),
        ),
        const SizedBox(height: 16),
        requestersAsync.maybeWhen(
          data: (requesters) => DropdownButtonFormField<String?>(
            initialValue: _seciliRequesterId,
            decoration:
                const InputDecoration(labelText: 'Talep Eden Kişi', border: OutlineInputBorder()),
            items: [
              const DropdownMenuItem(value: null, child: Text('-')),
              ...requesters.map((r) => DropdownMenuItem(value: r.id, child: Text(r.fullName))),
            ],
            onChanged: (v) => setState(() => _seciliRequesterId = v),
          ),
          orElse: () => const SizedBox.shrink(),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _cikisNedeniController,
          decoration:
              const InputDecoration(labelText: 'Çıkış Nedeni / Görev', border: OutlineInputBorder()),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        turkeyAsync.maybeWhen(
          data: _ilIlceAlanlari,
          orElse: () => const LinearProgressIndicator(),
        ),
        const SizedBox(height: 16),
        companiesAsync.maybeWhen(
          data: (companies) => DropdownButtonFormField<String?>(
            initialValue: _seciliSirketId,
            decoration:
                const InputDecoration(labelText: 'Gidilen Şirket', border: OutlineInputBorder()),
            items: [
              const DropdownMenuItem(value: null, child: Text('Listede yok / serbest metin')),
              ...companies.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
            ],
            onChanged: (v) => setState(() => _seciliSirketId = v),
          ),
          orElse: () => const SizedBox.shrink(),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _gidilenSirketFreeController,
          decoration: const InputDecoration(
              labelText: 'Gidilen Şirket (serbest metin)', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _irsaliyeNoGirisController,
          decoration: const InputDecoration(
              labelText: 'İrsaliye No (Giriş)', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _irsaliyeNoCikisController,
          decoration: const InputDecoration(
              labelText: 'İrsaliye No (Çıkış)', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _notlarCikisController,
          decoration: const InputDecoration(
              labelText: 'Not / Açıklama (Çıkış)', border: OutlineInputBorder()),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        _tarihSaatSecici(
          label: 'Fabrika Çıkış',
          deger: _fabrikaCikisAt,
          onChanged: (v) => setState(() => _fabrikaCikisAt = v),
        ),
        const SizedBox(height: 16),
        _tarihSaatSecici(
          label: 'Fabrika Giriş (sefer kapanışı)',
          deger: _fabrikaGirisAt,
          onChanged: (v) => setState(() => _fabrikaGirisAt = v),
        ),
      ],
    );
  }

  /// Gidilen il/ilce alanlari: il, sabit _izinVerilenIller listesinden
  /// secilir (serbest metne izin verilmez); Izmir/Manisa icin ilce de
  /// il_ilce.json'daki listeden secilir, digerlerinde ilce serbest metindir.
  Widget _ilIlceAlanlari(TurkeyLocations turkey) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Autocomplete<String>(
          optionsBuilder: (value) {
            if (value.text.isEmpty) return _izinVerilenIller;
            final q = value.text.toLowerCase();
            return _izinVerilenIller.where((il) => il.toLowerCase().contains(q));
          },
          onSelected: (il) => setState(() {
            _seciliIl = il;
            _gidilenIlController.text = il;
            _gidilenIlceController.clear();
          }),
          fieldViewBuilder: (context, controller, focusNode, onSubmit) {
            controller.text = _gidilenIlController.text;
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              decoration: const InputDecoration(labelText: 'Gidilen İl', border: OutlineInputBorder()),
              onChanged: (v) {
                _gidilenIlController.text = v;
                if (_seciliIl != v) {
                  setState(() {
                    _seciliIl = null;
                    _gidilenIlceController.clear();
                  });
                }
              },
            );
          },
        ),
        if (_seciliIl != null) ...[
          const SizedBox(height: 16),
          if (turkey.ilceZorunluMu(_seciliIl!))
            Autocomplete<String>(
              key: ValueKey('ilce-$_seciliIl'),
              optionsBuilder: (value) => turkey.ilceAra(_seciliIl!, value.text),
              onSelected: (ilce) => _gidilenIlceController.text = ilce,
              fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                controller.text = _gidilenIlceController.text;
                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration:
                      const InputDecoration(labelText: 'Gidilen İlçe', border: OutlineInputBorder()),
                  onChanged: (v) => _gidilenIlceController.text = v,
                );
              },
            )
          else
            TextFormField(
              controller: _gidilenIlceController,
              decoration: const InputDecoration(
                  labelText: 'Gidilen İlçe (opsiyonel)', border: OutlineInputBorder()),
            ),
        ],
      ],
    );
  }

  /// Duzenleme formunun en ustundeki "Tarih" alanindan (GG.AA.YYYY) sefer
  /// tarihini ayristirir; gecersizse bugune duser. Asagidaki saat secicileri
  /// artik tarihi tekrar sormuyor, bu tarihi temel alip sadece saat soruyor.
  DateTime get _seferTarihi => _gunAyYiliAyristir(_tarihController.text) ?? bugununTarihi();

  Widget _tarihSaatSecici({
    required String label,
    required DateTime? deger,
    required void Function(DateTime?) onChanged,
  }) {
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');
    return Row(
      children: [
        Expanded(
          child: Text('$label: ${deger == null ? '-' : dateFormat.format(deger)}'),
        ),
        TextButton(
          onPressed: () async {
            final baseDate = _seferTarihi;
            final saat = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(deger ?? DateTime.now()),
              initialEntryMode: TimePickerEntryMode.input,
              helpText: '$label saati (${DateFormat('dd.MM.yyyy').format(baseDate)})',
            );
            if (saat == null) return;
            onChanged(DateTime(baseDate.year, baseDate.month, baseDate.day, saat.hour, saat.minute));
          },
          child: const Text('Seç'),
        ),
        if (deger != null)
          TextButton(onPressed: () => onChanged(null), child: const Text('Temizle')),
      ],
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
