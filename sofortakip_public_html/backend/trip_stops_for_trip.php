<?php
require_once __DIR__ . '/lib_bootstrap.php';

requireAuth($pdo);
$tripId = (string) ($_GET['trip_id'] ?? '');
if ($tripId === '') {
    json_error('invalid_request', 'trip_id zorunlu', 422);
}

$stmt = $pdo->prepare('SELECT * FROM trip_stops WHERE trip_id = ? ORDER BY sira');
$stmt->execute([$tripId]);
json_success($stmt->fetchAll());
