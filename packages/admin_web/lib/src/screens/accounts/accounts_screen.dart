import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';

const _rolAdlari = {
  AppRole.admin: 'Admin',
  AppRole.manager: 'Yönetici',
  AppRole.office: 'Onay Verici',
  AppRole.driver: 'Şoför',
};

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsProvider);
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Kullanıcılar')),
      body: accountsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
        data: (accounts) {
          final gruplar = <AppRole, List<Account>>{
            for (final rol in AppRole.values) rol: accounts.where((a) => a.role == rol).toList(),
          };
          return ListView(
            padding: const EdgeInsets.all(8),
            children: [
              for (final rol in [AppRole.admin, AppRole.manager, AppRole.office, AppRole.driver])
                if (gruplar[rol]!.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 16, 8, 4),
                    child: Text(
                      _rolAdlari[rol]!,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  for (final acc in gruplar[rol]!)
                    Card(
                      child: ListTile(
                        title: Text(acc.fullName),
                        subtitle: Text(acc.username),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: acc.aktif,
                              onChanged: (val) async {
                                await ref
                                    .read(accountRepositoryProvider)
                                    .updateAccount(userId: acc.id, aktif: val);
                                ref.invalidate(accountsProvider);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => _hesapDialog(context, ref, isAdmin, account: acc),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _hesapDialog(context, ref, isAdmin),
        child: const Icon(Icons.person_add_alt_1_outlined),
      ),
    );
  }

  Future<void> _hesapDialog(
    BuildContext context,
    WidgetRef ref,
    bool isAdmin, {
    Account? account,
  }) async {
    final duzenlemeModu = account != null;
    // Yonetici (manager, admin degil) sadece sofor/onay verici hesabi
    // olusturup duzenleyebilir; baska bir yonetici/admin hesabina hic
    // dokunamaz (sunucu tarafi zaten bunu zorunlu kilar, bu sadece arayuz
    // tarafinda ayni kurali onceden gostermek icin).
    if (duzenlemeModu && !isAdmin && (account.role == AppRole.manager || account.role == AppRole.admin)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yönetici veya admin hesaplarını sadece admin düzenleyebilir.')),
      );
      return;
    }

    // Onay Verici (office) hesabi artik olusturulmuyor - admin_web'e sadece
    // yonetici/admin girer. Yonetici sadece sofor hesabi acabilir; admin
    // ayrica baska yonetici/admin de acabilir.
    final secilebilirRoller = isAdmin
        ? const [AppRole.driver, AppRole.manager, AppRole.admin]
        : const [AppRole.driver];

    final fullNameController = TextEditingController(text: account?.fullName);
    final usernameController = TextEditingController(text: account?.username);
    final passwordController = TextEditingController();
    var seciliRol = account?.role ?? AppRole.office;

    final kaydet = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(duzenlemeModu ? 'Hesabı Düzenle' : 'Yeni Hesap'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: fullNameController,
                decoration: const InputDecoration(labelText: 'Ad Soyad'),
              ),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Kullanıcı Adı'),
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: duzenlemeModu ? 'Yeni Şifre (opsiyonel)' : 'Şifre',
                ),
              ),
              DropdownButtonFormField<AppRole>(
                initialValue: seciliRol,
                decoration: const InputDecoration(labelText: 'Rol'),
                items: secilebilirRoller
                    .map((r) => DropdownMenuItem(value: r, child: Text(_rolAdlari[r]!)))
                    .toList(),
                onChanged: (v) => setState(() => seciliRol = v ?? seciliRol),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İptal')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Kaydet')),
          ],
        ),
      ),
    );

    if (kaydet != true || fullNameController.text.trim().isEmpty) return;

    final repo = ref.read(accountRepositoryProvider);
    try {
      if (duzenlemeModu) {
        await repo.updateAccount(
          userId: account.id,
          fullName: fullNameController.text.trim(),
          username: usernameController.text.trim().isEmpty ? null : usernameController.text.trim(),
          password: passwordController.text.isEmpty ? null : passwordController.text,
          role: seciliRol,
        );
      } else {
        await repo.createAccount(
          fullName: fullNameController.text.trim(),
          username: usernameController.text.trim(),
          password: passwordController.text,
          role: seciliRol,
        );
      }
      ref.invalidate(accountsProvider);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
    }
  }
}
