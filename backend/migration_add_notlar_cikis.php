<?php
declare(strict_types=1);

// Tek seferlik migration script'i: trip_stops tablosuna notlar_cikis
// sutununu ekler (schema.sql'deki CREATE TABLE IF NOT EXISTS var olan
// tabloyu degistirmedigi icin production'da elle calistirilmasi gerekiyor).
// Idempotent'tir (sutun zaten varsa hicbir sey yapmaz), ama GUVENLIK icin
// calistirdiktan sonra bu dosyayi Hestia Dosya Yoneticisi'nden SILIN.
//
// Kullanim: tarayicidan bir kez
//   https://<domain>/backend/migration_add_notlar_cikis.php?secret=<config.php'deki SEED_SECRET>
// ziyaret edin.

require_once __DIR__ . '/lib_db.php';

header('Content-Type: text/plain; charset=utf-8');

if (!defined('SEED_SECRET') || SEED_SECRET === '' || ($_GET['secret'] ?? '') !== SEED_SECRET) {
    http_response_code(403);
    echo "Yetkisiz. config.php icinde SEED_SECRET tanimlayip ?secret=... ile cagirin.\n";
    exit;
}

$pdo = getDb();

$existsStmt = $pdo->prepare(
    "SELECT COUNT(*) FROM information_schema.columns
     WHERE table_schema = DATABASE() AND table_name = 'trip_stops' AND column_name = 'notlar_cikis'"
);
$existsStmt->execute();
$exists = (int) $existsStmt->fetchColumn() > 0;

if ($exists) {
    echo "Zaten mevcut: trip_stops.notlar_cikis sutunu daha once eklenmis, bir sey yapilmadi.\n";
} else {
    $pdo->exec('ALTER TABLE trip_stops ADD COLUMN notlar_cikis TEXT NULL AFTER notlar');
    echo "Tamamlandi: trip_stops.notlar_cikis sutunu eklendi.\n";
}

echo "GUVENLIK: Bu dosyayi (migration_add_notlar_cikis.php) calistirdiktan sonra Hestia Dosya Yoneticisi'nden SILIN.\n";
