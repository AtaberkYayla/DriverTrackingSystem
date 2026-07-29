<?php
require_once __DIR__ . '/lib_bootstrap.php';

$body = readJsonBody();
$username = strtolower(trim((string) ($body['username'] ?? '')));
$password = (string) ($body['password'] ?? '');

if ($username === '' || $password === '') {
    json_error('invalid_request', 'Kullanıcı adı ve şifre zorunludur', 422);
}

$stmt = $pdo->prepare('SELECT * FROM users WHERE username = ? LIMIT 1');
$stmt->execute([$username]);
$user = $stmt->fetch();

if ($user === false || !password_verify($password, $user['password_hash'])) {
    json_error('invalid_credentials', 'Kullanıcı adı veya şifre hatalı', 401);
}
if ((int) $user['aktif'] !== 1) {
    json_error('account_disabled', 'Hesabınız pasif durumda', 403);
}

$token = issueToken($pdo, $user['id']);
unset($user['password_hash']);

json_success(['token' => $token, 'profile' => boolify($user, ['aktif', 'email_bildirim_aktif'])]);
