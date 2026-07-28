<?php
require_once __DIR__ . '/lib_bootstrap.php';

// Filtre listesinde sofor adlarini gosterebilmek icin - herhangi bir giris
// yapmis kullanici (office/manager/admin) cagirabilir, tam hesap listesi
// (accounts_list.php) gibi manager/admin'e kisitli degil.
requireAuth($pdo);

$stmt = $pdo->query("SELECT id, full_name FROM users WHERE role = 'driver' AND aktif = 1 ORDER BY full_name");
json_success($stmt->fetchAll());
