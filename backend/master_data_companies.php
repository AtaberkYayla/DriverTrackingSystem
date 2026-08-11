<?php
require_once __DIR__ . '/lib_bootstrap.php';

requireAuth($pdo);
$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $sadeceAktif = ($_GET['sadece_aktif'] ?? '1') === '1';
    $sql = 'SELECT c.*, GROUP_CONCAT(ctt.trip_type_id) AS trip_type_ids_concat
            FROM companies c
            LEFT JOIN company_trip_types ctt ON ctt.company_id = c.id';
    if ($sadeceAktif) {
        $sql .= ' WHERE c.aktif = 1';
    }
    $sql .= ' GROUP BY c.id ORDER BY c.name';
    $rows = $pdo->query($sql)->fetchAll();
    foreach ($rows as &$row) {
        $concat = $row['trip_type_ids_concat'];
        unset($row['trip_type_ids_concat']);
        $row['trip_type_ids'] = $concat === null ? [] : explode(',', $concat);
    }
    unset($row);
    json_success(boolifyAll($rows, ['aktif']));
}

requireRole($pdo, ['manager', 'admin']);

if ($method === 'POST') {
    $body = readJsonBody();
    $id = (string) ($body['id'] ?? '') ?: uuidv4();
    $name = (string) ($body['name'] ?? '');
    $sehir = $body['sehir'] ?? null;
    $tripTypeIds = array_values(array_unique((array) ($body['trip_type_ids'] ?? [])));
    $aktif = (int) (bool) ($body['aktif'] ?? true);
    if ($name === '') {
        json_error('invalid_request', 'name zorunlu', 422);
    }

    $pdo->beginTransaction();

    $pdo->prepare(
        'INSERT INTO companies (id, name, sehir, aktif) VALUES (?, ?, ?, ?)
         ON DUPLICATE KEY UPDATE name = VALUES(name), sehir = VALUES(sehir), aktif = VALUES(aktif)'
    )->execute([$id, $name, $sehir, $aktif]);

    $pdo->prepare('DELETE FROM company_trip_types WHERE company_id = ?')->execute([$id]);
    if ($tripTypeIds !== []) {
        $insertLink = $pdo->prepare('INSERT INTO company_trip_types (company_id, trip_type_id) VALUES (?, ?)');
        foreach ($tripTypeIds as $tripTypeId) {
            $insertLink->execute([$id, (string) $tripTypeId]);
        }
    }

    $pdo->commit();

    $select = $pdo->prepare('SELECT * FROM companies WHERE id = ?');
    $select->execute([$id]);
    $company = $select->fetch();
    $company['trip_type_ids'] = $tripTypeIds;
    json_success(boolify($company, ['aktif']));
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
