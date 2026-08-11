<?php
declare(strict_types=1);

// Tek seferlik migration script'i: users.role ENUM'una 'operator' rolunu ve
// trips tablosuna created_by_user_id sutununu ekler (schema.sql'deki
// CREATE TABLE IF NOT EXISTS var olan tabloyu degistirmedigi icin
// production'da elle calistirilmasi gerekiyor). Idempotent'tir (zaten
// eklenmisse hicbir sey yapmaz), ama GUVENLIK icin calistirdiktan sonra bu
// dosyayi Hestia Dosya Yoneticisi'nden SILIN.
//
// Kullanim: tarayicidan bir kez
//   https://<domain>/backend/migration_add_operator_role.php?secret=<config.php'deki SEED_SECRET>
// ziyaret edin.

require_once __DIR__ . '/lib_db.php';

header('Content-Type: text/plain; charset=utf-8');

if (!defined('SEED_SECRET') || SEED_SECRET === '' || ($_GET['secret'] ?? '') !== SEED_SECRET) {
    http_response_code(403);
    echo "Yetkisiz. config.php icinde SEED_SECRET tanimlayip ?secret=... ile cagirin.\n";
    exit;
}

$pdo = getDb();

// --- 1) users.role ENUM'una 'operator' ekle ---
$roleColStmt = $pdo->prepare(
    "SELECT COLUMN_TYPE FROM information_schema.columns
     WHERE table_schema = DATABASE() AND table_name = 'users' AND column_name = 'role'"
);
$roleColStmt->execute();
$roleColType = (string) $roleColStmt->fetchColumn();

if (str_contains($roleColType, "'operator'")) {
    echo "Zaten mevcut: users.role ENUM'unda 'operator' zaten var, bir sey yapilmadi.\n";
} else {
    $pdo->exec("ALTER TABLE users MODIFY role ENUM('driver','office','manager','admin','operator') NOT NULL");
    echo "Tamamlandi: users.role ENUM'una 'operator' eklendi.\n";
}

// --- 2) trips.created_by_user_id sutunu ---
$existsStmt = $pdo->prepare(
    "SELECT COUNT(*) FROM information_schema.columns
     WHERE table_schema = DATABASE() AND table_name = 'trips' AND column_name = 'created_by_user_id'"
);
$existsStmt->execute();
$exists = (int) $existsStmt->fetchColumn() > 0;

if ($exists) {
    echo "Zaten mevcut: trips.created_by_user_id sutunu daha once eklenmis, bir sey yapilmadi.\n";
} else {
    $pdo->exec(
        'ALTER TABLE trips
         ADD COLUMN created_by_user_id CHAR(36) NULL AFTER driver_id,
         ADD CONSTRAINT fk_trips_created_by FOREIGN KEY (created_by_user_id) REFERENCES users(id) ON DELETE SET NULL'
    );
    echo "Tamamlandi: trips.created_by_user_id sutunu eklendi.\n";
}

echo "GUVENLIK: Bu dosyayi (migration_add_operator_role.php) calistirdiktan sonra Hestia Dosya Yoneticisi'nden SILIN.\n";
