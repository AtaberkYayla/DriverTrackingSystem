import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../providers/app_providers.dart';
import '../../widgets/tarih_saat_secici.dart';

const _uuid = Uuid();

/// Gidilebilecek lokasyonlar bu sekiz il ile sinirlidir (bkz. driver_app'teki
/// ayni isimli/amacli liste, trip_detail_form.dart). Izmir ve Manisa icin
/// il_ilce.json'da gercek ilce listesi bulundugundan secim zorunlu bir
/// listeden yapilir; digerlerinde ilce verisi olmadigi icin serbest metin
/// olarak (istege bagli) girilir.
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

/// Bir durak (trip_stop) icin elle giris formunun tuttugu alanlar - her biri
/// listede bir kart olarak gosterilir, "Durak Ekle" ile cogaltilabilir.
class _StopForm {
  _StopForm();

  String? tripTypeId;
  String? requesterId;
  final cikisNedeniController = TextEditingController();
  final gidilenIlController = TextEditingController();
  final gidilenIlceController = TextEditingController();
  // Metin kutusundaki il, _izinVerilenIller listesinden gecerli bir secimle
  // mi eslesiyor - ilceyi (zorunlu/serbest) buna gore belirlemek icin.
  String? seciliIl;
  String? sirketId;
  final sirketFreeController = TextEditingController();
  final irsaliyeNoGirisController = TextEditingController();
  final irsaliyeNoCikisController = TextEditingController();
  final notlarController = TextEditingController();
  final notlarCikisController = TextEditingController();
  DateTime? firmaGirisAt;
  DateTime? firmaCikisAt;

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

/// admin_web'den elle ("unutulmus"/gecmise donuk) bir sefer olusturma ekrani.
/// Yonetici/admin ve operator kullanir - operator sadece burada olusturdugu
/// seferi sonradan duzenleyebilir (bkz. trip_detail_screen, backend
/// created_by_user_id/requireTripOwnershipIfOperator).
class CreateTripScreen extends ConsumerStatefulWidget {
  const CreateTripScreen({super.key});

  @override
  ConsumerState<CreateTripScreen> createState() => _CreateTripScreenState();
}

final _gunAyYilFormat = DateFormat('dd.MM.yyyy');

/// "GG.AA.YYYY" metnini DateTime'a cevirir, gecersiz/eksikse null doner.
DateTime? _gunAyYiliAyristir(String metin) {
  try {
    return _gunAyYilFormat.parseStrict(metin.trim());
  } catch (_) {
    return null;
  }
}

class _CreateTripScreenState extends ConsumerState<CreateTripScreen> {
  String? _seciliDriverId;
  String? _seciliVehicleId;
  late final _tarihController = TextEditingController(text: _gunAyYilFormat.format(bugununTarihi()));
  DateTime? _fabrikaCikisAt;
  DateTime? _fabrikaGirisAt;
  final List<_StopForm> _duraklar = [_StopForm()];
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

    if (_seciliDriverId == null || _seciliVehicleId == null || _tarihController.text.trim().isEmpty) {
      setState(() => _hata = 'Şoför, araç plakası ve tarih zorunlu.');
      return;
    }
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
      final trip = await repo.upsertTrip(Trip(
        id: '',
        clientTripId: _uuid.v4(),
        driverId: _seciliDriverId!,
        vehicleId: _seciliVehicleId!,
        tarih: DateFormat('yyyy-MM-dd').format(seciliTarih),
        fabrikaCikisAt: _fabrikaCikisAt,
        fabrikaGirisAt: _fabrikaGirisAt,
      ));

      for (var i = 0; i < _duraklar.length; i++) {
        final durak = _duraklar[i];
        await repo.upsertTripStop(TripStop(
          id: '',
          clientStopId: _uuid.v4(),
          tripId: trip.id,
          sira: i,
          firmaGirisAt: durak.firmaGirisAt!,
          tripTypeId: durak.tripTypeId,
          requesterId: durak.requesterId,
          cikisNedeni: durak.cikisNedeniController.text.trim().isEmpty
              ? null
              : durak.cikisNedeniController.text.trim(),
          gidilenIl:
              durak.gidilenIlController.text.trim().isEmpty ? null : durak.gidilenIlController.text.trim(),
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
          notlar:
              durak.notlarController.text.trim().isEmpty ? null : durak.notlarController.text.trim(),
          notlarCikis: durak.notlarCikisController.text.trim().isEmpty
              ? null
              : durak.notlarCikisController.text.trim(),
        ));
      }

      ref.invalidate(tripListProvider);
      if (mounted) Navigator.of(context).pop();
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

    return Scaffold(
      appBar: AppBar(title: const Text('Sefer Oluştur')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          driversAsync.maybeWhen(
            data: (drivers) => DropdownButtonFormField<String>(
              initialValue: _seciliDriverId,
              decoration: const InputDecoration(labelText: 'Şoför', border: OutlineInputBorder()),
              items: drivers.map((d) => DropdownMenuItem(value: d.id, child: Text(d.fullName))).toList(),
              onChanged: (v) => setState(() => _seciliDriverId = v),
            ),
            orElse: () => const LinearProgressIndicator(),
          ),
          const SizedBox(height: 16),
          vehiclesAsync.maybeWhen(
            data: (vehicles) => DropdownButtonFormField<String>(
              initialValue: _seciliVehicleId,
              decoration: const InputDecoration(labelText: 'Araç Plakası', border: OutlineInputBorder()),
              items: vehicles.map((v) => DropdownMenuItem(value: v.id, child: Text(v.plaka))).toList(),
              onChanged: (v) => setState(() => _seciliVehicleId = v),
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
          // "Durak Ekle" butonu bilinçli olarak 1. durağın hemen altında:
          // yeni bir durak eklerken önce mevcut ilk durağı görmek daha
          // az yanlış tıklamaya yol açıyor.
          for (var i = 0; i < _duraklar.length; i++) ...[
            _durakKarti(i, _duraklar[i]),
            const SizedBox(height: 12),
            if (i == 0) ...[
              OutlinedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Durak Ekle'),
                onPressed: () => setState(() => _duraklar.add(_StopForm())),
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

  Widget _durakKarti(int index, _StopForm durak) {
    final tripTypesAsync = ref.watch(tripTypesProvider);
    final requestersAsync = ref.watch(requestersProvider);
    final companiesAsync = ref.watch(companiesProvider);
    final turkeyAsync = ref.watch(turkeyLocationsProvider);

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
                if (_duraklar.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Durağı Kaldır',
                    onPressed: () => setState(() {
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
                decoration: const InputDecoration(labelText: 'Seyahat Türü', border: OutlineInputBorder()),
                items: [
                  const DropdownMenuItem(value: null, child: Text('-')),
                  ...tripTypes.map((t) => DropdownMenuItem(value: t.id, child: Text(t.label))),
                ],
                onChanged: (v) => setState(() => durak.tripTypeId = v),
              ),
              orElse: () => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            requestersAsync.maybeWhen(
              data: (requesters) => DropdownButtonFormField<String?>(
                initialValue: durak.requesterId,
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
              data: (turkey) => _ilIlceAlanlari(durak, turkey),
              orElse: () => const LinearProgressIndicator(),
            ),
            const SizedBox(height: 16),
            companiesAsync.maybeWhen(
              data: (companies) => DropdownButtonFormField<String?>(
                initialValue: durak.sirketId,
                decoration:
                    const InputDecoration(labelText: 'Gidilen Şirket', border: OutlineInputBorder()),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Listede yok / serbest metin')),
                  ...companies.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
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
          ],
        ),
      ),
    );
  }

  /// Gidilen il/ilce alanlari: il, sabit _izinVerilenIller listesinden
  /// secilir (serbest metne izin verilmez); Izmir/Manisa icin ilce de
  /// il_ilce.json'daki listeden secilir, digerlerinde ilce serbest metindir.
  Widget _ilIlceAlanlari(_StopForm durak, TurkeyLocations turkey) {
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
            durak.seciliIl = il;
            durak.gidilenIlController.text = il;
            durak.gidilenIlceController.clear();
          }),
          fieldViewBuilder: (context, controller, focusNode, onSubmit) {
            controller.text = durak.gidilenIlController.text;
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              decoration: const InputDecoration(labelText: 'Gidilen İl', border: OutlineInputBorder()),
              onChanged: (v) {
                durak.gidilenIlController.text = v;
                if (durak.seciliIl != v) {
                  setState(() {
                    durak.seciliIl = null;
                    durak.gidilenIlceController.clear();
                  });
                }
              },
            );
          },
        ),
        if (durak.seciliIl != null) ...[
          const SizedBox(height: 16),
          if (turkey.ilceZorunluMu(durak.seciliIl!))
            Autocomplete<String>(
              key: ValueKey('ilce-${durak.seciliIl}'),
              optionsBuilder: (value) => turkey.ilceAra(durak.seciliIl!, value.text),
              onSelected: (ilce) => durak.gidilenIlceController.text = ilce,
              fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                controller.text = durak.gidilenIlceController.text;
                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration:
                      const InputDecoration(labelText: 'Gidilen İlçe', border: OutlineInputBorder()),
                  onChanged: (v) => durak.gidilenIlceController.text = v,
                );
              },
            )
          else
            TextFormField(
              controller: durak.gidilenIlceController,
              decoration: const InputDecoration(
                  labelText: 'Gidilen İlçe (opsiyonel)', border: OutlineInputBorder()),
            ),
        ],
      ],
    );
  }

}
