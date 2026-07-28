<?php
require_once __DIR__ . '/lib_bootstrap.php';

requireAuth($pdo);
$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $sadeceAktif = ($_GET['sadece_aktif'] ?? '1') === '1';
    $sql = 'SELECT * FROM requesters';
    if ($sadeceAktif) {
        $sql .= ' WHERE aktif = 1';
    }
    $sql .= ' ORDER BY full_name';
    json_success(boolifyAll($pdo->query($sql)->fetchAll(), ['aktif']));
}

requireRole($pdo, ['manager', 'admin']);

if ($method === 'POST') {
    $body = readJsonBody();
    $id = (string) ($body['id'] ?? '') ?: uuidv4();
    $fullName = (string) ($body['full_name'] ?? '');
    $aktif = (int) (bool) ($body['aktif'] ?? true);
    $email = $body['email'] ?? null;
    if ($fullName === '') {
        json_error('invalid_request', 'full_name zorunlu', 422);
    }

    $pdo->prepare(
        'INSERT INTO requesters (id, full_name, aktif, email) VALUES (?, ?, ?, ?)
         ON DUPLICATE KEY UPDATE full_name = VALUES(full_name), aktif = VALUES(aktif), email = VALUES(email)'
    )->execute([$id, $fullName, $aktif, $email]);

    $select = $pdo->prepare('SELECT * FROM requesters WHERE id = ?');
    $select->execute([$id]);
    json_success(boolify($select->fetch(), ['aktif']));
}

if ($method === 'DELETE') {
    $id = (string) ($_GET['id'] ?? '');
    if ($id === '') {
        json_error('invalid_request', 'id zorunlu', 422);
    }
    try {
        $pdo->prepare('DELETE FROM requesters WHERE id = ?')->execute([$id]);
    } catch (PDOException $e) {
        if ((int) $e->errorInfo[1] === 1451) {
            json_error('fk_in_use', 'Bu kayıt kullanımda, önce pasife alın', 409);
        }
        throw $e;
    }
    json_success(['ok' => true]);
}

json_error('method_not_allowed', 'Desteklenmeyen metod', 405);
