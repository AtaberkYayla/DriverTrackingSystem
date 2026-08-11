<?php
declare(strict_types=1);

// Her api endpoint dosyasinin ilk satiri budur - DB baglantisi, CORS, JSON
// yardimcilari ve auth guard'larini tek yerden hazirlar.

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: ' . (defined('ALLOWED_ORIGIN') ? ALLOWED_ORIGIN : '*'));
header('Access-Control-Allow-Methods: GET, POST, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Authorization, Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

require_once __DIR__ . '/lib_db.php';
require_once __DIR__ . '/lib_response.php';
require_once __DIR__ . '/lib_uuid.php';
require_once __DIR__ . '/lib_auth.php';
require_once __DIR__ . '/lib_notifications.php';

set_exception_handler(function (Throwable $e): void {
    error_log($e->getMessage());
    json_error('internal_error', 'Beklenmeyen bir hata oluştu', 500);
});

function readJsonBody(): array
{
    $raw = file_get_contents('php://input');
    if ($raw === '' || $raw === false) {
        return [];
    }
    $decoded = json_decode($raw, true);
    return is_array($decoded) ? $decoded : [];
}

$pdo = getDb();
