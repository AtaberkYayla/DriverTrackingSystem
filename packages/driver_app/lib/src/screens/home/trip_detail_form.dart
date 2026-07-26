import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../local/app_database.dart';
import '../../providers/app_providers.dart';

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
    this.irsaliyeNo,
  });

  final String tripTypeId;
  final String requesterId;
  final String cikisNedeni;
  final String gidilenIl;
  final String? gidilenIlce;
  final String? gidilenSirketId;
  final String? gidilenSirketFree;
  final String? irsaliyeNo;
}

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
  final _irsaliyeNoController = TextEditingController();
  final _ilController = TextEditingController();
  final _ilceController = TextEditingController();
  final _sirketController = TextEditingController();

  TripTypesCacheData? _seciliTur;
  RequestersCacheData? _seciliTalepEden;
  CompaniesCacheData? _seciliSirket;
  String _seciliIl = '';

  @override
  void dispose() {
    _cikisNedeniController.dispose();
    _irsaliyeNoController.dispose();
    _ilController.dispose();
    _ilceController.dispose();
    _sirketController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tripTypesAsync = ref.watch(tripTypesProvider);
    final requestersAsync = ref.watch(requestersProvider);
    final companiesAsync = ref.watch(companiesProvider);
    final turkeyAsync = ref.watch(turkeyLocationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Firma Giris - Sefer Detaylari')),
      body: turkeyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Il/ilce verisi yuklenemedi: $e')),
        data: (turkey) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                tripTypesAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('Sefer turleri yuklenemedi: $e'),
                  data: (tripTypes) => DropdownButtonFormField<TripTypesCacheData>(
                    initialValue: _seciliTur,
                    decoration: const InputDecoration(
                      labelText: 'Seyahat Turu',
                      border: OutlineInputBorder(),
                    ),
                    items: tripTypes
                        .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                        .toList(),
                    onChanged: (v) => setState(() => _seciliTur = v),
                    validator: (v) => v == null ? 'Seyahat turu seciniz' : null,
                  ),
                ),
                const SizedBox(height: 16),
                requestersAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('Talep edenler yuklenemedi: $e'),
                  data: (requesters) => Autocomplete<RequestersCacheData>(
                    displayStringForOption: (r) => r.fullName,
                    optionsBuilder: (value) {
                      if (value.text.isEmpty) return requesters;
                      final q = value.text.toLowerCase();
                      return requesters.where((r) => r.fullName.toLowerCase().contains(q));
                    },
                    onSelected: (r) => setState(() => _seciliTalepEden = r),
                    fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Talep Eden Kisi',
                          border: OutlineInputBorder(),
                        ),
                        validator: (_) =>
                            _seciliTalepEden == null ? 'Talep eden kisi seciniz' : null,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cikisNedeniController,
                  decoration: const InputDecoration(
                    labelText: 'Cikis Nedeni / Gorev',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Cikis nedeni giriniz' : null,
                ),
                const SizedBox(height: 16),
                Autocomplete<String>(
                  optionsBuilder: (value) => turkey.ilAra(value.text),
                  onSelected: (il) {
                    setState(() {
                      _seciliIl = il;
                      _ilController.text = il;
                      _ilceController.clear();
                    });
                  },
                  fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                    controller.text = _ilController.text;
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        labelText: 'Gidilen Lokasyon (Il)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) => _seciliIl = v,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Gidilen il giriniz' : null,
                    );
                  },
                ),
                if (turkey.ilceZorunluMu(_seciliIl)) ...[
                  const SizedBox(height: 16),
                  Autocomplete<String>(
                    optionsBuilder: (value) => turkey.ilceAra(_seciliIl, value.text),
                    onSelected: (ilce) => _ilceController.text = ilce,
                    fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                      controller.text = _ilceController.text;
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Ilce',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (v) => _ilceController.text = v,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? '$_seciliIl icin ilce seciniz'
                            : null,
                      );
                    },
                  ),
                ],
                const SizedBox(height: 16),
                companiesAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('Sirketler yuklenemedi: $e'),
                  data: (companies) => Autocomplete<CompaniesCacheData>(
                    displayStringForOption: (c) => c.name,
                    optionsBuilder: (value) {
                      if (value.text.isEmpty) return companies;
                      final q = value.text.toLowerCase();
                      return companies.where((c) => c.name.toLowerCase().contains(q));
                    },
                    onSelected: (c) => setState(() {
                      _seciliSirket = c;
                      _sirketController.text = c.name;
                    }),
                    fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Gidilen Sirket',
                          helperText: 'Listede yoksa serbest metin olarak yazabilirsiniz',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (v) {
                          _sirketController.text = v;
                          if (_seciliSirket != null && _seciliSirket!.name != v) {
                            _seciliSirket = null;
                          }
                        },
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Gidilen sirket giriniz' : null,
                      );
                    },
                  ),
                ),
                if (_seciliTur?.requiresIrsaliye ?? false) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _irsaliyeNoController,
                    decoration: const InputDecoration(
                      labelText: 'Irsaliye No',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Bu seyahat turu icin irsaliye no zorunludur'
                        : null,
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _kaydet,
                  child: const Text('Firma Girisini Kaydet'),
                ),
              ],
            ),
          );
        },
      ),
    );
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
        irsaliyeNo: (_seciliTur?.requiresIrsaliye ?? false)
            ? _irsaliyeNoController.text.trim()
            : null,
      ),
    );
  }
}
