import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:intl/intl.dart';

import '../../providers/app_providers.dart';
import 'report_data.dart';
import 'xlsx_writer.dart';

/// Verilen kriterlere gore PDF raporuyla ayni veriden bir Excel (.xlsx)
/// dosyasi uretir: her durak bir satir olacak sekilde duzlestirilmis,
/// sefer bilgileri (tarih, sofor, plaka, fabrika giris/cikis) her satirda
/// tekrarlanmis bir tablo. Sefer bazinda gruplama/renklendirme PDF'e
/// ozgudur; Excel filtrelenebilir/siralanabilir duz tablo formatini
/// hedefler.
Uint8List buildTripReportExcel({
  required List<TripStopWithTrip> rows,
  required ReferenceData refData,
  required ReportCriteria criteria,
}) {
  final gruplar = groupTripStops(rows);
  final dateTimeFmt = DateFormat('dd.MM.yyyy HH:mm');
  final timeFmt = DateFormat('HH:mm');

  const headers = [
    'Tarih',
    'Şoför',
    'Araç Plakası',
    'Fabrika Çıkış',
    'Fabrika Giriş',
    'Gidilen Yer',
    'Sefer Türü',
    'Talep Eden',
    'Giriş',
    'Çıkış',
    'Onay Durumu',
  ];

  final sheetRows = <List<XlsxCell>>[
    [for (final h in headers) XlsxText(h, bold: true)],
  ];

  for (final grup in gruplar) {
    final soforAdi = refData.surucuAdi(grup.trip.driverId);
    final plaka = refData.aracPlakasi(grup.trip.vehicleId);
    final fabrikaCikis =
        grup.trip.fabrikaCikisAt == null ? '-' : dateTimeFmt.format(grup.trip.fabrikaCikisAt!);
    final fabrikaGiris =
        grup.trip.fabrikaGirisAt == null ? '-' : dateTimeFmt.format(grup.trip.fabrikaGirisAt!);

    if (grup.stops.isEmpty) {
      sheetRows.add([
        XlsxText(grup.trip.tarihGosterim),
        XlsxText(soforAdi),
        XlsxText(plaka),
        XlsxText(fabrikaCikis),
        XlsxText(fabrikaGiris),
        const XlsxText('Henüz bir firmaya uğramadı.'),
        const XlsxText('-'),
        const XlsxText('-'),
        const XlsxText('-'),
        const XlsxText('-'),
        const XlsxText('-'),
      ]);
      continue;
    }

    for (final stop in grup.stops) {
      final yer = [stop.gidilenIl, stop.gidilenIlce]
          .where((e) => e != null && e.isNotEmpty)
          .join(' / ');
      final firma = stop.gidilenSirketId != null
          ? refData.sirketAdi(stop.gidilenSirketId)
          : (stop.gidilenSirketFree ?? '');
      final gidilenYer = [if (yer.isNotEmpty) yer, if (firma.isNotEmpty) firma].join(' - ');
      final onaylandi = stop.onayDurumu == OnayDurumu.onaylandi;

      sheetRows.add([
        XlsxText(grup.trip.tarihGosterim),
        XlsxText(soforAdi),
        XlsxText(plaka),
        XlsxText(fabrikaCikis),
        XlsxText(fabrikaGiris),
        XlsxText(gidilenYer.isEmpty ? '-' : gidilenYer),
        XlsxText(refData.seferTuruAdi(stop.tripTypeId)),
        XlsxText(refData.talepEdenAdi(stop.requesterId)),
        XlsxText(timeFmt.format(stop.firmaGirisAt)),
        XlsxText(stop.firmaCikisAt == null ? '-' : timeFmt.format(stop.firmaCikisAt!)),
        XlsxText(onaylandi ? 'Onaylandı' : 'Bekliyor'),
      ]);
    }
  }

  return buildSimpleXlsx(rows: sheetRows, sheetName: 'Sefer Raporu');
}
