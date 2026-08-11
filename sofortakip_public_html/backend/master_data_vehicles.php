<?php
require_once __DIR__ . '/lib_bootstrap.php';

requireAuth($pdo);
$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $sadeceAktif = ($_GET['sadece_aktif'] ?? '1') === '1';
    $sql = 'SELECT * FROM vehicles';
    if ($sadeceAktif) {
        $sql .= ' WHERE aktif = 1';
    }
    $sql .= ' ORDER BY plaka';
    json_success(boolifyAll($pdo->query($sql)->fetchAll(), ['aktif']));
}

// Ekleme/silme sadece manager/admin - eski RLS'nin (vehicles_write policy) karsiligi.
requireRole($pdo, ['manager', 'admin']);

if ($method === 'POST') {
    $body = readJsonBody();
    $id = (string) ($body['id'] ?? '') ?: uuidv4();
    $plaka = (string) ($body['plaka'] ?? '');
    $aciklama = $body['aciklama'] ?? null;
    $aktif = (int) (bool) ($body['aktif'] ?? true);
    if ($plaka === '') {
        json_error('invalid_request', 'plaka zorunlu', 422);
    }

    $pdo->prepare(
        'INSERT INTO vehicles (id, plaka, aciklama, aktif) VALUES (?, ?, ?, ?)
         ON DUPLICATE KEY UPDATE plaka = VALUES(plaka), aciklama = VALUES(aciklama), aktif = VALUES(aktif)'
    )->execute([$id, $plaka, $aciklama, $aktif]);

    $select = $pdo->prepare('SELECT * FROM vehicles WHERE id = ?');
    $select->execute([$id]);
    json_success(boolify($select->fetch(), ['aktif']));
}

if ($method === 'DELETE') {
    $id = (string) ($_GET['id'] ?? '');
    if ($id === '') {
        json_error('invalid_request', 'id zorunlu', 422);
    }
    try {
        $pdo->prepare('DELETE FROM vehicles WHERE id = ?')->execute([$id]);
    } catch (PDOException $e) {
        if ((int) $e->errorInfo[1] === 1451) {
            json_error('fk_in_use', 'Bu kayıt kullanımda, önce pasife alın', 409);
        }
        throw $e;
    }
    json_success(['ok' => true]);
}

json_error('method_not_allowed', 'Desteklenmeyen metod', 405);
