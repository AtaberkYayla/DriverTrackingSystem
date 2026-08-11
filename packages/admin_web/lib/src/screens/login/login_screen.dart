import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';

/// Geniş ekranlarda marka panelinin gösterildiği eşik; altında sadece form
/// (küçük bir marka başlığıyla) gösterilir.
const _genisEkranEsigi = 900.0;

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _hata;

  @override
  void dispose() {
    _usernameController.dispose();
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
      await auth.signIn(
        username: _usernameController.text.trim(),
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
      setState(() => _hata = 'Giriş başarısız. Kullanıcı adı veya şifre hatalı.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final genisEkran = constraints.maxWidth >= _genisEkranEsigi;
          return Row(
            children: [
              if (genisEkran) const Expanded(flex: 5, child: _MarkaPaneli()),
              Expanded(
                flex: 4,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 380),
                      child: _girisFormu(context, genisEkran),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _girisFormu(BuildContext context, bool genisEkran) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!genisEkran) ...[
            Image.asset(DedemBrand.faviconAssetPath, package: 'core', height: 56),
            const SizedBox(height: 16),
            Text(
              'Dedem Mekatronik',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 32),
          ],
          Text(
            'Hoş geldiniz',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Yönetim paneline giriş yapın',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Kullanıcı Adı',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Kullanıcı adı giriniz' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: 'Şifre',
              prefixIcon: Icon(Icons.lock_outline),
            ),
            obscureText: true,
            onFieldSubmitted: (_) => _girisYap(),
            validator: (v) => (v == null || v.isEmpty) ? 'Şifre giriniz' : null,
          ),
          if (_hata != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _hata!,
                style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
              ),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _loading ? null : _girisYap,
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Giriş Yap'),
          ),
        ],
      ),
    );
  }
}

/// Geniş ekranlarda solda gösterilen marka paneli: kurumsal kimliği (kırmızı
/// zemin + logo + slogan) taşır, form panelinden ayrı tutularak giriş
/// ekranını "iç araç" değil ürün gibi hissettirir.
class _MarkaPaneli extends StatelessWidget {
  const _MarkaPaneli();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primary, Color.lerp(colorScheme.primary, Colors.black, 0.25)!],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -70,
            top: -70,
            child: _dekoratifDaire(220),
          ),
          Positioned(
            left: -50,
            bottom: -60,
            child: _dekoratifDaire(160),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Image.asset(
                      DedemBrand.logoPngAssetPath,
                      package: 'core',
                      height: 56,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Şoför Takip Sistemi',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 16),
                  ),
                  const SizedBox(height: 36),
                  Text(
                    'Filo, sefer ve onay süreçlerinizi\ntek panelden yönetin.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dekoratifDaire(double boyut) => Container(
        width: boyut,
        height: boyut,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.07)),
      );
}
