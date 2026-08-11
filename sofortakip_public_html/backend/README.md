# Backend (PHP + MySQL) - Hestia Kurulumu

Bu klasor, projenin eski Supabase (Postgres) backend'inin yerini alan duz
PHP + MySQL API'sidir. SSH/Composer gerektirmez, tamamen Hestia'nin
tarayici tabanli Dosya Yoneticisi + Cron Jobs paneli uzerinden kurulabilir.

Hosting firmasinin istegi uzerine tum dosyalar tek klasorde, **alt klasorsuz
duz** bir yapida duruyor (`api/auth/login.php` degil, `auth_login.php` gibi).
Her dosya adi hangi kaynaga ait oldugunu onek olarak tasir: `auth_*`,
`profile_*`, `trips_*`, `trip_stops_*`, `master_data_*`, `accounts_*`,
`approvals_*` (endpoint'ler), `lib_*` (sadece require_once ile dahil edilen,
dogrudan cagrilmamasi gereken yardimci dosyalar), `cron_*`, `scripts_*`.

## Kurulum adimlari

1. **Veritabani**: Hestia panelinden bir MySQL veritabani + kullanici olusturun.
   phpMyAdmin'e girip `schema.sql` dosyasini import edin.
2. **config.php**: `config.example.php`'yi `config.php` olarak kopyalayip
   gercek DB bilgilerini, `ALLOWED_ORIGIN`'i (admin_web'in barinacagi
   domain), `PUBLIC_API_URL`'i (bu backend'in kendi genel adresi - onay
   maillerindeki linkler icin sart) ve rastgele bir `SEED_SECRET` girin.
3. **Dosyalari yukleyin**: Bu `backend/` klasorunun tamamini zip'leyip Hestia
   Dosya Yoneticisi'nden `public_html/backend/` olacak sekilde yukleyip
   extract edin (admin_web ile ayni domain/public_html altinda, bir alt
   klasor olarak - tam dizin yapisi icin bkz. proje kokundeki
   `DEPLOYMENT.md`). `config.php`'nin gercekten yuklendiginden emin olun
   (`config.example.php` degil).
4. **Hesaplari olusturun**: Tarayicidan bir kez
   `https://<domain>/backend/scripts_seed.php?secret=<SEED_SECRET>` adresini
   ziyaret edin. Bu sistem yoneticisi + 4 yonetici + 3 sofor icin giris hesabi
   olusturur (ortak gecici sifre `test123`), 35 ismi hesapsiz
   "Talep Eden" master verisi, 46 arac plakasi, 13 seyahat turu ve 42 firma
   ekler. Ardindan **`scripts_seed.php` dosyasini silin**.
5. **Master veri**: Araclar/firmalar/seyahat turleri Master Veri Yonetimi
   ekranindan girilebilir. Talep Edenler zaten seed edildi ama **e-postalari
   bos** (gercek adreslerini bilmiyorum) - onay maili gidebilmesi icin her
   birinin e-postasini o ekrandan tek tek girmeniz gerekiyor.
6. **Cron / mail gonderimi**: Bildirimler (`notification_outbox` tablosu)
   olusuyor ama gonderim su an devre disi - Dedem Mekatronik'in kendi mail
   otomasyon sistemi uzerinden gonderilecek, entegrasyon detaylari
   netlesince `cron_process_outbox.php` doldurulup Hestia > Cron Jobs
   kismindan dakikada bir calisacak sekilde eklenecek:
   ```
   * * * * * php /home/<kullanici>/web/<domain>/public_html/backend/cron_process_outbox.php
   ```
   O ana kadar bekleyen bildirimler tabloda birikir, veri kaybolmaz.
7. **SSL**: Bu domain/subdomain icin Hestia'dan ucretsiz Let's Encrypt
   sertifikasini aktif edin.
8. **Flutter tarafi**: `packages/admin_web/env/api.json` ve
   `packages/driver_app/env/api.json` icine
   `{"API_BASE_URL": "https://<bu-domain>/backend"}` yazin.

## API sozlesmesi

- Basari: `{"data": ...}`
- Hata: `{"error": {"code": "...", "message": "..."}}` + uygun HTTP status
  (401 unauthorized, 403 forbidden, 404 not_found, 409 fk_in_use/username_taken,
  422 invalid_request, 500 internal_error).
- Kimlik dogrulama: `Authorization: Bearer <token>` header'i (login'den
  donen token, 30 gun gecerli, her istekte suresi uzamaz ama
  `last_used_at` guncellenir).
- DELETE istekleri `?id=...` query param ile calisir (govde/body gerekmez).

## Eski Supabase mimarisiyle farklar (bilerek yapilan basitlestirmeler)

- **Giris artik gercek bir `username` sutunuyla** yapiliyor - eski
  `usernameToEmail()` sentetik `@dedemmekatronik.com` e-posta hilesine
  (ve isim carpismasi riskine) gerek kalmadi.
- **"Anlik guncelleme"**: Postgres Realtime'in karsiligi yok - admin_web
  artik 5-7 saniyede bir `trips_list.php`'yi polluyor. Bu, gercek
  zamanli degil ama pratikte fark edilmeyecek kadar hizli.
- **Yetkilendirme**: eski RLS + trigger'lar artik her endpoint'in
  basindaki `requireRole(...)` cagrisi + hangi alanlarin kabul
  edildigine dair acik whitelist olarak kod icinde.
- **Onay Verici (office) hesabi yok**: admin_web'e sadece 4 yonetici +
  sistem yoneticisi girer. Talep Eden (Onay Verici) kisiler bunun yerine
  `requesters.email` adreslerine, icinde tek-tikla "Onayla" linki olan bir
  mail alir (bkz. `lib_notifications.php` + `approvals_approve.php`) -
  hicbir giris yapmadan seferi onaylayabilirler. Bu link 30 gun gecerli ve
  tek kullanimliktir; onaylandiktan sonra tekrar tiklanirsa "zaten
  onaylanmis" mesaji gosterir.
- **Mail gonderimi henuz entegre degil**: `notification_outbox` tablosuna
  kuyruklama (`lib_notifications.php`) calisir durumda, ama gercek gonderim
  (eskiden Gmail OAuth2 uzerinden yapiliyordu) kaldirildi - Dedem
  Mekatronik'in kendi mail otomasyon sistemi kullanilacak. Entegrasyon
  detaylari netlesince `cron_process_outbox.php` doldurulacak (bkz. dosya
  icindeki TODO).
