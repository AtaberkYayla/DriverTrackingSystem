<?php
require_once __DIR__ . '/lib_bootstrap.php';

// Yonetim paneli icin duz liste - eski Postgrest embedded-resource
// ('*, trip_stops(*)') sorgusunun yerini gercek bir SQL JOIN alir. Onay
// Verici (office) hesabi olmadigindan (bkz. backend/README.md) admin_web'e
// giren herkes (yonetici/admin/operator) tum seferleri gorur, talep-eden
// bazli kisitlama yok - operator'un duzenleme kisitlamasi (bkz.
// requireTripOwnershipIfOperator) sadece yazma islemlerinde uygulanir,
// goruntuleme/rapor icin serbesttir.
$user = requireRole($pdo, ['manager', 'admin', 'operator']);

$driverId = $_GET['driver_id'] ?? null;
$vehicleId = $_GET['vehicle_id'] ?? null;
$onayDurumu = $_GET['onay_durumu'] ?? null;
$seferDurumu = $_GET['sefer_durumu'] ?? null;
$baslangic = $_GET['baslangic'] ?? null;
$bitis = $_GET['bitis'] ?? null;
$limit = max(1, min(1000, (int) ($_GET['limit'] ?? 500)));

$where = [];
$params = [];

if ($driverId) {
    $where[] = 't.driver_id = ?';
    $params[] = $driverId;
}
if ($vehicleId) {
    $where[] = 't.vehicle_id = ?';
    $params[] = $vehicleId;
}
if ($baslangic) {
    $where[] = 't.tarih >= ?';
    $params[] = $baslangic;
}
if ($bitis) {
    $where[] = 't.tarih <= ?';
    $params[] = $bitis;
}

// Durak-bazli bir filtre (onay/sefer durumu) varsa durak zorunlu (INNER
// JOIN); aksi halde henuz hicbir firmaya ugramamis aktif seferler de
// gorunsun diye LEFT JOIN.
$stopJoin = 'LEFT JOIN trip_stops s ON s.trip_id = t.id';
if ($onayDurumu || $seferDurumu) {
    $stopJoin = 'INNER JOIN trip_stops s ON s.trip_id = t.id';
}
if ($onayDurumu) {
    $where[] = 's.onay_durumu = ?';
    $params[] = $onayDurumu;
}
if ($seferDurumu) {
    $where[] = 's.sefer_durumu = ?';
    $params[] = $seferDurumu;
}

$sql = "SELECT t.id, t.client_trip_id, t.driver_id, t.vehicle_id, t.tarih,
               t.fabrika_cikis_at, t.fabrika_giris_at, t.created_by_user_id,
               s.id AS stop_id, s.client_stop_id, s.sira, s.firma_giris_at, s.trip_type_id,
               s.requester_id, s.cikis_nedeni, s.gidilen_il, s.gidilen_ilce, s.gidilen_sirket_id,
               s.gidilen_sirket_free, s.irsaliye_no_giris, s.irsaliye_no_cikis, s.firma_cikis_at, s.onay_durumu, s.onaylayan_id,
               s.onaylandi_at, s.sefer_durumu, s.notlar, s.notlar_cikis
        FROM trips t $stopJoin";
if ($where) {
    $sql .= ' WHERE ' . implode(' AND ', $where);
}
$sql .= " ORDER BY t.created_at DESC LIMIT $limit";

$stmt = $pdo->prepare($sql);
$stmt->execute($params);
$rows = $stmt->fetchAll();

// Dart tarafinin bekledigi TripStopWithTrip sekli: {trip: {...}, stop: {...}|null}
$result = [];
foreach ($rows as $row) {
    $trip = [
        'id' => $row['id'],
        'client_trip_id' => $row['client_trip_id'],
        'driver_id' => $row['driver_id'],
        'vehicle_id' => $row['vehicle_id'],
        'tarih' => $row['tarih'],
        'fabrika_cikis_at' => $row['fabrika_cikis_at'],
        'fabrika_giris_at' => $row['fabrika_giris_at'],
        'created_by_user_id' => $row['created_by_user_id'],
    ];
    $stop = null;
    if ($row['stop_id'] !== null) {
        $stop = [
            'id' => $row['stop_id'],
            'client_stop_id' => $row['client_stop_id'],
            'trip_id' => $row['id'],
            'sira' => $row['sira'],
            'firma_giris_at' => $row['firma_giris_at'],
            'trip_type_id' => $row['trip_type_id'],
            'requester_id' => $row['requester_id'],
            'cikis_nedeni' => $row['cikis_nedeni'],
            'gidilen_il' => $row['gidilen_il'],
            'gidilen_ilce' => $row['gidilen_ilce'],
            'gidilen_sirket_id' => $row['gidilen_sirket_id'],
            'gidilen_sirket_free' => $row['gidilen_sirket_free'],
            'irsaliye_no_giris' => $row['irsaliye_no_giris'],
            'irsaliye_no_cikis' => $row['irsaliye_no_cikis'],
            'firma_cikis_at' => $row['firma_cikis_at'],
            'onay_durumu' => $row['onay_durumu'],
            'onaylayan_id' => $row['onaylayan_id'],
            'onaylandi_at' => $row['onaylandi_at'],
            'sefer_durumu' => $row['sefer_durumu'],
            'notlar' => $row['notlar'],
            'notlar_cikis' => $row['notlar_cikis'],
        ];
    }
    $result[] = ['trip' => $trip, 'stop' => $stop];
}

json_success($result);
