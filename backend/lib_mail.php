<?php
declare(strict_types=1);

// Composer/SSH gerektirmeyen, tek dosyalik ham SMTP istemcisi (bkz.
// backend/README.md - proje bilerek hicbir disaridan kutuphane kullanmiyor).
// PHPMailer benzeri bir kutuphane yerine bu asgari istemci tercih edildi.

class SmtpException extends RuntimeException
{
}

function getMailSettings(PDO $pdo): ?array
{
    $stmt = $pdo->query('SELECT * FROM mail_settings WHERE id = 1');
    $row = $stmt->fetch();
    return $row === false ? null : $row;
}

function saveMailSettings(PDO $pdo, array $settings): void
{
    $fields = [
        'smtp_host' => $settings['smtp_host'] ?? null,
        'smtp_port' => $settings['smtp_port'] ?? null,
        'use_ssl' => (int) (bool) ($settings['use_ssl'] ?? true),
        'from_email' => $settings['from_email'] ?? null,
        'from_name' => $settings['from_name'] ?? null,
        'smtp_user' => $settings['smtp_user'] ?? null,
    ];

    $existing = getMailSettings($pdo);
    // Sifre alani bos/eksik gonderildiyse mevcut sifreyi koru - boylece
    // istemci her kayitta sifreyi tekrar gondermek zorunda kalmaz.
    if (array_key_exists('smtp_password', $settings) && $settings['smtp_password'] !== '') {
        $fields['smtp_password'] = $settings['smtp_password'];
    } else {
        $fields['smtp_password'] = $existing['smtp_password'] ?? null;
    }

    $pdo->prepare(
        'INSERT INTO mail_settings (id, smtp_host, smtp_port, use_ssl, from_email, from_name, smtp_user, smtp_password)
         VALUES (1, ?, ?, ?, ?, ?, ?, ?)
         ON DUPLICATE KEY UPDATE
           smtp_host = VALUES(smtp_host), smtp_port = VALUES(smtp_port), use_ssl = VALUES(use_ssl),
           from_email = VALUES(from_email), from_name = VALUES(from_name), smtp_user = VALUES(smtp_user),
           smtp_password = VALUES(smtp_password)'
    )->execute([
        $fields['smtp_host'], $fields['smtp_port'], $fields['use_ssl'], $fields['from_email'],
        $fields['from_name'], $fields['smtp_user'], $fields['smtp_password'],
    ]);
}

/// $settings: mail_settings tablosundan bir satir (smtp_host, smtp_port, use_ssl,
/// from_email, from_name, smtp_user, smtp_password). Basarisizlikta SmtpException firlatir.
function smtpSendMail(array $settings, string $to, string $subject, string $body, bool $isHtml = false): void
{
    $host = (string) ($settings['smtp_host'] ?? '');
    $port = (int) ($settings['smtp_port'] ?? 0);
    $useSsl = (bool) ($settings['use_ssl'] ?? false);
    $user = (string) ($settings['smtp_user'] ?? '');
    $pass = (string) ($settings['smtp_password'] ?? '');
    $fromEmail = (string) ($settings['from_email'] ?? '');
    $fromName = (string) ($settings['from_name'] ?? '');

    if ($host === '' || $port <= 0 || $fromEmail === '') {
        throw new SmtpException('Mail ayarları eksik (sunucu/port/gönderen e-posta zorunlu)');
    }

    $transport = ($useSsl ? 'ssl://' : '') . $host;
    $errno = 0;
    $errstr = '';
    $fp = @stream_socket_client($transport . ':' . $port, $errno, $errstr, 15);
    if ($fp === false) {
        throw new SmtpException("Sunucuya bağlanılamadı: $errstr ($errno)");
    }
    stream_set_timeout($fp, 15);

    try {
        $readResponse = function () use ($fp): string {
            $resp = '';
            while (($line = fgets($fp, 515)) !== false) {
                $resp .= $line;
                if (!isset($line[3]) || $line[3] === ' ') {
                    break;
                }
            }
            $meta = stream_get_meta_data($fp);
            if ($meta['timed_out'] || $resp === '') {
                throw new SmtpException('Sunucudan yanıt alınamadı (zaman aşımı)');
            }
            return $resp;
        };
        $expect = function (int $wantCode) use ($readResponse): string {
            $resp = $readResponse();
            $code = (int) substr($resp, 0, 3);
            if ($code !== $wantCode) {
                throw new SmtpException("Beklenmeyen sunucu yanıtı (kod $wantCode bekleniyordu): " . trim($resp));
            }
            return $resp;
        };
        $send = function (string $cmd) use ($fp): void {
            fwrite($fp, $cmd . "\r\n");
        };
        $ehloName = $_SERVER['SERVER_NAME'] ?? 'localhost';

        $expect(220);
        $send('EHLO ' . $ehloName);
        $ehloResp = $expect(250);

        if (!$useSsl && stripos($ehloResp, 'STARTTLS') !== false) {
            $send('STARTTLS');
            $expect(220);
            if (!stream_socket_enable_crypto($fp, true, STREAM_CRYPTO_METHOD_TLS_CLIENT)) {
                throw new SmtpException('STARTTLS ile şifreli bağlantı kurulamadı');
            }
            $send('EHLO ' . $ehloName);
            $expect(250);
        }

        if ($user !== '') {
            $send('AUTH LOGIN');
            $expect(334);
            $send(base64_encode($user));
            $expect(334);
            $send(base64_encode($pass));
            $expect(235);
        }

        $send('MAIL FROM:<' . $fromEmail . '>');
        $expect(250);
        $send('RCPT TO:<' . $to . '>');
        $expect(250);
        $send('DATA');
        $expect(354);

        $encodedSubject = '=?UTF-8?B?' . base64_encode($subject) . '?=';
        $fromHeader = $fromName !== ''
            ? ('=?UTF-8?B?' . base64_encode($fromName) . '?= <' . $fromEmail . '>')
            : $fromEmail;
        $contentType = $isHtml ? 'text/html' : 'text/plain';

        $headers = "From: $fromHeader\r\n"
            . "To: <$to>\r\n"
            . "Subject: $encodedSubject\r\n"
            . "MIME-Version: 1.0\r\n"
            . "Content-Type: $contentType; charset=UTF-8\r\n"
            . "Content-Transfer-Encoding: base64\r\n";

        // Govde base64 ile kodlanir - SMTP'nin "tek basina nokta = veri sonu"
        // kuralina (dot-stuffing) takilma ihtimali boylece tamamen ortadan kalkar.
        $encodedBody = chunk_split(base64_encode($body));

        $send($headers . "\r\n" . $encodedBody . "\r\n.");
        $expect(250);
        $send('QUIT');
    } finally {
        fclose($fp);
    }
}
