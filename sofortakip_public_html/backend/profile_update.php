<?php
require_once __DIR__ . '/lib_bootstrap.php';

$user = requireAuth($pdo);
$body = readJsonBody();

$fields = [];
$params = [];
if (array_key_exists('full_name', $body)) {
    $fields[] = 'full_name = ?';
    $params[] = (string) $body['full_name'];
}
if (array_key_exists('notification_email', $body)) {
    $fields[] = 'notification_email = ?';
    $params[] = $body['notification_email'];
}
if (array_key_exists('email_bildirim_aktif', $body)) {
    $fields[] = 'email_bildirim_aktif = ?';
    $params[] = (int) (bool) $body['email_bildirim_aktif'];
}

if (!empty($fields)) {
    $params[] = $user['id'];
    $pdo->prepare('UPDATE users SET ' . implode(', ', $fields) . ' WHERE id = ?')->execute($params);
}

json_success(['ok' => true]);
