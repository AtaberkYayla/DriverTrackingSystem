import '../api/api_client.dart';
import '../models/mail_settings.dart';

class MailSettingsRepository {
  Future<MailSettings> fetch() async {
    final data = await api.get('/mail_settings.php') as Map<String, dynamic>;
    return MailSettings.fromJson(data);
  }

  Future<void> save({
    required String smtpHost,
    required int smtpPort,
    required bool useSsl,
    required String fromEmail,
    String? fromName,
    String? smtpUser,
    String? smtpPassword,
  }) async {
    await api.post('/mail_settings.php', body: {
      'smtp_host': smtpHost,
      'smtp_port': smtpPort,
      'use_ssl': useSsl,
      'from_email': fromEmail,
      'from_name': fromName,
      'smtp_user': smtpUser,
      // Bos birakilirsa backend mevcut sifreyi korur (bkz. saveMailSettings).
      if (smtpPassword != null && smtpPassword.isNotEmpty) 'smtp_password': smtpPassword,
    });
  }

  Future<void> sendTest(String to) async {
    await api.post('/mail_test_send.php', body: {'to': to});
  }
}
