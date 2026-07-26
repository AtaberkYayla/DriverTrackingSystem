import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/providers/app_providers.dart';
import 'src/screens/dashboard/trip_list_screen.dart';
import 'src/screens/login/login_screen.dart';

const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabasePublishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = await _loadSupabaseConfig();
  await initSupabase(
    url: config['SUPABASE_URL'] ?? _supabaseUrl,
    publishableKey: config['SUPABASE_PUBLISHABLE_KEY'] ?? _supabasePublishableKey,
  );
  runApp(const ProviderScope(child: AdminWebApp()));
}

Future<Map<String, String>> _loadSupabaseConfig() async {
  if (_supabaseUrl.isNotEmpty && _supabasePublishableKey.isNotEmpty) {
    return {
      'SUPABASE_URL': _supabaseUrl,
      'SUPABASE_PUBLISHABLE_KEY': _supabasePublishableKey,
    };
  }

  try {
    final raw = await rootBundle.loadString('env/supabase.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return {
      'SUPABASE_URL': (decoded['SUPABASE_URL'] as String?) ?? '',
      'SUPABASE_PUBLISHABLE_KEY': (decoded['SUPABASE_PUBLISHABLE_KEY'] as String?) ?? '',
    };
  } catch (_) {
    return {};
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
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends ConsumerWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    final oturumAcik = authState.maybeWhen(
      data: (state) => state.session != null,
      orElse: () => Supabase.instance.client.auth.currentSession != null,
    );

    if (!oturumAcik) return const LoginScreen();

    final profileAsync = ref.watch(currentProfileProvider);
    return profileAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => const LoginScreen(),
      data: (profile) {
        if (profile == null || profile.role == AppRole.driver || !profile.aktif) {
          return const LoginScreen();
        }
        return const TripListScreen();
      },
    );
  }
}
