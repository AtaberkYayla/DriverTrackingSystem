import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/auth/secure_token_store.dart';
import 'src/providers/app_providers.dart';
import 'src/screens/login/login_screen.dart';
import 'src/screens/shell/main_shell.dart';
import 'src/theme/app_theme.dart';

const _apiBaseUrl = String.fromEnvironment('API_BASE_URL');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final baseUrl = _apiBaseUrl.isNotEmpty ? _apiBaseUrl : await _loadApiBaseUrl();
  await initApiClient(baseUrl: baseUrl, tokenStore: const SecureTokenStore());
  runApp(const ProviderScope(child: AdminWebApp()));
}

Future<String> _loadApiBaseUrl() async {
  try {
    final raw = await rootBundle.loadString('env/api.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return (decoded['API_BASE_URL'] as String?) ?? '';
  } catch (_) {
    return '';
  }
}

class AdminWebApp extends StatelessWidget {
  const AdminWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Şoför Takip - Yönetim Paneli',
      debugShowCheckedModeBanner: false,
      locale: const Locale('tr'),
      supportedLocales: const [Locale('tr')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light(),
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends ConsumerWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);
    return profileAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => const LoginScreen(),
      data: (profile) {
        if (profile == null || profile.role == AppRole.driver || !profile.aktif) {
          return const LoginScreen();
        }
        return const MainShell();
      },
    );
  }
}
