<?php
require_once __DIR__ . '/lib_bootstrap.php';

// admin_web'deki canli harita ekrani icin - tum aktif soforleri, konumu
// bilinenler icin en son lat/lng/updated_at ile birlikte doner (henuz hic
// konum gondermemis soforlerde bu alanlar null gelir).
requireRole($pdo, ['manager', 'admin']);

$stmt = $pdo->query(
    "SELECT u.id AS driver_id, u.full_name, dl.lat, dl.lng, dl.updated_at
     FROM users u
     LEFT JOIN driver_locations dl ON dl.driver_id = u.id
     WHERE u.role = 'driver' AND u.aktif = 1
     ORDER BY u.full_name"
);
$rows = $stmt->fetchAll();
foreach ($rows as &$row) {
    if ($row['lat'] !== null) {
        $row['lat'] = (float) $row['lat'];
        $row['lng'] = (float) $row['lng'];
    }
}
unset($row);

json_success($rows);
