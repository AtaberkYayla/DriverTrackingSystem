<?php
require_once __DIR__ . '/lib_bootstrap.php';

requireAuth($pdo);
$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $sadeceAktif = ($_GET['sadece_aktif'] ?? '1') === '1';
    $sql = 'SELECT * FROM companies';
    if ($sadeceAktif) {
        $sql .= ' WHERE aktif = 1';
    }
    $sql .= ' ORDER BY name';
    json_success(boolifyAll($pdo->query($sql)->fetchAll(), ['aktif']));
}

requireRole($pdo, ['manager', 'admin']);

if ($method === 'POST') {
    $body = readJsonBody();
    $id = (string) ($body['id'] ?? '') ?: uuidv4();
    $name = (string) ($body['name'] ?? '');
    $sehir = $body['sehir'] ?? null;
    $aktif = (int) (bool) ($body['aktif'] ?? true);
    if ($name === '') {
        json_error('invalid_request', 'name zorunlu', 422);
    }

    $pdo->prepare(
        'INSERT INTO companies (id, name, sehir, aktif) VALUES (?, ?, ?, ?)
         ON DUPLICATE KEY UPDATE name = VALUES(name), sehir = VALUES(sehir), aktif = VALUES(aktif)'
    )->execute([$id, $name, $sehir, $aktif]);

    $select = $pdo->prepare('SELECT * FROM companies WHERE id = ?');
    $select->execute([$id]);
    json_success(boolify($select->fetch(), ['aktif']));
}

if ($method === 'DELETE') {
    $id = (string) ($_GET['id'] ?? '');
    if ($id === '') {
        json_error('invalid_request', 'id zorunlu', 422);
    }
    try {
        $pdo->prepare('DELETE FROM companies WHERE id = ?')->execute([$id]);
    } catch (PDOException $e) {
        if ((int) $e->errorInfo[1] === 1451) {
            json_error('fk_in_use', 'Bu kayıt kullanımda, önce pasife alın', 409);
        }
        throw $e;
    }
    json_success(['ok' => true]);
}

json_error('method_not_allowed', 'Desteklenmeyen metod', 405);
