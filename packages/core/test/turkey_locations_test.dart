import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TurkeyLocations', () {
    test('Izmir ve Manisa icin ilce zorunlu, diger iller icin degil', () async {
      final turkey = await TurkeyLocations.load();

      expect(turkey.ilceZorunluMu('İzmir'), isTrue);
      expect(turkey.ilceZorunluMu('Manisa'), isTrue);
      expect(turkey.ilceZorunluMu('Ankara'), isFalse);
    });

    test('ilceAra sadece secilen ile ait ilceleri arar', () async {
      final turkey = await TurkeyLocations.load();

      final sonuc = turkey.ilceAra('İzmir', 'bor');

      expect(sonuc, contains('Bornova'));
      expect(sonuc, isNot(contains('Akhisar')));
    });

    test('ilAra bos sorguda tum illeri dondurur', () async {
      final turkey = await TurkeyLocations.load();

      expect(turkey.ilAra(''), hasLength(81));
    });
  });
}
