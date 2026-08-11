<?php
require_once __DIR__ . '/lib_bootstrap.php';

requireRole($pdo, ['manager', 'admin']);
$id = (string) ($_GET['id'] ?? '');
if ($id === '') {
    json_error('invalid_request', 'id zorunlu', 422);
}

$pdo->prepare('DELETE FROM trip_stops WHERE id = ?')->execute([$id]);
json_success(['ok' => true]);
