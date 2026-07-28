<?php
declare(strict_types=1);

function bearerToken(): ?string
{
    $header = $_SERVER['HTTP_AUTHORIZATION'] ?? null;
    if ($header === null && function_exists('apache_request_headers')) {
        $headers = apache_request_headers();
        $header = $headers['Authorization'] ?? $headers['authorization'] ?? null;
    }
    if ($header === null) {
        return null;
    }
    if (preg_match('/^Bearer\s+(.+)$/i', trim($header), $m)) {
        return $m[1];
    }
    return null;
}

// Gecerli bir token varsa kullanici satirini (password_hash HARIC) dondurur, yoksa null.
function currentUser(PDO $pdo): ?array
{
    $token = bearerToken();
    if ($token === null) {
        return null;
    }
    $hash = hash('sha256', $token);
    $stmt = $pdo->prepare(
        'SELECT u.* FROM auth_tokens t
         JOIN users u ON u.id = t.user_id
         WHERE t.token_hash = ? AND t.expires_at > NOW() AND u.aktif = 1'
    );
    $stmt->execute([$hash]);
    $user = $stmt->fetch();
    if ($user === false) {
        return null;
    }
    $pdo->prepare('UPDATE auth_tokens SET last_used_at = NOW() WHERE token_hash = ?')->execute([$hash]);
    unset($user['password_hash']);
    return boolify($user, ['aktif', 'email_bildirim_aktif']);
}

// Eski Postgres RLS'nin yerini alan yetki kontrolleri - her endpoint bunlari
// cagirarak "kim ne yapabilir" kuralini acikca kendi icinde uygular.
function requireAuth(PDO $pdo): array
{
    $user = currentUser($pdo);
    if ($user === null) {
        json_error('unauthorized', 'Giriş yapmanız gerekiyor', 401);
    }
    return $user;
}

function requireRole(PDO $pdo, array $roles): array
{
    $user = requireAuth($pdo);
    if (!in_array($user['role'], $roles, true)) {
        json_error('forbidden', 'Bu işlem için yetkiniz yok', 403);
    }
    return $user;
}

function issueToken(PDO $pdo, string $userId): string
{
    $raw = bin2hex(random_bytes(32));
    $hash = hash('sha256', $raw);
    $ttlDays = defined('TOKEN_TTL_DAYS') ? (int) TOKEN_TTL_DAYS : 30;
    $stmt = $pdo->prepare(
        'INSERT INTO auth_tokens (token_hash, user_id, created_at, expires_at)
         VALUES (?, ?, NOW(), DATE_ADD(NOW(), INTERVAL ? DAY))'
    );
    $stmt->execute([$hash, $userId, $ttlDays]);
    return $raw;
}
