import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';

class MyProfileScreen extends ConsumerStatefulWidget {
  const MyProfileScreen({super.key});

  @override
  ConsumerState<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends ConsumerState<MyProfileScreen> {
  final _fullNameController = TextEditingController();
  final _notificationEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _emailBildirimAktif = true;
  bool _yuklendi = false;
  bool _kaydediliyor = false;
  String? _mesaj;

  @override
  void dispose() {
    _fullNameController.dispose();
    _notificationEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _formuDoldur(Profile profile) {
    if (_yuklendi) return;
    _fullNameController.text = profile.fullName;
    _notificationEmailController.text = profile.notificationEmail ?? '';
    _emailBildirimAktif = profile.emailBildirimAktif;
    _yuklendi = true;
  }

  Future<void> _kaydet() async {
    setState(() {
      _kaydediliyor = true;
      _mesaj = null;
    });
    try {
      final auth = ref.read(authRepositoryProvider);
      await auth.updateOwnProfile(
        fullName: _fullNameController.text.trim().isEmpty ? null : _fullNameController.text.trim(),
        notificationEmail: _notificationEmailController.text.trim().isEmpty
            ? null
            : _notificationEmailController.text.trim(),
        emailBildirimAktif: _emailBildirimAktif,
      );
      if (_passwordController.text.isNotEmpty) {
        await auth.updatePassword(_passwordController.text);
        _passwordController.clear();
      }
      ref.invalidate(currentProfileProvider);
      setState(() => _mesaj = 'Kaydedildi.');
    } catch (e) {
      setState(() => _mesaj = 'Hata: $e');
    } finally {
      if (mounted) setState(() => _kaydediliyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentProfileProvider);
    final isManagerOrAdmin = ref.watch(isManagerOrAdminProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profilim')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Profil yüklenemedi: $e')),
        data: (profile) {
          if (profile == null) return const Center(child: Text('Oturum bulunamadı.'));
          _formuDoldur(profile);
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        labelText: 'Ad Soyad',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notificationEmailController,
                      decoration: const InputDecoration(
                        labelText: 'Bildirim E-postası (gerçek e-postanız)',
                        helperText: 'Şoför işlemleriyle ilgili bildirimler bu adrese gelir.',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Yeni Şifre (opsiyonel)',
                        helperText: 'Şifrenizi değiştirmek için yeni şifreyi buraya yazın.',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    if (isManagerOrAdmin) ...[
                      const SizedBox(height: 16),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Yeni durak bildirimlerini e-posta ile al'),
                        value: _emailBildirimAktif,
                        onChanged: (v) => setState(() => _emailBildirimAktif = v),
                      ),
                    ],
                    if (_mesaj != null) ...[
                      const SizedBox(height: 12),
                      Text(_mesaj!),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _kaydediliyor ? null : _kaydet,
                      child: _kaydediliyor
                          ? const SizedBox(
                              width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Kaydet'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
