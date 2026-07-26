import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';

/// Bekleyen (henuz sunucuya ulasmamis) sefer kaydi olup olmadigini gosteren
/// kucuk bir durum seridi. Soforun offline basislarinin kaybolmadigina
/// guvenmesi icin sürekli gorunur.
class SyncStatusBanner extends ConsumerWidget {
  const SyncStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingSyncCountProvider);

    return pendingAsync.when(
      data: (pending) {
        if (pending == 0) {
          return _bar(
            context,
            icon: Icons.cloud_done_outlined,
            text: 'Senkronize edildi',
            color: Colors.green,
          );
        }
        return _bar(
          context,
          icon: Icons.cloud_upload_outlined,
          text: 'Bekleyen $pending kayit senkronize edilecek',
          color: Colors.orange,
        );
      },
      loading: () => _bar(
        context,
        icon: Icons.cloud_sync_outlined,
        text: 'Kontrol ediliyor...',
        color: Colors.grey,
      ),
      error: (_, _) => _bar(
        context,
        icon: Icons.cloud_off_outlined,
        text: 'Baglanti yok',
        color: Colors.red,
      ),
    );
  }

  Widget _bar(
    BuildContext context, {
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      color: color.withValues(alpha: 0.12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }
}
