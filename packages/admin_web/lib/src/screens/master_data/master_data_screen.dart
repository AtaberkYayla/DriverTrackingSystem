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

/// Bir Talep Eden aslinda sistemde giris yapip onay verebilen bir hesaba
/// (profiles/auth.users) karsilik gelir (requesters.profile_id). Bu yuzden
/// bu sekme sadece isim degil, o kisinin giris hesabini da (e-posta+sifre)
/// olusturur/gunceller - aksi halde o kisi sisteme hic giremez.
class _RequestersTab extends ConsumerWidget {
  const _RequestersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestersAsync = ref.watch(requestersProvider);
    final duzenlenebilir = ref.watch(isManagerOrAdminProvider);
    final emailById = <String, String>{
      if (duzenlenebilir)
        for (final a in (ref.watch(accountsProvider).value ?? const <Account>[])) a.id: a.email,
    };

    return requestersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Hata: $e')),
      data: (requesters) => Scaffold(
        body: ListView(
          children: requesters
              .map((r) => ListTile(
                    title: Text(r.fullName),
                    subtitle: Text(
                      r.profileId == null
                          ? 'Giriş hesabı yok'
                          : (emailById[r.profileId] ?? 'Giriş hesabı var'),
                      style: TextStyle(
                        color: r.profileId == null ? Colors.orange.shade800 : Colors.grey.shade600,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: r.aktif,
                          onChanged: !duzenlenebilir
                              ? null
                              : (val) async {
                                  await ref.read(masterDataRepositoryProvider).upsertRequester(
                                        Requester(
                                          id: r.id,
                                          fullName: r.fullName,
                                          aktif: val,
                                          profileId: r.profileId,
                                        ),
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
                    onTap: duzenlenebilir
                        ? () => _talepEdenDialog(
                              context,
                              ref,
                              requester: r,
                              mevcutEmail: emailById[r.profileId],
                            )
                        : null,
                  ))
              .toList(),
        ),
        floatingActionButton: !duzenlenebilir
            ? null
            : FloatingActionButton(
                onPressed: () => _talepEdenDialog(context, ref),
                child: const Icon(Icons.add),
              ),
      ),
    );
  }

  Future<void> _talepEdenDialog(
    BuildContext context,
    WidgetRef ref, {
    Requester? requester,
    String? mevcutEmail,
  }) async {
    final adController = TextEditingController(text: requester?.fullName);
    final emailController = TextEditingController(text: mevcutEmail);
    final sifreController = TextEditingController();
    final hesapVar = requester?.profileId != null;

    final kaydet = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(requester == null ? 'Yeni Talep Eden' : 'Talep Edeni Düzenle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: adController,
              decoration: const InputDecoration(labelText: 'Ad Soyad'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'E-posta (giriş için)',
                helperText: hesapVar
                    ? 'Bu talep edenin giriş yaptığı hesabın e-postası.'
                    : 'Bu kişinin sisteme girip onay verebilmesi için bir hesap oluşturulur.',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: sifreController,
              decoration: InputDecoration(
                labelText: hesapVar ? 'Yeni Şifre (opsiyonel)' : 'Şifre',
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İptal')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Kaydet')),
        ],
      ),
    );

    if (kaydet != true) return;
    final ad = adController.text.trim();
    final email = emailController.text.trim();
    final sifre = sifreController.text;
    if (ad.isEmpty) return;

    if (!hesapVar && email.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Yeni bir talep eden için e-posta ve şifre girmelisiniz; aksi halde bu kişi sisteme giriş yapıp onay veremez.',
          ),
        ),
      );
      return;
    }
    if (!hesapVar && sifre.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hesap oluşturmak için şifre girmelisiniz.')),
      );
      return;
    }

    try {
      final accountRepo = ref.read(accountRepositoryProvider);
      var profileId = requester?.profileId;

      if (profileId == null) {
        profileId = await accountRepo.createAccount(
          fullName: ad,
          email: email,
          password: sifre,
          role: AppRole.office,
        );
      } else if (email.isNotEmpty || sifre.isNotEmpty) {
        await accountRepo.updateAccount(
          userId: profileId,
          fullName: ad,
          email: email.isEmpty ? null : email,
          password: sifre.isEmpty ? null : sifre,
        );
      } else {
        await accountRepo.updateAccount(userId: profileId, fullName: ad);
      }

      await ref.read(masterDataRepositoryProvider).upsertRequester(
            Requester(
              id: requester?.id ?? _uuid.v4(),
              fullName: ad,
              aktif: requester?.aktif ?? true,
              profileId: profileId,
            ),
          );
      ref.invalidate(requestersProvider);
      ref.invalidate(accountsProvider);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
    }
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
