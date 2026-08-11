import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/auth/secure_local_storage.dart';
import 'src/providers/app_providers.dart';
import 'src/screens/home/active_trip_screen.dart';
import 'src/screens/login/login_screen.dart';
import 'src/screens/update/update_screen.dart';

const _apiBaseUrl = String.fromEnvironment('API_BASE_URL');
const _apkVersionUrl = String.fromEnvironment('APK_VERSION_URL');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final env = await _loadEnv();
  final baseUrl = _apiBaseUrl.isNotEmpty ? _apiBaseUrl : (env['API_BASE_URL'] ?? '');
  final apkVersionUrl = _apkVersionUrl.isNotEmpty ? _apkVersionUrl : (env['APK_VERSION_URL'] ?? '');
  await initApiClient(baseUrl: baseUrl, tokenStore: const SecureLocalStorage());
  runApp(ProviderScope(
    overrides: [apkVersionUrlProvider.overrideWithValue(apkVersionUrl)],
    child: const SoforTakipApp(),
  ));
}

Future<Map<String, String>> _loadEnv() async {
  try {
    final raw = await rootBundle.loadString('env/api.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(key, value as String? ?? ''));
  } catch (_) {
    return {};
  }
}

class SoforTakipApp extends StatelessWidget {
  const SoforTakipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Şoför Takip Sistemi',
      debugShowCheckedModeBanner: false,
      locale: const Locale('tr'),
      supportedLocales: const [Locale('tr')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(colorSchemeSeed: DedemBrand.red, useMaterial3: true),
      home: const _UpdateGate(),
    );
  }
}

/// Uygulama her acilista once daha yeni bir surum olup olmadigini kontrol
/// eder (bkz. updateCheckProvider) - varsa zorunlu UpdateScreen'i gosterir,
/// yoksa (ya da kontrol basarisiz olduysa) normal giris akisina devam eder.
class _UpdateGate extends ConsumerWidget {
  const _UpdateGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateAsync = ref.watch(updateCheckProvider);
    return updateAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => const _AuthGate(),
      data: (info) => info == null ? const _AuthGate() : UpdateScreen(info: info),
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
      data: (profile) => profile == null ? const LoginScreen() : const ActiveTripScreen(),
    );
  }
}
