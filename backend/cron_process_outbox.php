<?php
declare(strict_types=1);

// notification_outbox tablosuna kuyruklanan bildirimleri gonderir.
//
// Dedem Mekatronik'in kendi mail otomasyon sistemi var (Gmail OAuth2
// entegrasyonu bu yuzden kaldirildi) - bu dosya, o sistemin API'siyle
// nasil konusulacagi netlesince doldurulacak bir iskelettir. Su an
// SADECE bekleyen satirlari okur, gonderim yapmaz; entegrasyon
// eklenene kadar notification_outbox satirlari 'sent_at IS NULL'
// olarak birikir (veriyi kaybetmez).
//
// Hestia > Cron Jobs panelinden dakikada bir calistirilmasi planlanan
// komut (entegrasyon eklendiginde aktif hale gelir):
//   php /home/<kullanici>/web/<domain>/public_html/backend/cron_process_outbox.php

require_once __DIR__ . '/lib_db.php';

$pdo = getDb();

$pending = $pdo->query(
    'SELECT * FROM notification_outbox WHERE sent_at IS NULL AND attempt_count < 5
     ORDER BY created_at LIMIT 50'
)->fetchAll();

if (empty($pending)) {
    exit(0);
}

foreach ($pending as $row) {
    // TODO: Dedem Mekatronik'in kendi mail otomasyon sistemine gonderim burada yapilacak.
    // Basarili gonderimde:
    //   $pdo->prepare('UPDATE notification_outbox SET sent_at = NOW() WHERE id = ?')->execute([$row['id']]);
    // Hatada:
    //   $pdo->prepare('UPDATE notification_outbox SET attempt_count = attempt_count + 1, last_error = ? WHERE id = ?')
    //       ->execute([$errorMessage, $row['id']]);
}
