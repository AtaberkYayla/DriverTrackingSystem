<?php
require_once __DIR__ . '/lib_bootstrap.php';

$user = requireAuth($pdo);
$body = readJsonBody();
$yeniSifre = (string) ($body['password'] ?? '');

if (strlen($yeniSifre) < 6) {
    json_error('invalid_request', 'Şifre en az 6 karakter olmalı', 422);
}

$hash = password_hash($yeniSifre, PASSWORD_DEFAULT);
$pdo->prepare('UPDATE users SET password_hash = ? WHERE id = ?')->execute([$hash, $user['id']]);

json_success(['ok' => true]);
