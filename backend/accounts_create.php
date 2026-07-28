<?php
require_once __DIR__ . '/lib_bootstrap.php';

// Eski admin_create_account() RPC'sinin karsiligi. GoTrue'nin auth.users/
// auth.identities sablon-kopyalama hilesine hic gerek yok - kendi users
// tablomuza dogrudan bcrypt hash ile INSERT yeterli.
$user = requireRole($pdo, ['manager', 'admin']);
$body = readJsonBody();

$fullName = (string) ($body['full_name'] ?? '');
$username = strtolower(trim((string) ($body['username'] ?? '')));
$password = (string) ($body['password'] ?? '');
$role = (string) ($body['role'] ?? '');

if ($fullName === '' || $username === '' || $password === '' || $role === '') {
    json_error('invalid_request', 'Eksik alanlar var', 422);
}
if (!in_array($role, ['driver', 'office', 'manager', 'admin'], true)) {
    json_error('invalid_request', 'Geçersiz rol', 422);
}
// Sadece admin, manager/admin hesabi olusturabilir - eski kuralla ayni.
if (in_array($role, ['manager', 'admin'], true) && $user['role'] !== 'admin') {
    json_error('forbidden', 'Yönetici veya admin hesabı oluşturmak için admin yetkisi gerekiyor', 403);
}

$dupStmt = $pdo->prepare('SELECT id FROM users WHERE username = ?');
$dupStmt->execute([$username]);
if ($dupStmt->fetch() !== false) {
    json_error('username_taken', 'Bu kullanıcı adı zaten kullanımda', 409);
}

$id = uuidv4();
$pdo->prepare(
    'INSERT INTO users (id, username, password_hash, full_name, role, aktif) VALUES (?, ?, ?, ?, ?, 1)'
)->execute([$id, $username, password_hash($password, PASSWORD_DEFAULT), $fullName, $role]);

json_success(['id' => $id]);
