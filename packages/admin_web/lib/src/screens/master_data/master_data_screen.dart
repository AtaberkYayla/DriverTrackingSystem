import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;
import 'package:uuid/uuid.dart';

import '../../providers/app_providers.dart';

const _uuid = Uuid();

class MasterDataScreen extends StatelessWidget {
  const MasterDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Master Veri Yönetimi'),
          bottom: const TabBar(tabs: [
            Tab(text: 'Araçlar'),
            Tab(text: 'Seyahat Türleri'),
            Tab(text: 'Talep Edenler'),
            Tab(text: 'Şirketler'),
          ]),
        ),
        body: const TabBarView(children: [
          _VehiclesTab(),
          _TripTypesTab(),
          _RequestersTab(),
          _CompaniesTab(),
        ]),
      ),
    );
  }
}

/// Bir kaydi siler; baska bir seferde kullanildigi icin FK ihlali alinirsa
/// kullaniciya "pasife alin" onerisiyle anlasilir bir mesaj gosterir.
Future<void> _sil(
  BuildContext context,
  WidgetRef ref, {
  required String baslik,
  required Future<void> Function() sil,
  required void Function() sonrasindaGuncelle,
}) async {
  final onayVerildi = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(baslik),
      content: const Text('Bu kaydı tamamen silmek istediğinize emin misiniz?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İptal')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sil')),
      ],
    ),
  );
  if (onayVerildi != true) return;

  try {
    await sil();
    sonrasindaGuncelle();
  } on PostgrestException catch (e) {
    if (!context.mounted) return;
    final mesaj = e.code == '23503'
        ? 'Bu kayıt seferlerde kullanıldığı için silinemez. Pasife alabilirsiniz.'
        : 'Silinemedi: ${e.message}';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mesaj)));
  }
}

class _VehiclesTab extends ConsumerWidget {
  const _VehiclesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehiclesProvider);
    final duzenlenebilir = ref.watch(isManagerOrAdminProvider);
    return vehiclesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Hata: $e')),
      data: (vehicles) => Scaffold(
        body: ListView(
          children: vehicles
              .map((v) => ListTile(
                    title: Text(v.plaka),
                    subtitle: Text(v.aciklama ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: v.aktif,
                          onChanged: !duzenlenebilir
                              ? null
                              : (val) async {
                                  await ref.read(masterDataRepositoryProvider).upsertVehicle(
                                        Vehicle(
                                            id: v.id, plaka: v.plaka, aciklama: v.aciklama, aktif: val),
                                      );
                                  ref.invalidate(vehiclesProvider);
                                },
                        ),
                        if (duzenlenebilir)
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _sil(
                              context,
                              ref,
                              baslik: 'Aracı Sil',
                              sil: () => ref.read(masterDataRepositoryProvider).deleteVehicle(v.id),
                              sonrasindaGuncelle: () => ref.invalidate(vehiclesProvider),
                            ),
                          ),
                      ],
                    ),
                    onTap: duzenlenebilir ? () => _dialog(context, ref, v) : null,
                  ))
              .toList(),
        ),
        floatingActionButton: !duzenlenebilir
            ? null
            : FloatingActionButton(
                onPressed: () => _dialog(context, ref, null),
                child: const Icon(Icons.add),
              ),
      ),
    );
  }

  Future<void> _dialog(BuildContext context, WidgetRef ref, Vehicle? vehicle) async {
    final plakaController = TextEditingController(text: vehicle?.plaka);
    final aciklamaController = TextEditingController(text: vehicle?.aciklama);
    final kaydet = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(vehicle == null ? 'Yeni Araç' : 'Aracı Düzenle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: plakaController,
              decoration: const InputDecoration(labelText: 'Plaka'),
            ),
            TextField(
              controller: aciklamaController,
              decoration: const InputDecoration(labelText: 'Açıklama'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İptal')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Kaydet')),
        ],
      ),
    );
    if (kaydet != true || plakaController.text.trim().isEmpty) return;
    await ref.read(masterDataRepositoryProvider).upsertVehicle(Vehicle(
          id: vehicle?.id ?? _uuid.v4(),
          plaka: plakaController.text.trim(),
          aciklama: aciklamaController.text.trim().isEmpty ? null : aciklamaController.text.trim(),
          aktif: vehicle?.aktif ?? true,
        ));
    ref.invalidate(vehiclesProvider);
  }
}

class _TripTypesTab extends ConsumerWidget {
  const _TripTypesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripTypesAsync = ref.watch(tripTypesProvider);
    final duzenlenebilir = ref.watch(isManagerOrAdminProvider);
    return tripTypesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Hata: $e')),
      data: (tripTypes) => Scaffold(
        body: ListView(
          children: tripTypes
              .map((t) => ListTile(
                    title: Text(t.label),
                    subtitle: Text(t.requiresIrsaliye ? 'İrsaliye No zorunlu' : 'İrsaliye No istenmez'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: t.aktif,
                          onChanged: !duzenlenebilir
                              ? null
                              : (val) async {
                                  await ref.read(masterDataRepositoryProvider).upsertTripType(TripType(
                                        id: t.id,
                                        code: t.code,
                                        label: t.label,
                                        requiresIrsaliye: t.requiresIrsaliye,
                                        sira: t.sira,
                                        aktif: val,
                                      ));
                                  ref.invalidate(tripTypesProvider);
                                },
                        ),
                        if (duzenlenebilir)
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _sil(
                              context,
                              ref,
                              baslik: 'Seyahat Türünü Sil',
                              sil: () => ref.read(masterDataRepositoryProvider).deleteTripType(t.id),
                              sonrasindaGuncelle: () => ref.invalidate(tripTypesProvider),
                            ),
                          ),
                      ],
                    ),
                    onTap: duzenlenebilir ? () => _dialog(context, ref, t) : null,
                  ))
              .toList(),
        ),
        floatingActionButton: !duzenlenebilir
            ? null
            : FloatingActionButton(
                onPressed: () => _dialog(context, ref, null),
                child: const Icon(Icons.add),
              ),
      ),
    );
  }

  Future<void> _dialog(BuildContext context, WidgetRef ref, TripType? tripType) async {
    final labelController = TextEditingController(text: tripType?.label);
    final codeController = TextEditingController(text: tripType?.code);
    var irsaliyeGerekli = tripType?.requiresIrsaliye ?? false;
    final kaydet = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(tripType == null ? 'Yeni Seyahat Türü' : 'Seyahat Türünü Düzenle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelController,
                decoration: const InputDecoration(labelText: 'Ad (ör. Satın Alma Sevkiyatı)'),
              ),
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'Kod (ör. SATIN_ALMA_SEVKIYATI)'),
              ),
              SwitchListTile(
                title: const Text('İrsaliye No zorunlu'),
                value: irsaliyeGerekli,
                onChanged: (v) => setState(() => irsaliyeGerekli = v),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false), child: const Text('İptal')),
            FilledButton(
                onPressed: () => Navigator.pop(context, true), child: const Text('Kaydet')),
          ],
        ),
      ),
    );
    if (kaydet != true || labelController.text.trim().isEmpty) return;
    await ref.read(masterDataRepositoryProvider).upsertTripType(TripType(
          id: tripType?.id ?? _uuid.v4(),
          code: codeController.text.trim().isEmpty
              ? labelController.text.trim().toUpperCase().replaceAll(' ', '_')
              : codeController.text.trim(),
          label: labelController.text.trim(),
          requiresIrsaliye: irsaliyeGerekli,
          sira: tripType?.sira ?? 99,
          aktif: tripType?.aktif ?? true,
        ));
    ref.invalidate(tripTypesProvider);
  }
}

class _RequestersTab extends ConsumerWidget {
  const _RequestersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestersAsync = ref.watch(requestersProvider);
    final duzenlenebilir = ref.watch(isManagerOrAdminProvider);
    return requestersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Hata: $e')),
      data: (requesters) => Scaffold(
        body: ListView(
          children: requesters
              .map((r) => ListTile(
                    title: Text(r.fullName),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: r.aktif,
                          onChanged: !duzenlenebilir
                              ? null
                              : (val) async {
                                  await ref.read(masterDataRepositoryProvider).upsertRequester(
                                        Requester(id: r.id, fullName: r.fullName, aktif: val),
                                      );
                                  ref.invalidate(requestersProvider);
                                },
                        ),
                        if (duzenlenebilir)
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _sil(
                              context,
                              ref,
                              baslik: 'Talep Edeni Sil',
                              sil: () => ref.read(masterDataRepositoryProvider).deleteRequester(r.id),
                              sonrasindaGuncelle: () => ref.invalidate(requestersProvider),
                            ),
                          ),
                      ],
                    ),
                    onTap: duzenlenebilir ? () => _isimDuzenle(context, r.fullName, (isim) async {
                          await ref.read(masterDataRepositoryProvider).upsertRequester(
                                Requester(id: r.id, fullName: isim, aktif: r.aktif),
                              );
                          ref.invalidate(requestersProvider);
                        }) : null,
                  ))
              .toList(),
        ),
        floatingActionButton: !duzenlenebilir
            ? null
            : FloatingActionButton(
                onPressed: () => _isimEkle(
                  context,
                  'Yeni Talep Eden',
                  (isim) async {
                    await ref.read(masterDataRepositoryProvider).upsertRequester(
                          Requester(id: _uuid.v4(), fullName: isim),
                        );
                    ref.invalidate(requestersProvider);
                  },
                ),
                child: const Icon(Icons.add),
              ),
      ),
    );
  }
}


class _CompaniesTab extends ConsumerWidget {
  const _CompaniesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companiesAsync = ref.watch(companiesProvider);
    final duzenlenebilir = ref.watch(isManagerOrAdminProvider);
    return companiesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Hata: $e')),
      data: (companies) => Scaffold(
        body: ListView(
          children: companies
              .map((c) => ListTile(
                    title: Text(c.name),
                    subtitle: Text(c.sehir ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: c.aktif,
                          onChanged: !duzenlenebilir
                              ? null
                              : (val) async {
                                  await ref.read(masterDataRepositoryProvider).upsertCompany(
                                        Company(id: c.id, name: c.name, sehir: c.sehir, aktif: val),
                                      );
                                  ref.invalidate(companiesProvider);
                                },
                        ),
                        if (duzenlenebilir)
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _sil(
                              context,
                              ref,
                              baslik: 'Şirketi Sil',
                              sil: () => ref.read(masterDataRepositoryProvider).deleteCompany(c.id),
                              sonrasindaGuncelle: () => ref.invalidate(companiesProvider),
                            ),
                          ),
                      ],
                    ),
                    onTap: duzenlenebilir ? () => _dialog(context, ref, c) : null,
                  ))
              .toList(),
        ),
        floatingActionButton: !duzenlenebilir
            ? null
            : FloatingActionButton(
                onPressed: () => _dialog(context, ref, null),
                child: const Icon(Icons.add),
              ),
      ),
    );
  }

  Future<void> _dialog(BuildContext context, WidgetRef ref, Company? company) async {
    final nameController = TextEditingController(text: company?.name);
    final sehirController = TextEditingController(text: company?.sehir);
    final kaydet = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(company == null ? 'Yeni Şirket' : 'Şirketi Düzenle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Şirket Adı'),
            ),
            TextField(
              controller: sehirController,
              decoration: const InputDecoration(labelText: 'Şehir'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İptal')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Kaydet')),
        ],
      ),
    );
    if (kaydet != true || nameController.text.trim().isEmpty) return;
    await ref.read(masterDataRepositoryProvider).upsertCompany(Company(
          id: company?.id ?? _uuid.v4(),
          name: nameController.text.trim(),
          sehir: sehirController.text.trim().isEmpty ? null : sehirController.text.trim(),
          aktif: company?.aktif ?? true,
        ));
    ref.invalidate(companiesProvider);
  }
}

Future<void> _isimEkle(
  BuildContext context,
  String baslik,
  Future<void> Function(String isim) onKaydet,
) async {
  final controller = TextEditingController();
  final kaydet = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(baslik),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(labelText: 'Ad Soyad'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İptal')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Kaydet')),
      ],
    ),
  );
  if (kaydet == true && controller.text.trim().isNotEmpty) {
    await onKaydet(controller.text.trim());
  }
}

Future<void> _isimDuzenle(
  BuildContext context,
  String mevcutIsim,
  Future<void> Function(String isim) onKaydet,
) async {
  final controller = TextEditingController(text: mevcutIsim);
  final kaydet = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Adı Düzenle'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(labelText: 'Ad Soyad'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İptal')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Kaydet')),
      ],
    ),
  );
  if (kaydet == true && controller.text.trim().isNotEmpty) {
    await onKaydet(controller.text.trim());
  }
}
