<?php
// LOCAL XAMPP test ortami icin olusturuldu. Bu dosya repoya commit edilmemeli.

// --- MySQL baglantisi (XAMPP varsayilani: root, sifresiz) ---
define('DB_HOST', '127.0.0.1');
define('DB_NAME', 'dedem_takip');
define('DB_USER', 'root');
define('DB_PASS', '');

// --- CORS: local admin_web/driver_app gelistirme adresleri ---
define('ALLOWED_ORIGIN', 'http://localhost');

// --- Bu backend'in kendi genel adresi (local) ---
define('PUBLIC_API_URL', 'http://localhost/backend');

// --- Oturum token suresi ---
define('TOKEN_TTL_DAYS', 30);

// --- Tek seferlik hesap/master-veri seed script'i icin paylasilan sir ---
define('SEED_SECRET', '8f1fe4d054c59783329b54c74afecc932277a80731c76633');
