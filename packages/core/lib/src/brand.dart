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
}
