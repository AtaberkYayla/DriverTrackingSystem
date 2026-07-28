<?php
declare(strict_types=1);

function json_success($data, int $status = 200): void
{
    http_response_code($status);
    echo json_encode(['data' => $data], JSON_UNESCAPED_UNICODE);
    exit;
}

// code: makine-okunabilir kisa kod (ornek: 'fk_in_use', 'invalid_credentials') -
// Flutter tarafinda ApiException.code olarak yakalanip davranis buna gore secilir.
function json_error(string $code, string $message, int $status = 400): void
{
    http_response_code($status);
    echo json_encode(['error' => ['code' => $code, 'message' => $message]], JSON_UNESCAPED_UNICODE);
    exit;
}

// MySQL'in TINYINT(1) sutunlari PDO'dan PHP int (1/0) olarak doner, json_encode
// bunu da JSON sayisi olarak yazar - ama Dart tarafi bu alanlari `as bool` ile
// okuyor ve sayi gelince TypeError firlatiyor. Cikisa vermeden once gercek
// PHP bool'a ceviriyoruz ki json_encode true/false yazsin.
function boolify(array $row, array $keys): array
{
    foreach ($keys as $key) {
        if (array_key_exists($key, $row) && $row[$key] !== null) {
            $row[$key] = (bool) $row[$key];
        }
    }
    return $row;
}

function boolifyAll(array $rows, array $keys): array
{
    return array_map(static fn(array $row): array => boolify($row, $keys), $rows);
}
