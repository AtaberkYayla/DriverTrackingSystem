<?php
require_once __DIR__ . '/lib_bootstrap.php';

// Eski kuralda oldugu gibi soforden gelen detaylari sadece manager/admin duzeltebilir.
$user = requireRole($pdo, ['manager', 'admin']);
$body = readJsonBody();

$id = (string) ($body['id'] ?? '');
if ($id === '') {
    json_error('invalid_request', 'id zorunlu', 422);
}

$editable = [
    'sira', 'firma_giris_at', 'trip_type_id', 'requester_id', 'cikis_nedeni', 'gidilen_il',
    'gidilen_ilce', 'gidilen_sirket_id', 'gidilen_sirket_free', 'irsaliye_no_giris', 'irsaliye_no_cikis',
    'firma_cikis_at',
];
$fields = [];
$params = [];
foreach ($editable as $col) {
    if (array_key_exists($col, $body)) {
        $fields[] = "$col = ?";
        $params[] = $body[$col];
    }
}
if (empty($fields)) {
    json_error('invalid_request', 'Güncellenecek alan yok', 422);
}
$params[] = $id;
$pdo->prepare('UPDATE trip_stops SET ' . implode(', ', $fields) . ' WHERE id = ?')->execute($params);

$select = $pdo->prepare('SELECT * FROM trip_stops WHERE id = ?');
$select->execute([$id]);
$row = $select->fetch();
if ($row === false) {
    json_error('not_found', 'Durak bulunamadı', 404);
}
json_success($row);
