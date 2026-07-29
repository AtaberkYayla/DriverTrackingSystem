import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/app_providers.dart';
import 'native_pdf_preview.dart';
import 'trip_report_pdf.dart';

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  ReportMode _mod = ReportMode.sofor;
  String? _seciliDriverId;
  String? _seciliVehicleId;
  late DateTime _baslangic = DateTime(bugununTarihi().year, bugununTarihi().month, 1);
  DateTime _bitis = bugununTarihi();
  Future<Uint8List>? _pdfFuture;
  String? _hata;

  bool get _hazirMi => _mod == ReportMode.sofor ? _seciliDriverId != null : _seciliVehicleId != null;

  Future<void> _tarihSec() async {
    final secilen = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _baslangic, end: _bitis),
      firstDate: DateTime(2024),
      lastDate: bugununTarihi().add(const Duration(days: 1)),
      helpText: 'Rapor Tarih Aralığı',
      initialEntryMode: DatePickerEntryMode.input,
    );
    if (secilen == null) return;
    setState(() {
      _baslangic = secilen.start;
      _bitis = secilen.end;
      _pdfFuture = null;
    });
  }

  Future<void> _raporOlustur() async {
    setState(() => _hata = null);
    try {
      final refData = await ref.read(referenceDataProvider.future);
      final profile = await ref.read(currentProfileProvider.future);
      final rows = await ref.read(tripRepositoryProvider).fetchAllStopsWithTrip(
            driverId: _mod == ReportMode.sofor ? _seciliDriverId : null,
            vehicleId: _mod == ReportMode.plaka ? _seciliVehicleId : null,
            baslangic: _baslangic,
            bitis: _bitis,
            limit: 1000,
          );
      final secilenAd = _mod == ReportMode.sofor
          ? refData.surucuAdi(_seciliDriverId!)
          : refData.aracPlakasi(_seciliVehicleId!);

      setState(() {
        _pdfFuture = buildTripReportPdf(
          rows: rows,
          refData: refData,
          criteria: ReportCriteria(
            mode: _mod,
            secilenAd: secilenAd,
            baslangic: _baslangic,
            bitis: _bitis,
          ),
          olusturanAdi: profile?.fullName ?? '-',
        );
      });
    } catch (e) {
      setState(() => _hata = 'Rapor oluşturulamadı: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final driversAsync = ref.watch(allDriversProvider);
    final vehiclesAsync = ref.watch(vehiclesProvider);
    final dateFormat = DateFormat('dd.MM.yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Sefer Raporu')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SegmentedButton<ReportMode>(
                  segments: const [
                    ButtonSegment(
                      value: ReportMode.sofor,
                      label: Text('Şoför Bazlı'),
                      icon: Icon(Icons.person_outline),
                    ),
                    ButtonSegment(
                      value: ReportMode.plaka,
                      label: Text('Plaka Bazlı'),
                      icon: Icon(Icons.local_shipping_outlined),
                    ),
                  ],
                  selected: {_mod},
                  onSelectionChanged: (secim) => setState(() {
                    _mod = secim.first;
                    _pdfFuture = null;
                  }),
                ),
                if (_mod == ReportMode.sofor)
                  SizedBox(
                    width: 240,
                    child: driversAsync.when(
                      loading: () => const LinearProgressIndicator(),
                      error: (e, _) => Text('Şoförler yüklenemedi: $e'),
                      data: (drivers) => DropdownButtonFormField<String>(
                        initialValue: _seciliDriverId,
                        decoration: const InputDecoration(labelText: 'Şoför', border: OutlineInputBorder()),
                        items: drivers
                            .map((d) => DropdownMenuItem(value: d.id, child: Text(d.fullName)))
                            .toList(),
                        onChanged: (v) => setState(() {
                          _seciliDriverId = v;
                          _pdfFuture = null;
                        }),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    width: 240,
                    child: vehiclesAsync.when(
                      loading: () => const LinearProgressIndicator(),
                      error: (e, _) => Text('Araçlar yüklenemedi: $e'),
                      data: (vehicles) => DropdownButtonFormField<String>(
                        initialValue: _seciliVehicleId,
                        decoration:
                            const InputDecoration(labelText: 'Araç Plakası', border: OutlineInputBorder()),
                        items: vehicles
                            .map((v) => DropdownMenuItem(value: v.id, child: Text(v.plaka)))
                            .toList(),
                        onChanged: (v) => setState(() {
                          _seciliVehicleId = v;
                          _pdfFuture = null;
                        }),
                      ),
                    ),
                  ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today_outlined, size: 16),
                  label: Text('${dateFormat.format(_baslangic)} - ${dateFormat.format(_bitis)}'),
                  onPressed: _tarihSec,
                ),
                FilledButton.icon(
                  icon: const Icon(Icons.description_outlined),
                  label: const Text('Rapor Oluştur'),
                  onPressed: _hazirMi ? _raporOlustur : null,
                ),
              ],
            ),
          ),
          if (_hata != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(_hata!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          const Divider(height: 1),
          Expanded(
            child: _pdfFuture == null
                ? const Center(
                    child: Text('Kriterleri seçip "Rapor Oluştur"a basın.'),
                  )
                : FutureBuilder<Uint8List>(
                    future: _pdfFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Rapor oluşturulamadı: ${snapshot.error}'));
                      }
                      return NativePdfPreview(key: ValueKey(_pdfFuture), bytes: snapshot.data!);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
