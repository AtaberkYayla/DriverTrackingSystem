import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'update_info.dart';

/// `version.json`'u kontrol edip, gerekirse APK'yi indirip Android'in
/// sistem kurulum ekranina acar (bkz. plan md, driver_app icin uygulama
/// ici otomatik guncelleme). Internet olmamasi/kontrolun basarisiz olmasi
/// hicbir zaman uygulamayi kilitlemez - [checkForUpdate] her hatada
/// (baglanti yok, 404, timeout, gecersiz JSON) sessizce null doner.
class UpdateService {
  const UpdateService();

  Future<UpdateInfo?> checkForUpdate({
    required String versionUrl,
    required int currentVersionCode,
  }) async {
    try {
      final response = await http.get(Uri.parse(versionUrl)).timeout(const Duration(seconds: 5));
      if (response.statusCode != 200) return null;
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final info = UpdateInfo.fromJson(json);
      return info.versionCode > currentVersionCode ? info : null;
    } catch (_) {
      return null;
    }
  }

  /// APK'yi indirip uygulamaya ozel harici depolama alanina yazar,
  /// `onProgress` ile 0.0-1.0 arasi ilerleme bildirir. Sunucu Content-Length
  /// gondermezse (total == 0) ilerleme bildirilmez, sadece indirme tamamlanir.
  Future<File> download(String apkUrl, {required void Function(double) onProgress}) async {
    final request = http.Request('GET', Uri.parse(apkUrl));
    final response = await http.Client().send(request);
    if (response.statusCode != 200) {
      throw Exception('APK indirilemedi (HTTP ${response.statusCode}).');
    }

    final dir = await getExternalStorageDirectory() ?? await getTemporaryDirectory();
    final file = File('${dir.path}/driver_app_update.apk');
    final sink = file.openWrite();
    final total = response.contentLength ?? 0;
    var received = 0;
    await response.stream.map((chunk) {
      received += chunk.length;
      if (total > 0) onProgress(received / total);
      return chunk;
    }).pipe(sink);
    await sink.close();
    return file;
  }

  /// "Bilinmeyen kaynaklardan yukleme" iznini (yoksa) sistem ayarlar
  /// ekranini acarak talep eder, sonra APK'yi kurulum ekranina acar.
  Future<void> install(File apk) async {
    final izin = await Permission.requestInstallPackages.status;
    if (!izin.isGranted) {
      final sonuc = await Permission.requestInstallPackages.request();
      if (!sonuc.isGranted) {
        throw Exception('Kurulum için "Bilinmeyen kaynaklardan yükleme" izni gerekli.');
      }
    }
    final result = await OpenFilex.open(apk.path);
    if (result.type != ResultType.done) {
      throw Exception(result.message.isNotEmpty ? result.message : 'Kurulum başlatılamadı.');
    }
  }
}
