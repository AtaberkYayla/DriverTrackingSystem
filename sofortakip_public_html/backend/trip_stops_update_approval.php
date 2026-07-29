<?php
require_once __DIR__ . '/lib_bootstrap.php';

// Panel uzerinden manuel onay - sadece yonetici/admin (Onay Verici hesabi
// yok, o taraf approvals_approve.php'deki tek-tikla mail linkiyle
// calisiyor). Bu endpoint SADECE onay alanlarini yazar, sofor tarafinin
// gonderdigi detay alanlarina hic dokunmaz.
$user = requireRole($pdo, ['manager', 'admin']);
$body = readJsonBody();

$stopId = (string) ($body['stop_id'] ?? '');
$onayDurumu = (string) ($body['onay_durumu'] ?? '');
$seferDurumu = (string) ($body['sefer_durumu'] ?? '');
$notlar = $body['notlar'] ?? null;

if ($stopId === '' || $onayDurumu === '' || $seferDurumu === '') {
    json_error('invalid_request', 'Eksik alanlar var', 422);
}

$fields = 'onay_durumu = ?, onaylayan_id = ?, onaylandi_at = NOW(), sefer_durumu = ?';
$params = [$onayDurumu, $user['id'], $seferDurumu];
if ($notlar !== null) {
    $fields .= ', notlar = ?';
    $params[] = $notlar;
}
$params[] = $stopId;

$pdo->prepare("UPDATE trip_stops SET $fields WHERE id = ?")->execute($params);

$select = $pdo->prepare('SELECT * FROM trip_stops WHERE id = ?');
$select->execute([$stopId]);
$row = $select->fetch();
if ($row === false) {
    json_error('not_found', 'Durak bulunamadı', 404);
}
json_success($row);
