<?php
require_once __DIR__ . '/lib_bootstrap.php';
require_once __DIR__ . '/lib_mail.php';

// Sadece sistem yoneticisi gorebilir/degistirebilir.
requireRole($pdo, ['admin']);

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $settings = getMailSettings($pdo) ?? [];
    json_success([
        'smtp_host' => $settings['smtp_host'] ?? null,
        'smtp_port' => isset($settings['smtp_port']) ? (int) $settings['smtp_port'] : null,
        'use_ssl' => !isset($settings['use_ssl']) || (bool) $settings['use_ssl'],
        'from_email' => $settings['from_email'] ?? null,
        'from_name' => $settings['from_name'] ?? null,
        'smtp_user' => $settings['smtp_user'] ?? null,
        // Sifre hicbir zaman geri donulmez - sadece dolu olup olmadigi bilgisi verilir.
        'has_password' => !empty($settings['smtp_password'] ?? null),
    ]);
}

if ($method === 'POST') {
    $body = readJsonBody();
    saveMailSettings($pdo, $body);
    json_success(['ok' => true]);
}

json_error('method_not_allowed', 'Desteklenmeyen metod', 405);
