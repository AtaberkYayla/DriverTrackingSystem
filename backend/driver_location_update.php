<?php
require_once __DIR__ . '/lib_bootstrap.php';

// Sofor uygulamasi acikken periyodik olarak kendi konumunu gonderir (bkz.
// driver_app LocationService). Sadece en son konum tutulur, gecmis yok.
$user = requireAuth($pdo);
$body = readJsonBody();

$lat = $body['lat'] ?? null;
$lng = $body['lng'] ?? null;
if (!is_numeric($lat) || !is_numeric($lng)) {
    json_error('invalid_request', 'lat ve lng zorunlu', 422);
}

$pdo->prepare(
    'INSERT INTO driver_locations (driver_id, lat, lng) VALUES (?, ?, ?)
     ON DUPLICATE KEY UPDATE lat = VALUES(lat), lng = VALUES(lng)'
)->execute([$user['id'], (float) $lat, (float) $lng]);

json_success(['ok' => true]);
