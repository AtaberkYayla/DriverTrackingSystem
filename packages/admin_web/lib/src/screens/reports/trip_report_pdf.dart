import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../providers/app_providers.dart';

enum ReportMode { sofor, plaka }

class ReportCriteria {
  const ReportCriteria({
    required this.mode,
    required this.secilenAd,
    required this.baslangic,
    required this.bitis,
  });

  final ReportMode mode;
  final String secilenAd;
  final DateTime baslangic;
  final DateTime bitis;
}

class _TripGroup {
  _TripGroup(this.trip) : stops = [];
  final Trip trip;
  final List<TripStop> stops;
}

/// Bir sefer grubunun siralama icin kullanilacak en erken zaman damgasi:
/// once Fabrika Cikis, o yoksa en erken durak Girisi, o da yoksa Fabrika
/// Giris. Hicbiri yoksa (henuz hicbir olay islenmemis) null doner ve sadece
/// tarih alanina gore siralanir.
DateTime? _erkenZaman(_TripGroup grup) {
  if (grup.trip.fabrikaCikisAt != null) return grup.trip.fabrikaCikisAt;
  if (grup.stops.isNotEmpty) {
    return grup.stops.map((s) => s.firmaGirisAt).reduce((a, b) => a.isBefore(b) ? a : b);
  }
  return grup.trip.fabrikaGirisAt;
}

List<_TripGroup> _grupla(List<TripStopWithTrip> rows) {
  final gruplar = <String, _TripGroup>{};
  final sira = <String>[];
  for (final row in rows) {
    final grup = gruplar.putIfAbsent(row.trip.id, () {
      sira.add(row.trip.id);
      return _TripGroup(row.trip);
    });
    if (row.stop != null) grup.stops.add(row.stop!);
  }
  final liste = [for (final id in sira) gruplar[id]!];
  // Canli ekrandan farkli olarak rapor kronolojik (eskiden yeniye) okunsun.
  // Ayni gundeki seferler arasinda da saatine gore (erkenden gece) siralanir.
  liste.sort((a, b) {
    final tarihFarki = a.trip.tarih.compareTo(b.trip.tarih);
    if (tarihFarki != 0) return tarihFarki;
    final zamanA = _erkenZaman(a);
    final zamanB = _erkenZaman(b);
    if (zamanA == null && zamanB == null) return 0;
    if (zamanA == null) return -1;
    if (zamanB == null) return 1;
    return zamanA.compareTo(zamanB);
  });
  return liste;
}

const _bordo = PdfColor.fromInt(0xFF7A1F2E);

/// Verilen kriterlere gore "resmi" bir sefer raporu PDF'i uretir: logo +
/// olusturulma bilgisi basligi, ozet istatistik seridi, sefer bazinda
/// gruplanmis durak tablosu ve her sayfada sayfa numarasi.
Future<Uint8List> buildTripReportPdf({
  required List<TripStopWithTrip> rows,
  required ReferenceData refData,
  required ReportCriteria criteria,
  required String olusturanAdi,
}) async {
  final regularBytes = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
  final boldBytes = await rootBundle.load('assets/fonts/Roboto-Bold.ttf');
  final regular = pw.Font.ttf(regularBytes);
  final bold = pw.Font.ttf(boldBytes);
  final logoBytes =
      (await rootBundle.load('packages/core/${DedemBrand.logoPngAssetPath}')).buffer.asUint8List();
  final logoImage = pw.MemoryImage(logoBytes);

  final gruplar = _grupla(rows);
  final dateFmt = DateFormat('dd.MM.yyyy');
  final dateTimeFmt = DateFormat('dd.MM.yyyy HH:mm');
  final timeFmt = DateFormat('HH:mm');

  final toplamSefer = gruplar.length;
  final toplamDurak = gruplar.fold<int>(0, (s, g) => s + g.stops.length);
  final onaylanan =
      gruplar.fold<int>(0, (s, g) => s + g.stops.where((x) => x.onayDurumu == OnayDurumu.onaylandi).length);
  final bekleyen = toplamDurak - onaylanan;

  final baslikEtiketi = criteria.mode == ReportMode.sofor ? 'Şoför' : 'Araç Plakası';

  pw.Widget istatistik(String etiket, String deger) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(deger, style: const pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 2),
          pw.Text(etiket, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
        ],
      );

  pw.Widget th(String text, {pw.TextAlign align = pw.TextAlign.left}) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        child: pw.Text(text,
            textAlign: align,
            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
      );

  pw.Widget td(String text, {pw.TextAlign align = pw.TextAlign.left, PdfColor? color}) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        child: pw.Text(text, textAlign: align, style: pw.TextStyle(fontSize: 8.5, color: color)),
      );

  pw.TableRow stopRow(TripStop stop) {
    final yer = [stop.gidilenIl, stop.gidilenIlce]
        .where((e) => e != null && e.isNotEmpty)
        .join(' / ');
    final firma = stop.gidilenSirketId != null
        ? refData.sirketAdi(stop.gidilenSirketId)
        : (stop.gidilenSirketFree ?? '');
    final gidilenYer = [if (yer.isNotEmpty) yer, if (firma.isNotEmpty) firma].join(' - ');
    final onaylandi = stop.onayDurumu == OnayDurumu.onaylandi;
    return pw.TableRow(
      children: [
        td(gidilenYer.isEmpty ? '-' : gidilenYer),
        td(refData.seferTuruAdi(stop.tripTypeId)),
        td(refData.talepEdenAdi(stop.requesterId)),
        td(timeFmt.format(stop.firmaGirisAt)),
        td(stop.firmaCikisAt == null ? '-' : timeFmt.format(stop.firmaCikisAt!)),
        td(
          onaylandi ? 'Onaylandı' : 'Bekliyor',
          color: onaylandi ? PdfColors.green700 : PdfColors.orange800,
        ),
      ],
    );
  }

  pw.Widget tripCard(_TripGroup grup) {
    final ikincilEtiket = criteria.mode == ReportMode.sofor
        ? refData.aracPlakasi(grup.trip.vehicleId)
        : refData.surucuAdi(grup.trip.driverId);
    final fabrika = [
      if (grup.trip.fabrikaCikisAt != null) 'Fabrika Çıkış: ${dateTimeFmt.format(grup.trip.fabrikaCikisAt!)}',
      if (grup.trip.fabrikaGirisAt != null) 'Fabrika Giriş: ${dateTimeFmt.format(grup.trip.fabrikaGirisAt!)}',
    ].join('   ·   ');

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300, width: 0.7),
        borderRadius: pw.BorderRadius.circular(3),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: const pw.BoxDecoration(color: PdfColors.grey100),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('${grup.trip.tarih}   ·   $ikincilEtiket',
                    style: const pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                if (fabrika.isNotEmpty)
                  pw.Text(fabrika, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
              ],
            ),
          ),
          if (grup.stops.isEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.all(10),
              child: pw.Text('Henüz bir firmaya uğramadı.',
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
            )
          else
            pw.Table(
              columnWidths: const {
                0: pw.FlexColumnWidth(2.6),
                1: pw.FlexColumnWidth(1.6),
                2: pw.FlexColumnWidth(1.8),
                3: pw.FlexColumnWidth(0.9),
                4: pw.FlexColumnWidth(0.9),
                5: pw.FlexColumnWidth(1.1),
              },
              border: const pw.TableBorder(
                horizontalInside: pw.BorderSide(color: PdfColors.grey200, width: 0.5),
              ),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey400)),
                  ),
                  children: [
                    th('Gidilen Yer'),
                    th('Sefer Türü'),
                    th('Talep Eden'),
                    th('Giriş'),
                    th('Çıkış'),
                    th('Onay'),
                  ],
                ),
                for (final stop in grup.stops) stopRow(stop),
              ],
            ),
        ],
      ),
    );
  }

  final doc = pw.Document(
    theme: pw.ThemeData.withFont(base: regular, bold: bold),
  );

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(32, 28, 32, 28),
      header: (context) {
        if (context.pageNumber == 1) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Image(logoImage, height: 34),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Oluşturulma Tarihi: ${dateTimeFmt.format(DateTime.now())}',
                          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                      pw.SizedBox(height: 2),
                      pw.Text('Oluşturan: $olusturanAdi',
                          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 18),
              pw.Text('Sefer Raporu',
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: _bordo)),
              pw.SizedBox(height: 4),
              pw.Text(
                '$baslikEtiketi: ${criteria.secilenAd}   ·   Tarih Aralığı: '
                '${dateFmt.format(criteria.baslangic)} - ${dateFmt.format(criteria.bitis)}',
                style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey800),
              ),
              pw.SizedBox(height: 14),
              pw.Row(
                children: [
                  istatistik('Toplam Sefer', '$toplamSefer'),
                  pw.SizedBox(width: 28),
                  istatistik('Toplam Durak', '$toplamDurak'),
                  pw.SizedBox(width: 28),
                  istatistik('Onaylanan', '$onaylanan'),
                  pw.SizedBox(width: 28),
                  istatistik('Bekleyen', '$bekleyen'),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Divider(color: PdfColors.grey400, thickness: 0.7),
              pw.SizedBox(height: 8),
            ],
          );
        }
        return pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Row(
              children: [
                pw.Image(logoImage, height: 16),
                pw.SizedBox(width: 8),
                pw.Text('Sefer Raporu',
                    style: const pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
              ],
            ),
            pw.Text('$baslikEtiketi: ${criteria.secilenAd}',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
          ],
        );
      },
      footer: (context) => pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Divider(color: PdfColors.grey300, thickness: 0.7),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Dedem Mekatronik · Şoför Takip Sistemi',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
              pw.Text('Sayfa ${context.pageNumber} / ${context.pagesCount}',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
            ],
          ),
        ],
      ),
      build: (context) {
        if (gruplar.isEmpty) {
          return [
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 40),
              child: pw.Center(
                child: pw.Text('Seçilen aralıkta sefer bulunamadı.',
                    style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
              ),
            ),
          ];
        }
        return [for (final grup in gruplar) tripCard(grup)];
      },
    ),
  );

  return doc.save();
}
