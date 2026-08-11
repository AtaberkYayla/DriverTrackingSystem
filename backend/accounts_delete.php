<?php
require_once __DIR__ . '/lib_bootstrap.php';

$user = requireRole($pdo, ['manager', 'admin']);

$userId = (string) ($_GET['id'] ?? '');
if ($userId === '') {
    json_error('invalid_request', 'id zorunlu', 422);
}
if ($userId === $user['id']) {
    json_error('invalid_request', 'Kendi hesabınızı silemezsiniz', 422);
}

$currentStmt = $pdo->prepare('SELECT role FROM users WHERE id = ?');
$currentStmt->execute([$userId]);
$current = $currentStmt->fetch();
if ($current === false) {
    json_error('not_found', 'Hesap bulunamadı', 404);
}

// Yonetici/admin hesaplarini sadece admin silebilir - create/update ile ayni kural.
if (in_array($current['role'], ['manager', 'admin'], true) && $user['role'] !== 'admin') {
    json_error('forbidden', 'Yönetici veya admin hesaplarını sadece admin silebilir', 403);
}

try {
    $pdo->prepare('DELETE FROM users WHERE id = ?')->execute([$userId]);
} catch (PDOException $e) {
    if ((int) $e->errorInfo[1] === 1451) {
        json_error('fk_in_use', 'Bu hesabın seferleri/onayları var, önce pasife alın', 409);
    }
    throw $e;
}

json_success(['ok' => true]);
