<?php
require_once __DIR__ . '/lib_bootstrap.php';

// Eski admin_update_account() RPC'sinin karsiligi.
$user = requireRole($pdo, ['manager', 'admin']);
$body = readJsonBody();

$userId = (string) ($body['user_id'] ?? '');
if ($userId === '') {
    json_error('invalid_request', 'user_id zorunlu', 422);
}

$currentStmt = $pdo->prepare('SELECT role FROM users WHERE id = ?');
$currentStmt->execute([$userId]);
$current = $currentStmt->fetch();
if ($current === false) {
    json_error('not_found', 'Hesap bulunamadı', 404);
}

$newRole = $body['role'] ?? null;
$touchesManagerAdmin = in_array($current['role'], ['manager', 'admin'], true)
    || ($newRole !== null && in_array($newRole, ['manager', 'admin'], true));
// Yonetici/admin hesaplarini sadece admin duzenleyebilir - eski kuralla ayni.
if ($touchesManagerAdmin && $user['role'] !== 'admin') {
    json_error('forbidden', 'Yönetici veya admin hesaplarını sadece admin düzenleyebilir', 403);
}

$fields = [];
$params = [];
if (array_key_exists('full_name', $body)) {
    $fields[] = 'full_name = ?';
    $params[] = $body['full_name'];
}
if (array_key_exists('username', $body)) {
    $fields[] = 'username = ?';
    $params[] = strtolower(trim((string) $body['username']));
}
if (!empty($body['password'])) {
    $fields[] = 'password_hash = ?';
    $params[] = password_hash((string) $body['password'], PASSWORD_DEFAULT);
}
if ($newRole !== null) {
    $fields[] = 'role = ?';
    $params[] = $newRole;
}
if (array_key_exists('aktif', $body)) {
    $fields[] = 'aktif = ?';
    $params[] = (int) (bool) $body['aktif'];
}

if (!empty($fields)) {
    $params[] = $userId;
    $pdo->prepare('UPDATE users SET ' . implode(', ', $fields) . ' WHERE id = ?')->execute($params);
}

json_success(['ok' => true]);
