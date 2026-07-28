import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../providers/app_providers.dart';

/// Izmir - konumu bilinen hic sofor yokken haritanin acilacagi varsayilan merkez.
const _varsayilanMerkez = LatLng(38.4237, 27.1428);

/// FlutterMap (ve MapController) burada SADECE BIR KEZ kurulur ve bir daha
/// yeniden olusturulmaz; 6 saniyelik konum yenilemesi (autoRefreshTickProvider)
/// sadece asagidaki _CanliMarkerKatmani alt agacini gunceller. Aksi halde -
/// yani FlutterMap'i her tikte options ile yeniden olusturmak - soforun
/// devam eden zoom/pan hareketini kesiyor ve tarayicida donmaya yol aciyordu.
class LiveMapScreen extends StatefulWidget {
  const LiveMapScreen({super.key});

  @override
  State<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen> {
  final _mapController = MapController();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Canlı Konum Takibi')),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: const MapOptions(
                initialCenter: _varsayilanMerkez,
                initialZoom: 6,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.dedemmekatronik.driver_tracking_admin',
                ),
                _CanliMarkerKatmani(mapController: _mapController),
              ],
            ),
          ),
          const _KonumsuzSoforlerBar(),
        ],
      ),
    );
  }
}

class _CanliMarkerKatmani extends ConsumerStatefulWidget {
  const _CanliMarkerKatmani({required this.mapController});

  final MapController mapController;

  @override
  ConsumerState<_CanliMarkerKatmani> createState() => _CanliMarkerKatmaniState();
}

class _CanliMarkerKatmaniState extends ConsumerState<_CanliMarkerKatmani> {
  bool _ilkMerkezlemeYapildi = false;

  @override
  Widget build(BuildContext context) {
    final locations = ref.watch(driverLocationsProvider).value ?? const <DriverLocation>[];
    final konumluSoforler = locations.where((d) => d.lat != null && d.lng != null).toList();

    // Ilk konum verisi geldiginde haritayi bir kez ilk soforun konumuna
    // ortalar - sonraki her yenilemede degil (yoksa sofor haritada gezinirken
    // her 6 saniyede bir goruntu sifirlanirdi).
    if (!_ilkMerkezlemeYapildi && konumluSoforler.isNotEmpty) {
      _ilkMerkezlemeYapildi = true;
      final ilkKonum = konumluSoforler.first;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.mapController.move(LatLng(ilkKonum.lat!, ilkKonum.lng!), 12);
      });
    }

    return MarkerLayer(
      markers: konumluSoforler
          .map((d) => Marker(
                point: LatLng(d.lat!, d.lng!),
                width: 180,
                height: 78,
                alignment: Alignment.topCenter,
                child: _SoforIsareti(konum: d),
              ))
          .toList(),
    );
  }
}

class _KonumsuzSoforlerBar extends ConsumerWidget {
  const _KonumsuzSoforlerBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locations = ref.watch(driverLocationsProvider).value ?? const <DriverLocation>[];
    final konumsuzSoforler = locations.where((d) => d.lat == null).toList();
    if (konumsuzSoforler.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Text(
        'Henüz konum bilgisi alınamayan şoförler: '
        '${konumsuzSoforler.map((d) => d.fullName).join(', ')}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

class _SoforIsareti extends StatelessWidget {
  const _SoforIsareti({required this.konum});

  final DriverLocation konum;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                konum.fullName,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              if (konum.updatedAt != null)
                Text(
                  _gecenSure(konum.updatedAt!),
                  style: const TextStyle(fontSize: 9, color: Colors.black54),
                ),
            ],
          ),
        ),
        const Icon(Icons.location_on, color: Colors.red, size: 30),
      ],
    );
  }

  String _gecenSure(DateTime updatedAt) {
    final fark = DateTime.now().difference(updatedAt);
    if (fark.inSeconds < 60) return 'az önce';
    if (fark.inMinutes < 60) return '${fark.inMinutes} dk önce';
    return '${fark.inHours} sa önce';
  }
}
