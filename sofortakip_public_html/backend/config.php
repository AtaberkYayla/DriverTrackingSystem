<?php
// Bu dosyayi 'config.php' olarak kopyalayip gercek degerlerle doldurun.
// config.php repoya commit edilmemeli (gercek DB sifresi icerir).

// --- MySQL baglantisi (Hestia > Veritabanlari kismindan olusturulan bilgiler) ---
define('DB_HOST', '127.0.0.1');
define('DB_NAME', 'it_sofortakip');
define('DB_USER', 'it_sofortakip');
define('DB_PASS', 'D3dq0rT@L');

// --- CORS: admin_web'in barindigi gercek domain ---
// admin_web ile backend ayni domain/public_html altinda barinacagi icin
// pratikte devreye girmeyecek, ama yine de dogru domain'i yazin, '*' canliya
// alirken kullanilmamali.
define('ALLOWED_ORIGIN', 'https://sofortakip.dedemmekatronik.com');

// --- Bu backend'in kendi genel adresi - onay maillerindeki "Onayla"
// linkinin tam URL'sini olusturmak icin kullanilir (cron baglaminda
// $_SERVER['HTTP_HOST'] olmadigi icin sabit tanimlanir). Sonunda / OLMASIN.
define('PUBLIC_API_URL', 'https://sofortakip.dedemmekatronik.com/backend');

// --- Oturum token suresi ---
define('TOKEN_TTL_DAYS', 30);

// --- Mail gonderimi: Dedem Mekatronik'in kendi mail otomasyon sistemi
// uzerinden yapilacak (entegrasyon detaylari netlesince cron_process_outbox.php
// icine eklenecek). Bildirimler su an notification_outbox tablosunda birikir.

// --- Tek seferlik hesap/master-veri seed script'i icin paylasilan sir ---
// scripts_seed.php SADECE ?secret=<bu deger> ile cagrilirsa calisir.
// Kullandiktan sonra scripts_seed.php dosyasini silmeniz onerilir.
define('SEED_SECRET', '914f98f2720df51db5bfd293f51f679d');