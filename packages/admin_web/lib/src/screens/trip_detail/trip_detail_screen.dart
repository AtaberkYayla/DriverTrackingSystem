import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/app_providers.dart';

class TripDetailScreen extends ConsumerStatefulWidget {
  const TripDetailScreen({super.key, required this.stopWithTrip});

  final TripStopWithTrip stopWithTrip;

  @override
  ConsumerState<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends ConsumerState<TripDetailScreen> {
  late OnayDurumu _onayDurumu = widget.stopWithTrip.stop.onayDurumu;
  late SeferDurumu _seferDurumu = widget.stopWithTrip.stop.seferDurumu;
  late final _notlarController =
      TextEditingController(text: widget.stopWithTrip.stop.notlar);
  bool _kaydediliyor = false;

  @override
  void dispose() {
    _notlarController.dispose();
    super.dispose();
  }

  Future<void> _kaydet() async {
    final profile = await ref.read(currentProfileProvider.future);
    if (profile == null) return;
    setState(() => _kaydediliyor = true);
    try {
      await ref.read(tripRepositoryProvider).updateApproval(
            stopId: widget.stopWithTrip.stop.id,
            onayDurumu: _onayDurumu,
            onaylayanId: profile.id,
            seferDurumu: _seferDurumu,
            notlar: _notlarController.text.trim().isEmpty ? null : _notlarController.text.trim(),
          );
      ref.invalidate(tripListProvider);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _kaydediliyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.stopWithTrip.trip;
    final stop = widget.stopWithTrip.stop;
    final refDataAsync = ref.watch(referenceDataProvider);
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(title: Text('Sefer Detayi - ${trip.tarih}')),
      body: refDataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Referans veri yuklenemedi: $e')),
        data: (refData) {
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _bilgiSatiri('Sofor', refData.surucuAdi(trip.driverId)),
              _bilgiSatiri('Arac Plakasi', refData.aracPlakasi(trip.vehicleId)),
              _bilgiSatiri('Seyahat Turu', refData.seferTuruAdi(stop.tripTypeId)),
              _bilgiSatiri('Talep Eden Kisi', refData.talepEdenAdi(stop.requesterId)),
              _bilgiSatiri('Cikis Nedeni / Gorev', stop.cikisNedeni ?? '-'),
              _bilgiSatiri(
                'Gidilen Lokasyon',
                [stop.gidilenIl, stop.gidilenIlce].whereType<String>().join(' / '),
              ),
              _bilgiSatiri(
                'Gidilen Sirket',
                stop.gidilenSirketId != null
                    ? refData.sirketAdi(stop.gidilenSirketId)
                    : (stop.gidilenSirketFree ?? '-'),
              ),
              _bilgiSatiri('Irsaliye No', stop.irsaliyeNo ?? '-'),
              const Divider(height: 32),
              _bilgiSatiri(
                'Fabrika Cikis',
                trip.fabrikaCikisAt == null ? '-' : dateFormat.format(trip.fabrikaCikisAt!),
              ),
              _bilgiSatiri('Firma Giris', dateFormat.format(stop.firmaGirisAt)),
              _bilgiSatiri(
                'Firma Cikis',
                stop.firmaCikisAt == null ? '-' : dateFormat.format(stop.firmaCikisAt!),
              ),
              _bilgiSatiri(
                'Fabrika Giris (sefer kapanisi)',
                trip.fabrikaGirisAt == null ? '-' : dateFormat.format(trip.fabrikaGirisAt!),
              ),
              const Divider(height: 32),
              Text('Onay / Degerlendirme', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              DropdownButtonFormField<OnayDurumu>(
                initialValue: _onayDurumu,
                decoration: const InputDecoration(
                  labelText: 'Onay Durumu',
                  border: OutlineInputBorder(),
                ),
                items: OnayDurumu.values
                    .map((d) => DropdownMenuItem(
                          value: d,
                          child: Text(d == OnayDurumu.onaylandi ? 'Onaylandi' : 'Beklemede'),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _onayDurumu = v!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<SeferDurumu>(
                initialValue: _seferDurumu,
                decoration: const InputDecoration(
                  labelText: 'Sefer Durumu',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                      value: SeferDurumu.devamEdiyor, child: Text('Devam Ediyor')),
                  DropdownMenuItem(value: SeferDurumu.basarili, child: Text('Basarili')),
                  DropdownMenuItem(value: SeferDurumu.basarisiz, child: Text('Basarisiz')),
                ],
                onChanged: (v) => setState(() => _seferDurumu = v!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notlarController,
                decoration: const InputDecoration(
                  labelText: 'Notlar / Aciklamalar',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _kaydediliyor ? null : _kaydet,
                child: _kaydediliyor
                    ? const SizedBox(
                        width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Kaydet'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _bilgiSatiri(String label, String deger) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 200,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(deger)),
        ],
      ),
    );
  }
}
