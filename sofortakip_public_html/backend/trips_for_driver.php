<?php
require_once __DIR__ . '/lib_bootstrap.php';

$user = requireRole($pdo, ['driver']);
$limit = max(1, min(200, (int) ($_GET['limit'] ?? 50)));

$stmt = $pdo->prepare("SELECT * FROM trips WHERE driver_id = ? ORDER BY created_at DESC LIMIT $limit");
$stmt->execute([$user['id']]);
json_success($stmt->fetchAll());
