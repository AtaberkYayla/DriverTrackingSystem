import 'dart:js_interop';
import 'dart:typed_data';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

String _createPdfObjectUrl(Uint8List bytes) {
  final blob = web.Blob(
    [bytes.toJS].toJS,
    web.BlobPropertyBag(type: 'application/pdf'),
  );
  return web.URL.createObjectURL(blob);
}

/// PDF onizlemesini `printing` paketinin pdf.js tabanli rasterizasyonuna
/// (web'de pdf.js'in yuklenmesi CDN erisimine, plugin registration'a ve
/// bir Worker'in basarili baslamasina bagli - bunlardan biri aksarsa
/// onizleme ya hata veriyor ya da sonsuza kadar "yukleniyor" ekraninda
/// kaliyordu) ihtiyac duymadan, tarayicinin kendi yerlesik PDF
/// goruntuleyicisiyle (iframe + blob URL) gosterir.
class NativePdfPreview extends StatefulWidget {
  const NativePdfPreview({super.key, required this.bytes});

  final Uint8List bytes;

  @override
  State<NativePdfPreview> createState() => _NativePdfPreviewState();
}

class _NativePdfPreviewState extends State<NativePdfPreview> {
  late final String _viewType =
      'native-pdf-preview-${identityHashCode(this)}';
  String? _objectUrl;

  @override
  void initState() {
    super.initState();
    final url = _createPdfObjectUrl(widget.bytes);
    _objectUrl = url;
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      return web.HTMLIFrameElement()
        ..src = url
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%';
    });
  }

  @override
  void dispose() {
    final url = _objectUrl;
    if (url != null) web.URL.revokeObjectURL(url);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewType);
  }
}
