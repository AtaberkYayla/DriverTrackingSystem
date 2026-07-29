<?php
require_once __DIR__ . '/lib_bootstrap.php';

$token = bearerToken();
if ($token !== null) {
    $pdo->prepare('DELETE FROM auth_tokens WHERE token_hash = ?')->execute([hash('sha256', $token)]);
}

json_success(['ok' => true]);
