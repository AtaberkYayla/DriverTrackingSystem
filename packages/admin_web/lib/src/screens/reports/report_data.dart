import 'package:core/core.dart';
import 'package:intl/intl.dart';

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

/// Rapor kriterlerinden (soför adi/plaka + tarih araligi), indirilen dosya
/// icin anlamli ve dosya sistemi icin guvenli bir isim uretir.
/// Ornek: "Sefer_Raporu_Oktay_Yakut_01.07.2026-30.07.2026.pdf"
String buildReportFileName(ReportCriteria criteria, {String extension = 'pdf'}) {
  final dateFmt = DateFormat('dd.MM.yyyy');
  final guvenliAd = criteria.secilenAd
      .trim()
      .replaceAll(RegExp(r'[<>:"/\\|?*]'), '')
      .replaceAll(RegExp(r'\s+'), '_');
  final tarihAraligi = '${dateFmt.format(criteria.baslangic)}-${dateFmt.format(criteria.bitis)}';
  return 'Sefer_Raporu_${guvenliAd}_$tarihAraligi.$extension';
}

class TripGroup {
  TripGroup(this.trip) : stops = [];
  final Trip trip;
  final List<TripStop> stops;
}

/// Bir sefer grubunun siralama icin kullanilacak en erken zaman damgasi:
/// once Fabrika Cikis, o yoksa en erken durak Girisi, o da yoksa Fabrika
/// Giris. Hicbiri yoksa (henuz hicbir olay islenmemis) null doner ve sadece
/// tarih alanina gore siralanir.
DateTime? tripGroupErkenZaman(TripGroup grup) {
  if (grup.trip.fabrikaCikisAt != null) return grup.trip.fabrikaCikisAt;
  if (grup.stops.isNotEmpty) {
    return grup.stops.map((s) => s.firmaGirisAt).reduce((a, b) => a.isBefore(b) ? a : b);
  }
  return grup.trip.fabrikaGirisAt;
}

List<TripGroup> groupTripStops(List<TripStopWithTrip> rows) {
  final gruplar = <String, TripGroup>{};
  final sira = <String>[];
  for (final row in rows) {
    final grup = gruplar.putIfAbsent(row.trip.id, () {
      sira.add(row.trip.id);
      return TripGroup(row.trip);
    });
    if (row.stop != null) grup.stops.add(row.stop!);
  }
  final liste = [for (final id in sira) gruplar[id]!];
  // Kaynak satirlar (fetchAllStopsWithTrip) genel sorguda en yeniden eskiye
  // siralandigi icin, ayni sefer icindeki duraklar da ters (son ziyaret
  // ilk) sirada geliyordu. Her grup icinde duraklari, sirasiyla girilme
  // sirasini tutan 'sira' alanina gore kronolojik hale getiriyoruz.
  for (final grup in liste) {
    grup.stops.sort((a, b) => a.sira.compareTo(b.sira));
  }
  // Canli ekrandan farkli olarak rapor kronolojik (eskiden yeniye) okunsun.
  // Ayni gundeki seferler arasinda da saatine gore (erkenden gece) siralanir.
  liste.sort((a, b) {
    final tarihFarki = a.trip.tarih.compareTo(b.trip.tarih);
    if (tarihFarki != 0) return tarihFarki;
    final zamanA = tripGroupErkenZaman(a);
    final zamanB = tripGroupErkenZaman(b);
    if (zamanA == null && zamanB == null) return 0;
    if (zamanA == null) return -1;
    if (zamanB == null) return 1;
    return zamanA.compareTo(zamanB);
  });
  return liste;
}
