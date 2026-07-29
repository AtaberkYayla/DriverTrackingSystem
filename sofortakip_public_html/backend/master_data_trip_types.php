<?php
require_once __DIR__ . '/lib_bootstrap.php';

requireAuth($pdo);
$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $sadeceAktif = ($_GET['sadece_aktif'] ?? '1') === '1';
    $sql = 'SELECT * FROM trip_types';
    if ($sadeceAktif) {
        $sql .= ' WHERE aktif = 1';
    }
    $sql .= ' ORDER BY sira';
    json_success(boolifyAll($pdo->query($sql)->fetchAll(), ['aktif', 'requires_irsaliye']));
}

requireRole($pdo, ['manager', 'admin']);

if ($method === 'POST') {
    $body = readJsonBody();
    $id = (string) ($body['id'] ?? '') ?: uuidv4();
    $code = (string) ($body['code'] ?? '');
    $label = (string) ($body['label'] ?? '');
    $requiresIrsaliye = (int) (bool) ($body['requires_irsaliye'] ?? false);
    $sira = (int) ($body['sira'] ?? 0);
    $aktif = (int) (bool) ($body['aktif'] ?? true);
    if ($code === '' || $label === '') {
        json_error('invalid_request', 'code ve label zorunlu', 422);
    }

    $pdo->prepare(
        'INSERT INTO trip_types (id, code, label, requires_irsaliye, sira, aktif) VALUES (?, ?, ?, ?, ?, ?)
         ON DUPLICATE KEY UPDATE code = VALUES(code), label = VALUES(label),
           requires_irsaliye = VALUES(requires_irsaliye), sira = VALUES(sira), aktif = VALUES(aktif)'
    )->execute([$id, $code, $label, $requiresIrsaliye, $sira, $aktif]);

    $select = $pdo->prepare('SELECT * FROM trip_types WHERE id = ?');
    $select->execute([$id]);
    json_success(boolify($select->fetch(), ['aktif', 'requires_irsaliye']));
}

if ($method === 'DELETE') {
    $id = (string) ($_GET['id'] ?? '');
    if ($id === '') {
        json_error('invalid_request', 'id zorunlu', 422);
    }
    try {
        $pdo->prepare('DELETE FROM trip_types WHERE id = ?')->execute([$id]);
    } catch (PDOException $e) {
        if ((int) $e->errorInfo[1] === 1451) {
            json_error('fk_in_use', 'Bu kayıt kullanımda, önce pasife alın', 409);
        }
        throw $e;
    }
    json_success(['ok' => true]);
}

json_error('method_not_allowed', 'Desteklenmeyen metod', 405);
