<?php
require_once __DIR__ . '/lib_bootstrap.php';

// operator sadece admin_web'den kendi olusturdugu (created_by_user_id) seferi
// duzenleyebilir; manager/admin icin kisitlama yok (mevcut genis yetki).
$user = requireRole($pdo, ['manager', 'admin', 'operator']);
$body = readJsonBody();
$id = (string) ($body['id'] ?? '');
if ($id === '') {
    json_error('invalid_request', 'id zorunlu', 422);
}
requireTripOwnershipIfOperator($pdo, $user, $id);

$fields = [];
$params = [];
foreach (['vehicle_id', 'tarih', 'fabrika_cikis_at', 'fabrika_giris_at'] as $col) {
    if (array_key_exists($col, $body)) {
        $fields[] = "$col = ?";
        $params[] = $body[$col];
    }
}
if (empty($fields)) {
    json_error('invalid_request', 'Güncellenecek alan yok', 422);
}
$params[] = $id;
$pdo->prepare('UPDATE trips SET ' . implode(', ', $fields) . ' WHERE id = ?')->execute($params);

$select = $pdo->prepare('SELECT * FROM trips WHERE id = ?');
$select->execute([$id]);
$row = $select->fetch();
if ($row === false) {
    json_error('not_found', 'Sefer bulunamadı', 404);
}
json_success($row);
