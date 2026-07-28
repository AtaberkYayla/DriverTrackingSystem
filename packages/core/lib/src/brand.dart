import 'package:flutter/widgets.dart';

/// Dedem Mekatronik marka sabitleri (renk + varlik yollari). Her iki uygulama
/// (admin_web, driver_app) da ayni gorsel kimligi kullansin diye burada
/// merkezilestirilmistir.
class DedemBrand {
  DedemBrand._();

  /// Logodaki/favicondaki kirmizi vurgu rengi.
  static const Color red = Color(0xFFE2111A);

  /// `core` paketinin assets/branding klasorunden yuklenirken kullanilacak
  /// yol (Flutter'in paket-ici asset konumu, `package: 'core'` ile birlikte).
  static const String faviconAssetPath = 'assets/branding/dedem-favicon.png';
  static const String logoAssetPath = 'assets/branding/dedem-logo.svg';

  /// Tam logonun (30. yil rozeti + "DEDEM MEKATRONIK" yaziligi) raster
  /// (PNG) hali - PDF gibi SVG gradyan/clip-path desteklemeyen ortamlarda
  /// (bkz. pdf paketinin SvgImage'i) kullanilmak icin dedem-logo.svg'den
  /// birebir (Chrome headless ile) uretildi.
  static const String logoPngAssetPath = 'assets/branding/dedem-logo.png';
}
