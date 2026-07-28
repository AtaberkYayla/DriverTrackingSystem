import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';

class MailSettingsScreen extends ConsumerStatefulWidget {
  const MailSettingsScreen({super.key});

  @override
  ConsumerState<MailSettingsScreen> createState() => _MailSettingsScreenState();
}

class _MailSettingsScreenState extends ConsumerState<MailSettingsScreen> {
  final _smtpHostController = TextEditingController();
  final _smtpPortController = TextEditingController();
  final _fromEmailController = TextEditingController();
  final _fromNameController = TextEditingController();
  final _smtpUserController = TextEditingController();
  final _smtpPasswordController = TextEditingController();
  final _testEmailController = TextEditingController();
  bool _useSsl = true;
  bool _yuklendi = false;
  bool _kaydediliyor = false;
  bool _testGonderiliyor = false;
  String? _kayitMesaji;
  String? _testMesaji;

  @override
  void dispose() {
    _smtpHostController.dispose();
    _smtpPortController.dispose();
    _fromEmailController.dispose();
    _fromNameController.dispose();
    _smtpUserController.dispose();
    _smtpPasswordController.dispose();
    _testEmailController.dispose();
    super.dispose();
  }

  void _formuDoldur(MailSettings settings) {
    if (_yuklendi) return;
    _smtpHostController.text = settings.smtpHost ?? '';
    _smtpPortController.text = settings.smtpPort?.toString() ?? '';
    _fromEmailController.text = settings.fromEmail ?? '';
    _fromNameController.text = settings.fromName ?? '';
    _smtpUserController.text = settings.smtpUser ?? '';
    _useSsl = settings.useSsl;
    _yuklendi = true;
  }

  Future<void> _kaydet() async {
    final port = int.tryParse(_smtpPortController.text.trim());
    if (_smtpHostController.text.trim().isEmpty || port == null || _fromEmailController.text.trim().isEmpty) {
      setState(() => _kayitMesaji = 'SMTP sunucu, port ve gönderen e-posta zorunludur.');
      return;
    }
    setState(() {
      _kaydediliyor = true;
      _kayitMesaji = null;
    });
    try {
      await ref.read(mailSettingsRepositoryProvider).save(
            smtpHost: _smtpHostController.text.trim(),
            smtpPort: port,
            useSsl: _useSsl,
            fromEmail: _fromEmailController.text.trim(),
            fromName: _fromNameController.text.trim().isEmpty ? null : _fromNameController.text.trim(),
            smtpUser: _smtpUserController.text.trim().isEmpty ? null : _smtpUserController.text.trim(),
            smtpPassword: _smtpPasswordController.text.isEmpty ? null : _smtpPasswordController.text,
          );
      _smtpPasswordController.clear();
      ref.invalidate(mailSettingsProvider);
      setState(() => _kayitMesaji = 'Kaydedildi.');
    } catch (e) {
      setState(() => _kayitMesaji = 'Hata: $e');
    } finally {
      if (mounted) setState(() => _kaydediliyor = false);
    }
  }

  Future<void> _testGonder() async {
    final to = _testEmailController.text.trim();
    if (to.isEmpty) {
      setState(() => _testMesaji = 'Test e-postası adresi giriniz.');
      return;
    }
    setState(() {
      _testGonderiliyor = true;
      _testMesaji = null;
    });
    try {
      await ref.read(mailSettingsRepositoryProvider).sendTest(to);
      setState(() => _testMesaji = 'Test e-postası gönderildi.');
    } catch (e) {
      setState(() => _testMesaji = 'Gönderilemedi: $e');
    } finally {
      if (mounted) setState(() => _testGonderiliyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(mailSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mail Ayarları')),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Mail ayarları yüklenemedi: $e')),
        data: (settings) {
          _formuDoldur(settings);
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SMTP Ayarları', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _smtpHostController,
                            decoration: const InputDecoration(
                              labelText: 'SMTP Sunucu',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _smtpPortController,
                            decoration: const InputDecoration(
                              labelText: 'SMTP Port',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('SSL Kullan'),
                      value: _useSsl,
                      onChanged: (v) => setState(() => _useSsl = v),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _fromEmailController,
                            decoration: const InputDecoration(
                              labelText: 'Gönderen E-posta',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _fromNameController,
                            decoration: const InputDecoration(
                              labelText: 'Gönderen Adı',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _smtpUserController,
                            decoration: const InputDecoration(
                              labelText: 'SMTP Kullanıcı',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _smtpPasswordController,
                            decoration: InputDecoration(
                              labelText: 'SMTP Şifre',
                              helperText: settings.hasPassword
                                  ? 'Boş bırakırsanız korunur.'
                                  : 'Henüz kayıtlı değil.',
                              border: const OutlineInputBorder(),
                            ),
                            obscureText: true,
                          ),
                        ),
                      ],
                    ),
                    if (_kayitMesaji != null) ...[
                      const SizedBox(height: 12),
                      Text(_kayitMesaji!),
                    ],
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FilledButton(
                        onPressed: _kaydediliyor ? null : _kaydet,
                        child: _kaydediliyor
                            ? const SizedBox(
                                width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Kaydet'),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text('Test E-postası', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _testEmailController,
                            decoration: const InputDecoration(
                              labelText: 'Test E-postası',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: OutlinedButton(
                              onPressed: _testGonderiliyor ? null : _testGonder,
                              child: _testGonderiliyor
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2))
                                  : const Text('Test Maili Gönder'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_testMesaji != null) ...[
                      const SizedBox(height: 12),
                      Text(_testMesaji!),
                    ],
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
