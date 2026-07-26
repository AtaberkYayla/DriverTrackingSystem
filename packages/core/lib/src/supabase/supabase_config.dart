import 'package:supabase_flutter/supabase_flutter.dart';

/// Uygulama baslangicinda bir kere cagrilir. `url` ve `publishableKey` degerleri
/// Supabase projesinin Settings > API sayfasindan alinir; --dart-define ile
/// (ör. `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_PUBLISHABLE_KEY=...`)
/// derleme zamaninda gecilmesi onerilir, kaynak koda gommeyin.
Future<void> initSupabase({
  required String url,
  required String publishableKey,
  LocalStorage? localStorage,
}) {
  return Supabase.initialize(
    url: url,
    publishableKey: publishableKey,
    authOptions: FlutterAuthClientOptions(localStorage: localStorage),
  );
}

SupabaseClient get supabase => Supabase.instance.client;
