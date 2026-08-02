/// `version.json`'dan (bkz. update_service.dart) okunan, mevcut kurulu
/// surumden daha yeni bir surum oldugunu tarifleyen model.
class UpdateInfo {
  const UpdateInfo({
    required this.versionCode,
    required this.versionName,
    required this.apkUrl,
    this.notes,
  });

  final int versionCode;
  final String versionName;
  final String apkUrl;
  final String? notes;

  factory UpdateInfo.fromJson(Map<String, dynamic> json) => UpdateInfo(
        versionCode: (json['versionCode'] as num).toInt(),
        versionName: json['versionName'] as String,
        apkUrl: json['apkUrl'] as String,
        notes: json['notes'] as String?,
      );
}
