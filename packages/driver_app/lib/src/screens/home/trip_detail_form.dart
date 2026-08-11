import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../local/app_database.dart';
import '../../providers/app_providers.dart';
import '../../widgets/autocomplete_options_view.dart';

/// "Firma Giris" asamasinda soforun doldurdugu sefer detaylari.
class TripDetailFormResult {
  const TripDetailFormResult({
    required this.tripTypeId,
    required this.requesterId,
    required this.cikisNedeni,
    required this.gidilenIl,
    this.gidilenIlce,
    this.gidilenSirketId,
    this.gidilenSirketFree,
    this.irsaliyeNoGiris,
    this.notlar,
  });

  final String tripTypeId;
  final String requesterId;
  final String cikisNedeni;
  final String gidilenIl;
  final String? gidilenIlce;
  final String? gidilenSirketId;
  final String? gidilenSirketFree;
  final String? irsaliyeNoGiris;
  final String? notlar;
}

/// Gidilebilecek lokasyonlar bu sekiz il ile sinirlidir. Izmir ve Manisa
/// icin il_ilce.json'da gercek ilce listesi bulundugundan secim zorunlu bir
/// listeden yapilir; digerlerinde ilce verisi olmadigi icin sofor ilceyi
/// serbest metin olarak (istege bagli) girer.
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


Future<TripDetailFormResult?> showTripDetailForm(BuildContext context) {
  return Navigator.of(context).push<TripDetailFormResult>(
    MaterialPageRoute(builder: (_) => const TripDetailFormScreen()),
  );
}

class TripDetailFormScreen extends ConsumerStatefulWidget {
  const TripDetailFormScreen({super.key});

  @override
  ConsumerState<TripDetailFormScreen> createState() => _TripDetailFormScreenState();
}

class _TripDetailFormScreenState extends ConsumerState<TripDetailFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cikisNedeniController = TextEditingController();
  final _irsaliyeNoGirisController = TextEditingController();
  final _ilController = TextEditingController();
  final _ilceController = TextEditingController();
  final _sirketController = TextEditingController();
  final _notlarController = TextEditingController();

  TripTypesCacheData? _seciliTur;
  RequestersCacheData? _seciliTalepEden;
  CompaniesCacheData? _seciliSirket;
  String _seciliIl = '';

  @override
  void dispose() {
    _cikisNedeniController.dispose();
    _irsaliyeNoGirisController.dispose();
    _ilController.dispose();
    _ilceController.dispose();
    _sirketController.dispose();
    _notlarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tripTypesAsync = ref.watch(tripTypesProvider);
    final requestersAsync = ref.watch(requestersProvider);
    final companiesAsync = ref.watch(companiesProvider);
    final turkeyAsync = ref.watch(turkeyLocationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Firma Giriş - Sefer Detayları')),
      body: turkeyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('İl/ilçe verisi yüklenemedi: $e')),
        data: (turkey) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                tripTypesAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('Sefer türleri yüklenemedi: $e'),
                  data: (tripTypes) => DropdownButtonFormField<TripTypesCacheData>(
                    initialValue: _seciliTur,
                    decoration: const InputDecoration(
                      labelText: 'Seyahat Türü',
                      border: OutlineInputBorder(),
                    ),
                    items: tripTypes
                        .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                        .toList(),
                    onChanged: (v) => setState(() => _seciliTur = v),
                    validator: (v) => v == null ? 'Seyahat türü seçiniz' : null,
                  ),
                ),
                const SizedBox(height: 16),
                requestersAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('Talep edenler yüklenemedi: $e'),
                  data: (requesters) => Autocomplete<RequestersCacheData>(
                    displayStringForOption: (r) => r.fullName,
                    optionsBuilder: (value) {
                      if (value.text.isEmpty) return requesters;
                      final q = value.text.toLowerCase();
                      return requesters.where((r) => r.fullName.toLowerCase().contains(q));
                    },
                    optionsViewBuilder: (context, onSelected, options) => buildAutocompleteOptionsView(
                      options: options,
                      onSelected: onSelected,
                      displayStringForOption: (r) => r.fullName,
                    ),
                    onSelected: (r) => setState(() => _seciliTalepEden = r),
                    fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Talep Eden Kişi',
                          border: OutlineInputBorder(),
                        ),
                        validator: (_) =>
                            _seciliTalepEden == null ? 'Talep eden kişi seçiniz' : null,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cikisNedeniController,
                  decoration: const InputDecoration(
                    labelText: 'Çıkış Nedeni / Görev',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Çıkış nedeni giriniz' : null,
                ),
                const SizedBox(height: 16),
                Autocomplete<String>(
                  optionsBuilder: (value) {
                    if (value.text.isEmpty) return _izinVerilenIller;
                    final q = value.text.toLowerCase();
                    return _izinVerilenIller.where((il) => il.toLowerCase().contains(q));
                  },
                  optionsViewBuilder: (context, onSelected, options) => buildAutocompleteOptionsView(
                    options: options,
                    onSelected: onSelected,
                    displayStringForOption: RawAutocomplete.defaultStringForOption,
                  ),
                  onSelected: (il) => setState(() {
                    _seciliIl = il;
                    _ilController.text = il;
                    _ilceController.clear();
                  }),
                  fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                    controller.text = _ilController.text;
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        labelText: 'Gidilen Lokasyon (İl)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) {
                        _ilController.text = v;
                        if (_seciliIl != v) {
                          setState(() {
                            _seciliIl = '';
                            _ilceController.clear();
                          });
                        }
                      },
                      validator: (v) => (v == null || !_izinVerilenIller.contains(v))
                          ? 'Listeden geçerli bir il seçiniz'
                          : null,
                    );
                  },
                ),
                if (_seciliIl.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  if (turkey.ilceZorunluMu(_seciliIl))
                    Autocomplete<String>(
                      key: ValueKey('ilce-$_seciliIl'),
                      optionsBuilder: (value) => turkey.ilceAra(_seciliIl, value.text),
                      optionsViewBuilder: (context, onSelected, options) => buildAutocompleteOptionsView(
                        options: options,
                        onSelected: onSelected,
                        displayStringForOption: RawAutocomplete.defaultStringForOption,
                      ),
                      onSelected: (ilce) => _ilceController.text = ilce,
                      fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                        controller.text = _ilceController.text;
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: const InputDecoration(
                            labelText: 'İlçe',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (v) => _ilceController.text = v,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? '$_seciliIl için ilçe seçiniz'
                              : null,
                        );
                      },
                    )
                  else
                    TextFormField(
                      controller: _ilceController,
                      decoration: const InputDecoration(
                        labelText: 'İlçe (opsiyonel)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                ],
                const SizedBox(height: 16),
                if (_sirketAutocompleteGosterilsinMi(companiesAsync))
                  companiesAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Şirketler yüklenemedi: $e'),
                    data: (companies) => Autocomplete<CompaniesCacheData>(
                      displayStringForOption: (c) => c.name,
                      optionsBuilder: (value) {
                        final kategoriye = _turUyumluSirketler(companies);
                        if (value.text.isEmpty) return kategoriye;
                        final q = value.text.toLowerCase();
                        return kategoriye.where((c) => c.name.toLowerCase().contains(q));
                      },
                      optionsViewBuilder: (context, onSelected, options) => buildAutocompleteOptionsView(
                        options: options,
                        onSelected: onSelected,
                        displayStringForOption: (c) => c.name,
                      ),
                      onSelected: (c) => setState(() {
                        _seciliSirket = c;
                        _sirketController.text = c.name;
                      }),
                      fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                        final bankaMi = _seciliTur?.code == 'BANKA';
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            labelText: bankaMi ? 'Gidilen Banka' : 'Gidilen Şirket',
                            helperText: 'Listede yoksa serbest metin olarak yazabilirsiniz',
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (v) {
                            _sirketController.text = v;
                            if (_seciliSirket != null && _seciliSirket!.name != v) {
                              _seciliSirket = null;
                            }
                          },
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? (bankaMi ? 'Gidilen banka giriniz' : 'Gidilen şirket giriniz')
                              : null,
                        );
                      },
                    ),
                  )
                else
                  TextFormField(
                    controller: _sirketController,
                    decoration: const InputDecoration(
                      labelText: 'Gidilen Şirket / Yer',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) {
                      if (_seciliSirket != null) _seciliSirket = null;
                    },
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Gidilen şirket/yer giriniz' : null,
                  ),
                if (_seciliTur?.requiresIrsaliye ?? false) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _irsaliyeNoGirisController,
                    decoration: const InputDecoration(
                      labelText: 'İrsaliye No (Giriş)',
                      helperText: 'Biliyorsanız girin, zorunlu değil',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
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
                  onPressed: _kaydet,
                  child: const Text('Firma Girişini Kaydet'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _sirketKategoriUyumlu(CompaniesCacheData c, String turId) =>
      c.tripTypeIds.split(',').contains(turId);

  /// Bir sirket firma-otomatik-tamamlama alaninin gosterilip gosterilmeyecegini
  /// belirler: secili sefer turu icin kategorize edilmis en az bir sirket varsa
  /// (irsaliye gerektiren turlerde her zaman en az biri olmasi beklenir).
  bool _sirketAutocompleteGosterilsinMi(AsyncValue<List<CompaniesCacheData>> companiesAsync) {
    final tur = _seciliTur;
    if (tur == null) return false;
    if (tur.requiresIrsaliye) return true;
    final companies = companiesAsync.value;
    return companies != null && companies.any((c) => _sirketKategoriUyumlu(c, tur.id));
  }

  /// Secili sefer turune (kategoriye) etiketlenmis sirketleri filtreler.
  List<CompaniesCacheData> _turUyumluSirketler(List<CompaniesCacheData> companies) {
    final tur = _seciliTur;
    if (tur == null) return const [];
    return companies.where((c) => _sirketKategoriUyumlu(c, tur.id)).toList();
  }

  void _kaydet() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      TripDetailFormResult(
        tripTypeId: _seciliTur!.id,
        requesterId: _seciliTalepEden!.id,
        cikisNedeni: _cikisNedeniController.text.trim(),
        gidilenIl: _seciliIl,
        gidilenIlce: _ilceController.text.trim().isEmpty ? null : _ilceController.text.trim(),
        gidilenSirketId: _seciliSirket?.id,
        gidilenSirketFree: _seciliSirket == null ? _sirketController.text.trim() : null,
        irsaliyeNoGiris: (_seciliTur?.requiresIrsaliye ?? false)
            ? (_irsaliyeNoGirisController.text.trim().isEmpty
                ? null
                : _irsaliyeNoGirisController.text.trim())
            : null,
        notlar: _notlarController.text.trim().isEmpty ? null : _notlarController.text.trim(),
      ),
    );
  }
}
