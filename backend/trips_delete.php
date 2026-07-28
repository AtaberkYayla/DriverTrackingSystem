<?php
require_once __DIR__ . '/lib_bootstrap.php';

requireRole($pdo, ['manager', 'admin']);
$id = (string) ($_GET['id'] ?? '');
if ($id === '') {
    json_error('invalid_request', 'id zorunlu', 422);
}

// trip_stops FK'si ON DELETE CASCADE - eski Postgres davranisiyla ayni.
$pdo->prepare('DELETE FROM trips WHERE id = ?')->execute([$id]);
json_success(['ok' => true]);
