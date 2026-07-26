import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../local/app_database.dart';
import '../../providers/app_providers.dart';

final _tripHistoryProvider = FutureProvider.autoDispose<List<TripsCacheData>>((ref) async {
  final profile = await ref.watch(currentProfileProvider.future);
  if (profile == null) return [];
  return ref.watch(localStoreProvider).gecmisSeferler(profile.id);
});

class TripHistoryScreen extends ConsumerWidget {
  const TripHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(_tripHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sefer Geçmişi')),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Sefer geçmişi yüklenemedi: $e')),
        data: (trips) {
          if (trips.isEmpty) {
            return const Center(child: Text('Henüz tamamlanmış sefer yok.'));
          }
          return ListView.separated(
            itemCount: trips.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) => _TripTile(trip: trips[index]),
          );
        },
      ),
    );
  }
}

class _TripTile extends ConsumerWidget {
  const _TripTile({required this.trip});

  final TripsCacheData trip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stopsAsync = ref.watch(stopsForTripProvider(trip.clientTripId));
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    return ExpansionTile(
      leading: Icon(
        trip.synced ? Icons.cloud_done_outlined : Icons.cloud_upload_outlined,
        color: trip.synced ? Colors.green : Colors.orange,
      ),
      title: Text(trip.tarih),
      subtitle: stopsAsync.when(
        loading: () => const Text('...'),
        error: (e, _) => Text('Hata: $e'),
        data: (stops) => Text('${stops.length} firma ziyareti'),
      ),
      children: [
        if (trip.fabrikaCikisAt != null)
          ListTile(
            dense: true,
            title: const Text('Fabrika Çıkış'),
            trailing: Text(dateFormat.format(trip.fabrikaCikisAt!)),
          ),
        stopsAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
          data: (stops) => Column(
            children: stops
                .map((s) => ListTile(
                      dense: true,
                      title: Text(s.gidilenSirketFree ?? '${s.sira}. durak'),
                      subtitle: Text(
                        'Giriş: ${dateFormat.format(s.firmaGirisAt)}'
                        '${s.firmaCikisAt != null ? " - Çıkış: ${dateFormat.format(s.firmaCikisAt!)}" : ""}',
                      ),
                    ))
                .toList(),
          ),
        ),
        if (trip.fabrikaGirisAt != null)
          ListTile(
            dense: true,
            title: const Text('Fabrika Giriş'),
            trailing: Text(dateFormat.format(trip.fabrikaGirisAt!)),
          ),
      ],
    );
  }
}
