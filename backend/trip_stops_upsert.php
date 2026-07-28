<?php
require_once __DIR__ . '/lib_bootstrap.php';

$user = requireRole($pdo, ['driver']);
$body = readJsonBody();

$clientStopId = (string) ($body['client_stop_id'] ?? '');
$tripId = (string) ($body['trip_id'] ?? '');
if ($clientStopId === '' || $tripId === '') {
    json_error('invalid_request', 'Eksik alanlar var', 422);
}

$tripStmt = $pdo->prepare('SELECT * FROM trips WHERE id = ?');
$tripStmt->execute([$tripId]);
$trip = $tripStmt->fetch();
if ($trip === false || $trip['driver_id'] !== $user['id']) {
    json_error('forbidden', 'Bu sefere ait değilsiniz', 403);
}

$existingStmt = $pdo->prepare('SELECT * FROM trip_stops WHERE client_stop_id = ?');
$existingStmt->execute([$clientStopId]);
$existing = $existingStmt->fetch();
$id = $existing['id'] ?? uuidv4();
$wasOpen = $existing !== false && $existing['firma_cikis_at'] === null;

$sira = (int) ($body['sira'] ?? 0);
$firmaGirisAt = $body['firma_giris_at'] ?? null;
$tripTypeId = $body['trip_type_id'] ?? null;
$requesterId = $body['requester_id'] ?? null;
$cikisNedeni = $body['cikis_nedeni'] ?? null;
$gidilenIl = $body['gidilen_il'] ?? null;
$gidilenIlce = $body['gidilen_ilce'] ?? null;
$gidilenSirketId = $body['gidilen_sirket_id'] ?? null;
$gidilenSirketFree = $body['gidilen_sirket_free'] ?? null;
$irsaliyeNoGiris = $body['irsaliye_no_giris'] ?? null;
$irsaliyeNoCikis = $body['irsaliye_no_cikis'] ?? null;
$firmaCikisAt = $body['firma_cikis_at'] ?? null;

$pdo->prepare(
    'INSERT INTO trip_stops (id, client_stop_id, trip_id, sira, firma_giris_at, trip_type_id, requester_id,
        cikis_nedeni, gidilen_il, gidilen_ilce, gidilen_sirket_id, gidilen_sirket_free, irsaliye_no_giris,
        irsaliye_no_cikis, firma_cikis_at)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
     ON DUPLICATE KEY UPDATE
       sira = VALUES(sira), firma_giris_at = VALUES(firma_giris_at), trip_type_id = VALUES(trip_type_id),
       requester_id = VALUES(requester_id), cikis_nedeni = VALUES(cikis_nedeni), gidilen_il = VALUES(gidilen_il),
       gidilen_ilce = VALUES(gidilen_ilce), gidilen_sirket_id = VALUES(gidilen_sirket_id),
       gidilen_sirket_free = VALUES(gidilen_sirket_free), irsaliye_no_giris = VALUES(irsaliye_no_giris),
       irsaliye_no_cikis = VALUES(irsaliye_no_cikis), firma_cikis_at = VALUES(firma_cikis_at)'
)->execute([
    $id, $clientStopId, $tripId, $sira, $firmaGirisAt, $tripTypeId, $requesterId, $cikisNedeni,
    $gidilenIl, $gidilenIlce, $gidilenSirketId, $gidilenSirketFree, $irsaliyeNoGiris, $irsaliyeNoCikis,
    $firmaCikisAt,
]);

$select = $pdo->prepare('SELECT * FROM trip_stops WHERE id = ?');
$select->execute([$id]);
$stop = $select->fetch();

// Bildirim kuyrugu: yeni durak (firma girisi) ya da firma_cikis_at'in
// null'dan dolu hale gecisi (firma cikisi) - ag cagrisi YOK, sadece hizli INSERT.
$isNewStop = $existing === false;
$isExitTransition = $wasOpen && $stop['firma_cikis_at'] !== null;
if ($isNewStop || $isExitTransition) {
    queueTripStopNotification($pdo, $trip, $stop, $isNewStop ? 'Firma Girişi' : 'Firma Çıkışı');
}

json_success($stop);
