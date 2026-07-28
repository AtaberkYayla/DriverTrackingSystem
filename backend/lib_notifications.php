<?php
declare(strict_types=1);

require_once __DIR__ . '/config.php';

// migration_007_notification_outbox.sql'deki notify_trip_stop_event()'in PHP
// karsiligi: agir/ag gerektiren hicbir sey yapmaz, sadece notification_outbox
// tablosuna hizli bir INSERT yapar - trip_stops yazisini ASLA geciktirmez.
// Gercek mail gonderimi cron_process_outbox.php tarafindan ayri yapilir.
//
// Talep Eden (Onay Verici) hesabi olmadigi icin onay dogrudan mail
// uzerinden yapilir: kendisine ozel bir "Onayla" linki (approval_tokens)
// icinde HTML bir mail gider, tikladiginda approvals_approve.php
// hicbir girise gerek kalmadan durak (trip_stop) onaylar.
function queueTripStopNotification(PDO $pdo, array $trip, array $stop, string $islem): void
{
    try {
        $driverStmt = $pdo->prepare(
            'SELECT u.full_name AS sofor, v.plaka
             FROM users u, vehicles v
             WHERE u.id = ? AND v.id = ?'
        );
        $driverStmt->execute([$trip['driver_id'], $trip['vehicle_id']]);
        $info = $driverStmt->fetch() ?: ['sofor' => '-', 'plaka' => '-'];

        $gidilen = trim(($stop['gidilen_il'] ?? '') . ' / ' . ($stop['gidilen_ilce'] ?? ''), " /");
        if ($gidilen === '') {
            $gidilen = $stop['gidilen_sirket_free'] ?? '-';
        }

        $konu = $islem . ' - ' . $info['sofor'] . ' - ' . $info['plaka'];
        $ozet = 'Şoför: ' . $info['sofor'] . "\n" .
                'Plaka: ' . $info['plaka'] . "\n" .
                'İşlem: ' . $islem . "\n" .
                'Gidilen Yer: ' . $gidilen . "\n" .
                'Zaman: ' . date('d.m.Y H:i');

        // Alici 1: Talep Eden'in kendi e-postasi - tek tikla onay linki icerir.
        // Zaten onaylanmissa tekrar link gondermeye gerek yok.
        if (!empty($stop['requester_id']) && ($stop['onay_durumu'] ?? null) !== 'ONAYLANDI') {
            $reqStmt = $pdo->prepare(
                'SELECT email FROM requesters WHERE id = ? AND email IS NOT NULL AND email <> \'\''
            );
            $reqStmt->execute([$stop['requester_id']]);
            $requester = $reqStmt->fetch();
            if ($requester !== false) {
                $approveUrl = createApprovalLink($pdo, $stop['id']);
                $html = renderApprovalEmailHtml($konu, $ozet, $approveUrl);
                insertOutbox($pdo, $requester['email'], $konu, $html, true);
            }
        }

        // Alici 2: bildirim tercihi acik olan tum yonetici/admin'ler (bilgilendirme, HTML - onay linki yok).
        $stmt = $pdo->query(
            "SELECT notification_email FROM users
             WHERE role IN ('manager','admin') AND email_bildirim_aktif = 1
               AND notification_email IS NOT NULL"
        );
        foreach ($stmt->fetchAll() as $alici) {
            insertOutbox($pdo, $alici['notification_email'], $konu, renderInfoEmailHtml($konu, $ozet), true);
        }
    } catch (Throwable $e) {
        // Bildirim kuyruga alinamasa bile soforun islemi (trip_stop yazisi) ASLA engellenmemeli.
        error_log('queueTripStopNotification basarisiz: ' . $e->getMessage());
    }
}

/// Tek kullanimlik, 30 gun gecerli bir onay tokeni uretir ve tam URL'sini doner.
function createApprovalLink(PDO $pdo, string $stopId): string
{
    $raw = bin2hex(random_bytes(32));
    $hash = hash('sha256', $raw);
    $pdo->prepare(
        'INSERT INTO approval_tokens (token_hash, stop_id, expires_at)
         VALUES (?, ?, DATE_ADD(NOW(), INTERVAL 30 DAY))'
    )->execute([$hash, $stopId]);

    $base = defined('PUBLIC_API_URL') ? rtrim(PUBLIC_API_URL, '/') : '';
    return $base . '/approvals_approve.php?token=' . $raw;
}

// Mail'lerin gelen kutusunda hemen taninmasi icin ortak logo + marka basligi.
// Favicon.png admin_web'in kendi build'inde herkese acik durdugu icin (ayni
// domain'in koku) ekstra bir dosya barindirmaya gerek kalmiyor.
function emailLogoUrl(): string
{
    $base = defined('ALLOWED_ORIGIN') ? rtrim(ALLOWED_ORIGIN, '/') : '';
    return $base . '/favicon.png';
}

function renderEmailHeader(): string
{
    $logoUrl = htmlspecialchars(emailLogoUrl(), ENT_QUOTES);
    return <<<HTML
<table role="presentation" cellpadding="0" cellspacing="0" style="width:100%; border-bottom:3px solid #7A1F2E; margin-bottom:24px;">
  <tr>
    <td style="padding:4px 0 16px 0; vertical-align:middle;">
      <img src="{$logoUrl}" width="36" height="36" alt="Dedem Mekatronik" style="vertical-align:middle; border-radius:50%;">
      <span style="font-size:15px; font-weight:bold; color:#222; vertical-align:middle; padding-left:10px;">Dedem Mekatronik &middot; Şoför Takip Sistemi</span>
    </td>
  </tr>
</table>
HTML;
}

function renderEmailFooter(): string
{
    return <<<HTML
<p style="color:#aaa; font-size:11px; margin-top:32px; border-top:1px solid #eee; padding-top:12px;">
  Bu otomatik bir bildirimdir, Şoför Takip Sistemi tarafından gönderilmiştir.
</p>
HTML;
}

function renderApprovalEmailHtml(string $konu, string $ozet, string $approveUrl): string
{
    $ozetHtml = nl2br(htmlspecialchars($ozet));
    $safeUrl = htmlspecialchars($approveUrl, ENT_QUOTES);
    $header = renderEmailHeader();
    $footer = renderEmailFooter();
    return <<<HTML
<div style="font-family: Arial, sans-serif; max-width: 480px; margin: 0 auto; color:#222;">
  {$header}
  <h2 style="color:#7A1F2E; margin-bottom: 16px;">{$konu}</h2>
  <p style="line-height:1.6; font-size:15px;">{$ozetHtml}</p>
  <p style="margin-top:28px;">
    <a href="{$safeUrl}"
       style="background:#4F7358; color:#ffffff; padding:14px 28px; text-decoration:none;
              border-radius:6px; font-weight:bold; font-size:15px; display:inline-block;">
      Onayla
    </a>
  </p>
  <p style="color:#888; font-size:12px; margin-top:24px;">
    Bu bağlantıya tıkladığınızda ek bir giriş yapmanıza gerek kalmadan ziyaret onaylanır.
  </p>
  {$footer}
</div>
HTML;
}

// Yonetici/admin bilgilendirme maili - onay linki yok, sadece ozet + marka basligi.
function renderInfoEmailHtml(string $konu, string $ozet): string
{
    $ozetHtml = nl2br(htmlspecialchars($ozet));
    $header = renderEmailHeader();
    $footer = renderEmailFooter();
    return <<<HTML
<div style="font-family: Arial, sans-serif; max-width: 480px; margin: 0 auto; color:#222;">
  {$header}
  <h2 style="color:#7A1F2E; margin-bottom: 16px;">{$konu}</h2>
  <p style="line-height:1.6; font-size:15px;">{$ozetHtml}</p>
  {$footer}
</div>
HTML;
}

function insertOutbox(PDO $pdo, string $toEmail, string $subject, string $body, bool $isHtml = false): void
{
    $pdo->prepare(
        'INSERT INTO notification_outbox (to_email, subject, body, is_html) VALUES (?, ?, ?, ?)'
    )->execute([$toEmail, $subject, $body, $isHtml ? 1 : 0]);
}
