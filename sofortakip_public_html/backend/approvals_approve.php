<?php
// Talep Eden'in (Onay Verici) hesabi yok - mailindeki "Onayla" butonu
// dogrudan bu sayfaya, kimlik dogrulama gerektirmeyen bir token ile gelir.
// Bilerek `lib_bootstrap.php` KULLANILMIYOR (JSON API degil, tarayicida acilan
// basit bir HTML sayfa; CORS/Authorization guard'lari burada anlamsiz).

require_once __DIR__ . '/lib_db.php';

header('Content-Type: text/html; charset=utf-8');

function renderPage(string $title, string $message, bool $success): never
{
    $color = $success ? '#1a7f37' : '#c92a2a';
    $safeTitle = htmlspecialchars($title);
    $safeMessage = htmlspecialchars($message);
    echo <<<HTML
<!doctype html>
<html lang="tr">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>{$safeTitle}</title>
</head>
<body style="font-family: Arial, sans-serif; text-align:center; padding: 64px 16px; background:#fafafa;">
  <h2 style="color:{$color};">{$safeTitle}</h2>
  <p style="color:#444; font-size:16px;">{$safeMessage}</p>
</body>
</html>
HTML;
    exit;
}

$token = (string) ($_GET['token'] ?? '');
if ($token === '') {
    renderPage('Geçersiz Bağlantı', 'Onay bağlantısı eksik veya hatalı.', false);
}

$pdo = getDb();
$hash = hash('sha256', $token);

$stmt = $pdo->prepare(
    'SELECT t.stop_id, t.expires_at, t.used_at, s.onay_durumu
     FROM approval_tokens t
     JOIN trip_stops s ON s.id = t.stop_id
     WHERE t.token_hash = ?'
);
$stmt->execute([$hash]);
$row = $stmt->fetch();

if ($row === false) {
    renderPage('Geçersiz Bağlantı', 'Bu onay bağlantısı geçerli değil.', false);
}

if ($row['onay_durumu'] === 'ONAYLANDI') {
    renderPage('Zaten Onaylanmış', 'Bu ziyaret daha önce onaylanmış, tekrar bir işlem yapmanıza gerek yok.', true);
}

if (strtotime((string) $row['expires_at']) < time()) {
    renderPage(
        'Bağlantının Süresi Dolmuş',
        'Bu onay bağlantısının süresi dolmuş. Lütfen ilgili yöneticiyle iletişime geçin.',
        false
    );
}

$pdo->prepare(
    "UPDATE trip_stops SET onay_durumu = 'ONAYLANDI', onaylandi_at = NOW() WHERE id = ?"
)->execute([$row['stop_id']]);
$pdo->prepare('UPDATE approval_tokens SET used_at = NOW() WHERE token_hash = ?')->execute([$hash]);

renderPage('Onaylandı', 'Ziyaret başarıyla onaylandı. Teşekkür ederiz.', true);
