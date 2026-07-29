<?php
require_once __DIR__ . '/lib_bootstrap.php';
require_once __DIR__ . '/lib_mail.php';

requireRole($pdo, ['admin']);

$body = readJsonBody();
$to = trim((string) ($body['to'] ?? ''));
if ($to === '' || !filter_var($to, FILTER_VALIDATE_EMAIL)) {
    json_error('invalid_request', 'Geçerli bir test e-postası giriniz', 422);
}

$settings = getMailSettings($pdo);
if ($settings === null) {
    json_error('invalid_request', 'Önce mail ayarlarını kaydedin', 422);
}

try {
    smtpSendMail(
        $settings,
        $to,
        'Şoför Takip Sistemi - Test E-postası',
        "Bu bir test e-postasıdır.\n\nMail ayarlarınız doğru çalışıyor.\n\nGönderim zamanı: " . date('d.m.Y H:i:s')
    );
} catch (SmtpException $e) {
    json_error('smtp_error', $e->getMessage(), 502);
}

json_success(['ok' => true]);
