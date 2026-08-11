<?php
require_once __DIR__ . '/lib_bootstrap.php';

// Sofor kendi seferini yazar (driver_id token'daki kullaniciya sabitlenir).
// manager/admin/operator ise admin_web'den elle sefer olusturabilir - bu
// durumda driver_id body'den zorunlu alinir ve created_by_user_id ile kim
// olusturduysa isaretlenir (operator'un sadece kendi olusturdugunu
// duzenleyebilmesinin temeli, bkz. lib_auth.php requireTripOwnershipIfOperator).
$user = requireRole($pdo, ['driver', 'manager', 'admin', 'operator']);
$body = readJsonBody();

$clientTripId = (string) ($body['client_trip_id'] ?? '');
$vehicleId = (string) ($body['vehicle_id'] ?? '');
$tarih = (string) ($body['tarih'] ?? '');
$fabrikaCikisAt = $body['fabrika_cikis_at'] ?? null;
$fabrikaGirisAt = $body['fabrika_giris_at'] ?? null;

if ($user['role'] === 'driver') {
    $driverId = $user['id'];
    $createdByUserId = null;
} else {
    $driverId = (string) ($body['driver_id'] ?? '');
    if ($driverId === '') {
        json_error('invalid_request', 'driver_id zorunlu', 422);
    }
    $createdByUserId = $user['id'];
}

if ($clientTripId === '' || $vehicleId === '' || $tarih === '') {
    json_error('invalid_request', 'Eksik alanlar var', 422);
}

$existing = $pdo->prepare('SELECT id FROM trips WHERE client_trip_id = ?');
$existing->execute([$clientTripId]);
$row = $existing->fetch();
$id = $row['id'] ?? uuidv4();

if ($row !== false) {
    requireTripOwnershipIfOperator($pdo, $user, $id);
}

$pdo->prepare(
    'INSERT INTO trips (id, client_trip_id, driver_id, vehicle_id, tarih, fabrika_cikis_at, fabrika_giris_at, created_by_user_id)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?)
     ON DUPLICATE KEY UPDATE
       vehicle_id = VALUES(vehicle_id), tarih = VALUES(tarih),
       fabrika_cikis_at = VALUES(fabrika_cikis_at), fabrika_giris_at = VALUES(fabrika_giris_at)'
)->execute([$id, $clientTripId, $driverId, $vehicleId, $tarih, $fabrikaCikisAt, $fabrikaGirisAt, $createdByUserId]);

$select = $pdo->prepare('SELECT * FROM trips WHERE client_trip_id = ?');
$select->execute([$clientTripId]);
json_success($select->fetch());
