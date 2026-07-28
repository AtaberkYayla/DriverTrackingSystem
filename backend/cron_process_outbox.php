<?php
declare(strict_types=1);

// notification_outbox tablosuna kuyruklanan bildirimleri gonderir - Mail
// Ayarlari ekranindan (mail_settings.php, admin_web > Master Veri Yonetimi)
// girilen SMTP bilgileriyle, lib_mail.php'deki ham SMTP istemcisi uzerinden.
//
// Hestia > Cron Jobs panelinden dakikada bir calistirilmasi gerekir:
//   php /home/<kullanici>/web/<domain>/public_html/backend/cron_process_outbox.php

require_once __DIR__ . '/lib_db.php';
require_once __DIR__ . '/lib_mail.php';

$pdo = getDb();

$settings = getMailSettings($pdo);
if ($settings === null || empty($settings['smtp_host'])) {
    // Mail ayarlari henuz girilmemis - satirlar biriktirmeye devam eder, veri kaybolmaz.
    exit(0);
}

$pending = $pdo->query(
    'SELECT * FROM notification_outbox WHERE sent_at IS NULL AND attempt_count < 5
     ORDER BY created_at LIMIT 50'
)->fetchAll();

foreach ($pending as $row) {
    try {
        smtpSendMail($settings, $row['to_email'], $row['subject'], $row['body'], (bool) $row['is_html']);
        $pdo->prepare('UPDATE notification_outbox SET sent_at = NOW() WHERE id = ?')->execute([$row['id']]);
    } catch (SmtpException $e) {
        $pdo->prepare('UPDATE notification_outbox SET attempt_count = attempt_count + 1, last_error = ? WHERE id = ?')
            ->execute([$e->getMessage(), $row['id']]);
    }
}
