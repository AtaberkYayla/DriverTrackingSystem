import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';
import '../../update/update_info.dart';

/// Zorunlu guncelleme ekrani: daha yeni bir surum bulundugunda uygulama
/// bunun yerine bu ekrani gosterir (bkz. main.dart _UpdateGate). Geri
/// tusu/atlama YOK - tum surucularin ayni surumde olmasini garanti eder.
class UpdateScreen extends ConsumerStatefulWidget {
  const UpdateScreen({super.key, required this.info});

  final UpdateInfo info;

  @override
  ConsumerState<UpdateScreen> createState() => _UpdateScreenState();
}

enum _Asama { bekliyor, indiriliyor, kuruluyor, hata }

class _UpdateScreenState extends ConsumerState<UpdateScreen> {
  _Asama _asama = _Asama.bekliyor;
  double _ilerleme = 0;
  String? _hata;

  Future<void> _guncelle() async {
    final service = ref.read(updateServiceProvider);
    setState(() {
      _asama = _Asama.indiriliyor;
      _ilerleme = 0;
      _hata = null;
    });
    try {
      final File apk = await service.download(
        widget.info.apkUrl,
        onProgress: (p) {
          if (mounted) setState(() => _ilerleme = p);
        },
      );
      if (!mounted) return;
      setState(() => _asama = _Asama.kuruluyor);
      await service.install(apk);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _asama = _Asama.hata;
        _hata = '$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(DedemBrand.faviconAssetPath, package: 'core', height: 72),
                  const SizedBox(height: 24),
                  Text(
                    'Yeni bir sürüm mevcut',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sürüm ${widget.info.versionName}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  if ((widget.info.notes ?? '').isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      widget.info.notes!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  const SizedBox(height: 32),
                  Text(
                    'Devam etmek için uygulamayı güncellemeniz gerekiyor.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 24),
                  ..._asamaWidgetlari(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _asamaWidgetlari(BuildContext context) {
    switch (_asama) {
      case _Asama.bekliyor:
        return [
          FilledButton(
            onPressed: _guncelle,
            child: const Text('Güncelle'),
          ),
        ];
      case _Asama.indiriliyor:
        return [
          LinearProgressIndicator(value: _ilerleme > 0 ? _ilerleme : null),
          const SizedBox(height: 8),
          Text(_ilerleme > 0 ? '%${(_ilerleme * 100).toStringAsFixed(0)} indirildi' : 'İndiriliyor...'),
        ];
      case _Asama.kuruluyor:
        return [
          const CircularProgressIndicator(),
          const SizedBox(height: 8),
          const Text('Kurulum ekranı açılıyor...'),
        ];
      case _Asama.hata:
        return [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _hata ?? 'Güncelleme başarısız oldu.',
              style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _guncelle,
            child: const Text('Tekrar Dene'),
          ),
        ];
    }
  }
}
