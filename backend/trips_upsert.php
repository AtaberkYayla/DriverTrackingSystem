<?php
require_once __DIR__ . '/lib_bootstrap.php';

// Sadece sofor kendi seferini yazabilir - driver_id her zaman token'daki
// kullaniciya sabitlenir, body'den gelen bir deger asla guvenilmez.
$user = requireRole($pdo, ['driver']);
$body = readJsonBody();

$clientTripId = (string) ($body['client_trip_id'] ?? '');
$vehicleId = (string) ($body['vehicle_id'] ?? '');
$tarih = (string) ($body['tarih'] ?? '');
$fabrikaCikisAt = $body['fabrika_cikis_at'] ?? null;
$fabrikaGirisAt = $body['fabrika_giris_at'] ?? null;

if ($clientTripId === '' || $vehicleId === '' || $tarih === '') {
    json_error('invalid_request', 'Eksik alanlar var', 422);
}

$existing = $pdo->prepare('SELECT id FROM trips WHERE client_trip_id = ?');
$existing->execute([$clientTripId]);
$row = $existing->fetch();
$id = $row['id'] ?? uuidv4();

$pdo->prepare(
    'INSERT INTO trips (id, client_trip_id, driver_id, vehicle_id, tarih, fabrika_cikis_at, fabrika_giris_at)
     VALUES (?, ?, ?, ?, ?, ?, ?)
     ON DUPLICATE KEY UPDATE
       vehicle_id = VALUES(vehicle_id), tarih = VALUES(tarih),
       fabrika_cikis_at = VALUES(fabrika_cikis_at), fabrika_giris_at = VALUES(fabrika_giris_at)'
)->execute([$id, $clientTripId, $user['id'], $vehicleId, $tarih, $fabrikaCikisAt, $fabrikaGirisAt]);

$select = $pdo->prepare('SELECT * FROM trips WHERE client_trip_id = ?');
$select->execute([$clientTripId]);
json_success($select->fetch());
