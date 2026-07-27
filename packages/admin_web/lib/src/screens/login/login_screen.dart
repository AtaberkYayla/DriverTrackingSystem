import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _hata;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _girisYap() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _hata = null;
    });
    try {
      final auth = ref.read(authRepositoryProvider);
      await auth.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      final profile = await auth.fetchCurrentProfile();
      if (profile == null || profile.role == AppRole.driver) {
        await auth.signOut();
        setState(() => _hata = 'Bu hesap yönetim paneli için yetkili değil.');
      } else if (!profile.aktif) {
        await auth.signOut();
        setState(() => _hata = 'Bu hesap devre dışı bırakılmış.');
      }
    } catch (e) {
      setState(() => _hata = 'Giriş başarısız. E-posta veya şifre hatalı.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    DedemBrand.faviconAssetPath,
                    package: 'core',
                    height: 72,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Dedem Mekatronik',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    'Şoför Takip - Yönetim Paneli',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'E-posta',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'E-posta giriniz' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Şifre',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    onFieldSubmitted: (_) => _girisYap(),
                    validator: (v) => (v == null || v.isEmpty) ? 'Şifre giriniz' : null,
                  ),
                  if (_hata != null) ...[
                    const SizedBox(height: 12),
                    Text(_hata!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _loading ? null : _girisYap,
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Giriş Yap'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
