import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../providers/app_providers.dart';

const _uuid = Uuid();

class MasterDataScreen extends StatelessWidget {
  const MasterDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Master Veri Yonetimi'),
          bottom: const TabBar(tabs: [
            Tab(text: 'Araclar'),
            Tab(text: 'Seyahat Turleri'),
            Tab(text: 'Talep Edenler'),
            Tab(text: 'Yoneticiler'),
            Tab(text: 'Sirketler'),
          ]),
        ),
        body: const TabBarView(children: [
          _VehiclesTab(),
          _TripTypesTab(),
          _RequestersTab(),
          _ManagersTab(),
          _CompaniesTab(),
        ]),
      ),
    );
  }
}

class _VehiclesTab extends ConsumerWidget {
  const _VehiclesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehiclesProvider);
    return vehiclesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Hata: $e')),
      data: (vehicles) => Scaffold(
        body: ListView(
          children: vehicles
              .map((v) => ListTile(
                    title: Text(v.plaka),
                    subtitle: Text(v.aciklama ?? ''),
                    trailing: Switch(
                      value: v.aktif,
                      onChanged: (val) async {
                        await ref.read(masterDataRepositoryProvider).upsertVehicle(
                              Vehicle(id: v.id, plaka: v.plaka, aciklama: v.aciklama, aktif: val),
                            );
                        ref.invalidate(vehiclesProvider);
                      },
                    ),
                    onTap: () => _dialog(context, ref, v),
                  ))
              .toList(),
        ),
        floatingActionButton: FloatingActionButton(
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
        title: Text(vehicle == null ? 'Yeni Arac' : 'Araci Duzenle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: plakaController,
              decoration: const InputDecoration(labelText: 'Plaka'),
            ),
            TextField(
              controller: aciklamaController,
              decoration: const InputDecoration(labelText: 'Aciklama'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Iptal')),
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
    return tripTypesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Hata: $e')),
      data: (tripTypes) => Scaffold(
        body: ListView(
          children: tripTypes
              .map((t) => ListTile(
                    title: Text(t.label),
                    subtitle: Text(t.requiresIrsaliye ? 'Irsaliye No zorunlu' : 'Irsaliye No istenmez'),
                    trailing: Switch(
                      value: t.aktif,
                      onChanged: (val) async {
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
                    onTap: () => _dialog(context, ref, t),
                  ))
              .toList(),
        ),
        floatingActionButton: FloatingActionButton(
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
          title: Text(tripType == null ? 'Yeni Seyahat Turu' : 'Seyahat Turunu Duzenle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelController,
                decoration: const InputDecoration(labelText: 'Ad (ör. Satin Alma Sevkiyati)'),
              ),
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'Kod (ör. SATIN_ALMA_SEVKIYATI)'),
              ),
              SwitchListTile(
                title: const Text('Irsaliye No zorunlu'),
                value: irsaliyeGerekli,
                onChanged: (v) => setState(() => irsaliyeGerekli = v),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false), child: const Text('Iptal')),
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
    return requestersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Hata: $e')),
      data: (requesters) => Scaffold(
        body: ListView(
          children: requesters
              .map((r) => ListTile(
                    title: Text(r.fullName),
                    trailing: Switch(
                      value: r.aktif,
                      onChanged: (val) async {
                        await ref.read(masterDataRepositoryProvider).upsertRequester(
                              Requester(id: r.id, fullName: r.fullName, aktif: val),
                            );
                        ref.invalidate(requestersProvider);
                      },
                    ),
                  ))
              .toList(),
        ),
        floatingActionButton: FloatingActionButton(
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

class _ManagersTab extends ConsumerWidget {
  const _ManagersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final managersAsync = ref.watch(managersProvider);
    return managersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Hata: $e')),
      data: (managers) => Scaffold(
        body: ListView(
          children: managers
              .map((m) => ListTile(
                    title: Text(m.fullName),
                    trailing: Switch(
                      value: m.aktif,
                      onChanged: (val) async {
                        await ref.read(masterDataRepositoryProvider).upsertManager(
                              Manager(id: m.id, fullName: m.fullName, aktif: val),
                            );
                        ref.invalidate(managersProvider);
                      },
                    ),
                  ))
              .toList(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _isimEkle(
            context,
            'Yeni Yonetici',
            (isim) async {
              await ref.read(masterDataRepositoryProvider).upsertManager(
                    Manager(id: _uuid.v4(), fullName: isim),
                  );
              ref.invalidate(managersProvider);
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
    return companiesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Hata: $e')),
      data: (companies) => Scaffold(
        body: ListView(
          children: companies
              .map((c) => ListTile(
                    title: Text(c.name),
                    subtitle: Text(c.sehir ?? ''),
                    trailing: Switch(
                      value: c.aktif,
                      onChanged: (val) async {
                        await ref.read(masterDataRepositoryProvider).upsertCompany(
                              Company(id: c.id, name: c.name, sehir: c.sehir, aktif: val),
                            );
                        ref.invalidate(companiesProvider);
                      },
                    ),
                    onTap: () => _dialog(context, ref, c),
                  ))
              .toList(),
        ),
        floatingActionButton: FloatingActionButton(
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
        title: Text(company == null ? 'Yeni Sirket' : 'Sirketi Duzenle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Sirket Adi'),
            ),
            TextField(
              controller: sehirController,
              decoration: const InputDecoration(labelText: 'Sehir'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Iptal')),
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
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Iptal')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Kaydet')),
      ],
    ),
  );
  if (kaydet == true && controller.text.trim().isNotEmpty) {
    await onKaydet(controller.text.trim());
  }
}
