<?php
declare(strict_types=1);

// Tek seferlik kurulum script'i.
//
// Giris hesabi olanlar: sistem yoneticisi + 4 yonetici + 3 sofor.
//
// Onay Verici (office) hesaplari KALDIRILDI - admin_web'e sadece yonetici/admin
// giris yapiyor. Eskiden "office" hesabi olarak olusturulan 35 kisi artik
// sadece 'requesters' (Talep Eden) master verisine, GIRIS HESABI OLMADAN
// ekleniyor - seferlerde kimin adina gidildigini kaydetmeye devam ediyor,
// kendileri sisteme giremiyor.
//
// Ayrica mevcut Excel tablosundan alinma 46 arac plakasi, 13 seyahat turu
// ve 42 firma da master veri olarak eklenir (panelden duzenlenebilir/silinebilir).
//
// Kullanim: tarayicidan bir kez
//   https://<domain>/backend/scripts_seed.php?secret=<config.php'deki SEED_SECRET>
// ziyaret edin. Idempotent'tir (var olan username/full_name'leri atlar), ama
// GUVENLIK icin calistirdiktan sonra bu dosyayi Hestia Dosya
// Yoneticisi'nden SILIN.

require_once __DIR__ . '/lib_db.php';
require_once __DIR__ . '/lib_uuid.php';

header('Content-Type: text/plain; charset=utf-8');

if (!defined('SEED_SECRET') || SEED_SECRET === '' || ($_GET['secret'] ?? '') !== SEED_SECRET) {
    http_response_code(403);
    echo "Yetkisiz. config.php icinde SEED_SECRET tanimlayip ?secret=... ile cagirin.\n";
    exit;
}

$pdo = getDb();
$password = 'test123';
$hash = password_hash($password, PASSWORD_DEFAULT);

// Giris hesabi olacaklar: sistem yoneticisi + 4 yonetici + 3 sofor.
$accounts = [
    ['Sistem Yöneticisi', 'admin', 'admin'],
    ['Anıl Bulut', 'anil.bulut', 'manager'],
    ['Koray Mete', 'koray.mete', 'manager'],
    ['Sercan Karataş', 'sercan.karatas', 'manager'],
    ['Kübra Ezgi Şen', 'kubra.sen', 'manager'],
    ['Oktay Yakut', 'oktay.yakut', 'driver'],
    ['Ali İhsan Duran', 'ali.ihsan.duran', 'driver'],
    ['Levent Uzun', 'levent.uzun', 'driver'],
];

// Giris hesabi OLMAYACAK, sadece Talep Eden (Onay Verici) master verisi.
$requesterNames = [
    'Hande Ankacık',
    'Merve Akar',
    'Radina Mardanova',
    'Osman Bozcaarmutlu',
    'Umut Özdemir',
    'Gökhan Ersan',
    'Serkan Topaloğlu',
    'Umut Aksu',
    'Dilek Akbal',
    'Şengül İmrenci',
    'Nalan Kaynar',
    'Hakan Yavas',
    'Dilan Koksoy',
    'Esma Rana İmrenci Kocatürk',
    'Şahin Yılmaz',
    'Nisa Sarıbıyık',
    'Aslıhan Ünal',
    'Gülşah Yarımca',
    'Mert Uğraş',
    'Caner Yeşil',
    'Recep Çakanlar',
    'Ulaş Özbent',
    'Feyza Hilal Sağlam',
    'Halil Ekmekçi',
    'Barışcan Çaylak',
    'Furkan Yüksel',
    'Erdal Temel',
    'Ewa Magdalena Warachowska',
    'Mustafa Sarıoğlu',
    'Onurcan Tosun',
    'Sema Esmer Filiz',
    'Elçin Yeği',
    'Sergen Doğanlı',
    'Şiyar Adıbelli',
    'Murat Çoban',
];

$insertUser = $pdo->prepare(
    'INSERT INTO users (id, username, password_hash, full_name, role, aktif) VALUES (?, ?, ?, ?, ?, 1)'
);
$userExists = $pdo->prepare('SELECT id FROM users WHERE username = ?');

$hesapSayisi = 0;
foreach ($accounts as [$fullName, $username, $role]) {
    $userExists->execute([$username]);
    if ($userExists->fetch() !== false) {
        continue;
    }
    $insertUser->execute([uuidv4(), $username, $hash, $fullName, $role]);
    $hesapSayisi++;
}

$insertRequester = $pdo->prepare(
    'INSERT INTO requesters (id, full_name, aktif) VALUES (?, ?, 1)'
);
$requesterExists = $pdo->prepare('SELECT id FROM requesters WHERE full_name = ?');

$talepEdenSayisi = 0;
foreach ($requesterNames as $fullName) {
    $requesterExists->execute([$fullName]);
    if ($requesterExists->fetch() !== false) {
        continue;
    }
    $insertRequester->execute([uuidv4(), $fullName]);
    $talepEdenSayisi++;
}

// Arac plakalari (mevcut Excel tablosundan alinma).
$plakalar = [
    '45 BBR 668', '45 BBR 669', '45 BBR 670', '45 BBR 672', '45 BBR 673',
    '35 BBA 714', '35 BBB 899', '35 BBA 713', '35 BBA 712', '35 BBA 711',
    '35 BBA 710', '35 AZT 506', '35 ESM 95', '35 BTZ 274', '35 BTZ 275',
    '35 BTZ 276', '35 BTZ 281', '35 BUB 086', '35 BTZ 277', '35 BTZ 279',
    '35 BTZ 280', '35 BUD 397', '35 BTZ 278', '35 BUD 465', '35 BUD 474',
    '35 CBY 225', '35 CAS 760', '35 CYB 212', '35 CBY 218', '35 CBY 240',
    '35 CAS 890', '35 CAS 892', '35 CAS 893', '35 CAS 891', '34 GPL 593',
    '34 HFP 784', '34 HFP 916', '34 KIR 166', '34 KTJ 245', '34 KTJ 047',
    '34 GZL 323', '34 GZL 146', '34 GPF 478', '34 GZL 351', '34 HFP 795',
    '34 KSP 962', '34 KLF 899',
];

$insertVehicle = $pdo->prepare('INSERT INTO vehicles (id, plaka, aktif) VALUES (?, ?, 1)');
$vehicleExists = $pdo->prepare('SELECT id FROM vehicles WHERE plaka = ?');

$aracSayisi = 0;
foreach ($plakalar as $plaka) {
    $vehicleExists->execute([$plaka]);
    if ($vehicleExists->fetch() !== false) {
        continue;
    }
    $insertVehicle->execute([uuidv4(), $plaka]);
    $aracSayisi++;
}

// Seyahat turleri (mevcut Excel tablosundan alinma).
$seyahatTurleri = [
    ['SATIN_ALMA_SEVKIYATI', 'Satın Alma Sevkiyatı', true, 1],
    ['FASON_SEVKIYAT', 'Fason Sevkiyat', true, 2],
    ['URETIM_SEVKIYATI', 'Üretim Sevkiyatı', true, 3],
    ['PERSONEL_ALIMI', 'Personel Alımı', false, 4],
    ['SGK', 'SGK', false, 5],
    ['ISKUR', 'İşkur', false, 6],
    ['BANKA', 'Banka', false, 7],
    ['KARGO', 'Kargo', false, 8],
    ['ARAC_TAMIRI', 'Araç Tamiri', false, 9],
    ['ARAC_BAKIM', 'Araç Bakım', false, 10],
    ['YEMEKHANE_MALZEME', 'Yemekhane Malzeme', false, 11],
    ['ARAC_VIZE', 'Araç Vize', false, 12],
    ['IKRAMLIK', 'İkramlık', false, 13],
];

$insertTripType = $pdo->prepare(
    'INSERT INTO trip_types (id, code, label, requires_irsaliye, sira, aktif) VALUES (?, ?, ?, ?, ?, 1)'
);
$tripTypeExists = $pdo->prepare('SELECT id FROM trip_types WHERE code = ?');

$turSayisi = 0;
foreach ($seyahatTurleri as [$code, $label, $requiresIrsaliye, $sira]) {
    $tripTypeExists->execute([$code]);
    if ($tripTypeExists->fetch() !== false) {
        continue;
    }
    $insertTripType->execute([uuidv4(), $code, $label, $requiresIrsaliye ? 1 : 0, $sira]);
    $turSayisi++;
}

// Firmalar (irsaliyeli sevkiyat sefer turlerinde "Gidilen Sirket" alaninda
// otomatik tamamlama olarak onerilir; listede yoksa yine serbest metin
// olarak yazilabilir - bkz. driver_app trip_detail_form.dart).
$sirketler = [
    'Abuşoğlu Kumlama',
    'MSS Boya',
    'Manisa Kaplama',
    'TMK Kaplama',
    'Savran Boya',
    'Şeker Eloksal ve Cam Küre Kumlama',
    'Polimak Vulkalon Kaplama',
    'Alaçam Vulkalon Teker Kaplama',
    'Batı Isıl İşlem',
    'Nursan Bobinaj, Motor Fren ve Encoder Montajı',
    'Zinc Power Daldırma Galvaniz Kaplama',
    'Tuncer Makine Zincir Kulak Montajı',
    'Kozanoğlu Makine/Profil Lazer Kesim',
    'Engin Kalıp/Inkol menteşe imalatı',
    'SALT MAK.END.YEDEK PARÇA .İTHALAT İHRACAT SAN VE.TİC.LTD.ŞTİ.',
    'ATLIER RULMANCILIK ENDÜSTRİYEL EKİPMAN TİC.LTD.ŞTİ.',
    'ÖZGÜR SOMUN CIVATA HIRDAVAT İNŞAAT TİC LTD ŞTİ',
    'ARİF ALAÇAM RULMAN TİC.SAN.LTD.ŞTİ',
    'ÖZGÜN BORA TEKNİK HIRDAVAT VE BÜRO KIR.SAN.TİC.LTD.ŞTİ.',
    'KARAELMAS TEK.HIRD.ATÖLYE MLZ.LTD.ŞTİ',
    'BONFIGLIOLİ GÜÇ AKTARMA VE OTO.TEK.SAN.TİC. A.Ş.',
    'AKR ALÜMİNYUM MARKET METAL VE METAL ÜR.SAN.TİC.LTD.ŞTİ.',
    'DOĞUŞ KALIP METAL VE FORM SAN DIŞ TİC.A.Ş.',
    'UMUT KAMA MAKİNE İMALAT DIŞ TİCARET SANAYİ VE TİC.LTD.ŞTİ.',
    'EGELF ENDÜSTÜRİYEL MAK.TEKN.MALZ.VE TİC.LTD.ŞTİ.',
    'İŞÇİMENLER KONVEYÖR BANT SİSTEMLERİ SAN.VE TİC. A.Ş.',
    'ENDO ENDÜSTRİYEL DONANIM VE OTOMASYON SİSTEMLERİ SAN.TİC.A.Ş.',
    'İZMİR ÇELİK SAN.TİC. A.Ş.',
    'YAGCILAR METAL ENDÜSTRI SANAYI ANONIM SIRKETI',
    'EGE BORU VE TEK. TES. MALZ. SAN. VE TİC. A.Ş.',
    'KARDEŞLER İMALAT ÇELİKLERİ SAN.TİC.LTD.ŞTİ',
    'EGE ASAL METAL METAL ÜRÜNLERİ TİC. LTD. ŞTİ.',
    'ALKOR ALUMİNYUM ENERJİ İNŞAAT SANAYİ VE TİC. A.Ş.',
    'METE KAUÇUK SAN. VE TİCARET A.Ş.',
    'ALMAR METAL ALÜMİNYUM SANAYİ TİCARET LİMİTED ŞİRKETİ',
    'BİLGE PROFİL ALÜMİNYUM MAK.SAN.TİC.LTD.ŞTİ.',
    'EGE MAGNET MIKNATİS BİLGİSAYAR ELEKTRİK ELEKTRONİK ÜRÜNLER T',
    'LEVENT YAY SANAYİ VE TİCARET LTD.ŞTİ.',
    'SEMSAN MAKİNA YEDEK PARÇA TEK. HİZ. SAN. TİC. LTD. ŞTİ.',
    'İZTEK PNÖMATİK OTOMASYON VE MÜHENDİSLİK SAN.TİC.LTD.ŞTİ',
    'TÜRKAY PLASTİK MAKİNA SAN.VE TİC.LTD.ŞTİ.',
    'BOLEM ELEKTRIK VE ELEKTRONİK SAN. VE TİC. A.Ş.',
];

$insertCompany = $pdo->prepare('INSERT INTO companies (id, name, aktif) VALUES (?, ?, 1)');
$companyExists = $pdo->prepare('SELECT id FROM companies WHERE name = ?');

$sirketSayisi = 0;
foreach ($sirketler as $name) {
    $companyExists->execute([$name]);
    if ($companyExists->fetch() !== false) {
        continue;
    }
    $insertCompany->execute([uuidv4(), $name]);
    $sirketSayisi++;
}

echo "Tamamlandi.\n";
echo "Yeni olusturulan hesap sayisi: $hesapSayisi (ortak sifre: $password, ilk giriste degistirilmeli)\n";
echo "Yeni eklenen Talep Eden sayisi: $talepEdenSayisi (e-postalari BOS - gercek adresleri bilmedigim\n";
echo "icin girmedim; onay maili gidebilmesi icin her birinin e-postasini Master Veri Yonetimi >\n";
echo "Talep Edenler ekranindan tek tek girmeniz gerekiyor).\n";
echo "Yeni eklenen arac sayisi: $aracSayisi\n";
echo "Yeni eklenen seyahat turu sayisi: $turSayisi\n";
echo "Yeni eklenen sirket sayisi: $sirketSayisi\n";
echo "GUVENLIK: Bu dosyayi (scripts_seed.php) calistirdiktan sonra Hestia Dosya Yoneticisi'nden SILIN.\n";
