<?php
require_once __DIR__ . '/lib_bootstrap.php';

$user = requireRole($pdo, ['driver']);

$stmt = $pdo->prepare('SELECT * FROM trips WHERE driver_id = ? AND fabrika_giris_at IS NULL LIMIT 1');
$stmt->execute([$user['id']]);
json_success($stmt->fetch() ?: null);
