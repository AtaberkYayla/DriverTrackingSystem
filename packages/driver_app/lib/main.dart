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

const _apiBaseUrl = String.fromEnvironment('API_BASE_URL');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final baseUrl = _apiBaseUrl.isNotEmpty ? _apiBaseUrl : await _loadApiBaseUrl();
  await initApiClient(baseUrl: baseUrl, tokenStore: const SecureLocalStorage());
  runApp(const ProviderScope(child: SoforTakipApp()));
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
      data: (profile) => profile == null ? const LoginScreen() : const ActiveTripScreen(),
    );
  }
}
