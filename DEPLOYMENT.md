# Canlıya Alma Rehberi — Hestia + Mobil APK

Bu doküman, sistemi Hestia panelli VPS'e kurup şoförlerin telefonuna
driver_app'i APK olarak yüklemek için izlenecek adımları sırayla anlatır.
Local (XAMPP) test ortamından farklı olarak burada **gerçek domain** ve
**gerçek Hestia paneli** kullanılıyor.

---

## Bölüm A — Backend + Veritabanı (Hestia)

### A1. Veritabanını oluştur
1. Hestia panelinde **Veritabanları (Databases)** kısmından yeni bir MySQL
   veritabanı ve kullanıcısı oluştur (ör. `dedem_takip` / `dedem_user`).
2. Oluşan bilgilerle **phpMyAdmin**'e gir, `dedem_takip` veritabanını seç,
   üstteki **İçe Aktar (Import)** sekmesinden `backend/schema.sql` dosyasını
   yükle ve çalıştır. Tüm tablolar (users, trips, trip_stops, vehicles,
   companies, requesters, approval_tokens, notification_outbox vb.)
   oluşmalı.

### A2. Domain ve dizin yapısı

Hosting firması tek bir domain/`public_html` altında çalışılmasını istediği
için admin_web (statik dosyalar) ile backend (PHP) **aynı domain**, aynı
`public_html` içinde, backend sadece bir alt klasörde yer alacak şekilde
kuruluyor. İkisi aynı origin'de olduğu için CORS'a bile gerek kalmıyor.

```
public_html/
  index.html          <- admin_web (flutter build web çıktısı, kök dizinde)
  main.dart.js
  flutter_bootstrap.js
  assets/
  icons/
  favicon.png
  manifest.json
  backend/            <- backend/ klasörünün tamamı, düz (alt klasörsüz) yapıda
    config.php
    auth_login.php, auth_me.php, trips_list.php, trip_stops_upsert.php, ...
    lib_db.php, lib_bootstrap.php, ...   (sadece dahil edilir, .htaccess ile
                                          dogrudan erisimi kapali)
    schema.sql        (tarayıcıdan .htaccess ile erişime kapalı)
```

> **Not:** Backend'deki tüm PHP dosyaları hosting firmasının istediği şekilde
> **tek klasörde, alt klasörsüz** duruyor (`backend/api/auth/login.php` değil,
> `backend/auth_login.php` gibi) — her dosya adı hangi kaynağa ait olduğunu
> önek olarak taşıyor (`auth_`, `trips_`, `trip_stops_`, `master_data_`,
> `accounts_`, `approvals_`, `lib_`, `cron_`, `scripts_`).

1. Hestia'da tek domain (ör. `dedemmekatronik.com` veya bir subdomain) için
   **ücretsiz Let's Encrypt SSL** sertifikasını aktif et.
2. Backend'e erişim adresi `https://dedemmekatronik.com/backend` olacak,
   admin_web ise `https://dedemmekatronik.com` kökünde açılacak.

### A3. Backend dosyalarını yükle
1. `backend/` klasörünün **tamamını** zip'le.
2. Hestia **Dosya Yöneticisi**'nden domain'in `public_html/` dizini **altına**
   yükleyip extract et — sonucun `public_html/backend/auth_login.php`,
   `public_html/backend/trips_list.php` şeklinde olması lazım (yani `backend`
   klasörü `public_html`'in içinde bir alt klasör, `public_html`'in kendisi
   değil; `backend/` içindeki dosyaların kendisi zaten alt klasörsüz/düz).
3. `public_html/backend/config.example.php`'yi **aynı klasörde** `config.php`
   olarak kopyala (Dosya Yöneticisi'nde "Copy/Rename" ile) ve içini doldur:
   - `DB_HOST`, `DB_NAME`, `DB_USER`, `DB_PASS` → A1'de oluşturduğun bilgiler
   - `ALLOWED_ORIGIN` → `https://dedemmekatronik.com` (aynı origin olduğu
     için pratikte devreye girmeyecek ama yine de doğru domain'i yaz, `*`
     canlıda kullanılmamalı)
   - `PUBLIC_API_URL` → `https://dedemmekatronik.com/backend` (onay
     maillerindeki linkler için; mail gönderimi entegre edilene kadar
     kullanılmıyor ama doğru girilsin)
   - `SEED_SECRET` → rastgele, tahmin edilemez bir değer üret

   > **Not:** `config.php` `.htaccess` tarafından tarayıcıdan doğrudan
   > erişime kapatılmıştır, ama yine de gerçek şifreleri kimseyle paylaşma.

### A4. Hesapları ve master veriyi oluştur
1. Tarayıcıdan **bir kez** ziyaret et:
   ```
   https://dedemmekatronik.com/backend/scripts_seed.php?secret=<SEED_SECRET>
   ```
2. Şunlar oluşmalı: 1 admin + 4 yönetici + 3 şoför hesabı (ortak geçici şifre
   `test123`), 35 Talep Eden (e-postasız), 46 araç plakası,
   13 seyahat türü, 42 firma (irsaliyeli sevkiyatlar için).
3. **Güvenlik için hemen ardından** `scripts_seed.php` dosyasını Hestia
   Dosya Yöneticisi'nden **sil**.
4. Master Veri Yönetimi ekranından (admin_web kurulduktan sonra) **35 Talep
   Eden'in gerçek e-posta adreslerini** tek tek gir — onay maili
   gidebilmesi için bu şart (mail entegrasyonu tamamlanınca).

### A5. Mail gönderimi (bilgi amaçlı — şu an aksiyon gerektirmiyor)
Gmail entegrasyonu koddan kaldırıldı; Dedem Mekatronik'in kendi mail
otomasyon sistemi üzerinden gönderim yapılacak. `notification_outbox`
tablosu bildirimleri biriktirmeye devam ediyor, gerçek gönderim
`backend/cron_process_outbox.php` içine o sistem entegre edildiğinde
eklenecek. Şimdilik bu adımda yapılacak bir şey yok.

### A6. admin_web'i derle ve yükle
1. `packages/admin_web/env/api.json` dosyasını gerçek backend adresine göre düzenle:
   ```json
   { "API_BASE_URL": "https://dedemmekatronik.com/backend" }
   ```
2. Derle (aynı domain'in kökünde barınacağı için `--base-href` gerekmiyor,
   varsayılan `/` yeterli):
   ```bash
   cd packages/admin_web
   flutter build web --dart-define-from-file=env/api.json
   ```
3. Oluşan `build/web/` klasörünün **içeriğini** (klasörün kendisini değil,
   içindekileri — `index.html`, `main.dart.js`, `assets/` vb.) Hestia Dosya
   Yöneticisi'nden domain'in `public_html/` **kökine** yükle. `backend/`
   klasörüyle **aynı seviyede**, onun yanına gelecek (üzerine yazma).
4. `https://dedemmekatronik.com` adresini aç, `admin` /
   `test123` ile giriş yap, ardından **Profilim** ekranından
   şifreni değiştir. Diğer 4 yönetici ve 3 şoför de ilk girişte şifresini
   değiştirmeli.

---

## Bölüm B — driver_app'i APK Olarak Şoförlere Ulaştırma

### B1. Backend adresini ayarla
`packages/driver_app/env/api.json` dosyasını gerçek backend adresine göre düzenle:
```json
{
  "API_BASE_URL": "https://dedemmekatronik.com/backend",
  "APK_VERSION_URL": "https://dedemmekatronik.com/apk/version.json"
}
```
`APK_VERSION_URL`, uygulama içi otomatik güncellemenin (bkz. B3) kontrol
ettiği adres — genelde değiştirmene gerek yok, `api.example.json`'daki
varsayılan zaten doğru domain'i gösteriyor.

### B2. APK'yı derle
```bash
cd packages/driver_app
flutter build apk --release --dart-define-from-file=env/api.json
```
Derleme bitince APK şurada oluşur:
```
packages/driver_app/build/app/outputs/flutter-apk/app-release.apk
```

> **Not:** Release derlemesi şu an **debug imza anahtarı** ile imzalanıyor
> ([android/app/build.gradle.kts](packages/driver_app/android/app/build.gradle.kts)) —
> Play Store'a değil, doğrudan şoförlerin telefonuna kurulum (sideload) için
> bu bir sorun değil. Sadece APK'yı ileride güncellerken **aynı bilgisayardaki**
> debug keystore ile imzalamaya devam etmen gerekiyor, aksi halde şoförler
> yeni sürümü "üzerine kurulum" yerine önce eskisini kaldırıp kurmak zorunda kalır.
> Uygulama içi otomatik güncelleme (bkz. B3) bu durumda sessizce "Tekrar Dene"
> döngüsüne düşer, bu yüzden bu kural artık daha da kritik.

> **Her yayında:** `packages/driver_app/pubspec.yaml`'daki `version: 1.0.0+N`
> satırının `+N` kısmını (build numarası) bir önceki yayından **daha büyük**
> bir değere çıkar — uygulama içi otomatik güncelleme (B3) bunu şoförün
> telefonundaki sürümle karşılaştırıyor.

### B3. APK'yı şoförlere ulaştır

**Otomatik güncelleme (önerilen — şoförler artık uygulama içinden güncelleniyor):**
APK'nın yanına küçük bir `version.json` da yükle, aynı `public_html/apk/`
klasörüne:
```json
{
  "versionCode": 2,
  "versionName": "1.1.0",
  "apkUrl": "https://dedemmekatronik.com/apk/driver_app.apk",
  "notes": "Bu sürümde neler değişti (opsiyonel, şoföre gösterilir)"
}
```
`versionCode`, pubspec.yaml'da az önce artırdığın build numarasıyla (`+N`)
aynı olmalı. Uygulama açılışta bu dosyayı kontrol eder; daha yeni bir
`versionCode` görürse şoför güncelleyene kadar uygulamayı kullandırmaz
(zorunlu güncelleme ekranı) — telefona fiziksel erişim gerekmez.

**İlk kurulum (bir şoförün telefonuna henüz hiç kurulmamışsa) hâlâ elle
yapılıyor:**
- APK dosyasını Hestia Dosya Yöneticisi'nden `public_html/` altına (ör.
  `public_html/apk/driver_app.apk`) yükleyip `https://dedemmekatronik.com/apk/driver_app.apk`
  linkini şoförle paylaşmak, **veya**
- WhatsApp/e-posta ile doğrudan dosya olarak göndermek.

### B4. Telefona kurulum (her şoförün kendi telefonunda)
1. Linke tıklayıp/dosyayı açıp APK'yı indir.
2. Android "Bilinmeyen kaynaklardan yükleme" (Install unknown apps) izni
   isteyebilir — o tarayıcı/uygulama için izin ver.
3. Kurulumu tamamla, uygulamayı aç.
4. Kendi kullanıcı adı/şifresiyle giriş yapsın (`oktay.yakut`,
   `ali.ihsan.duran`, `levent.uzun` — ortak geçici şifre
   `test123`, ilk girişte değiştirilmeli).

### B5. Doğrulama
Bir şoför gerçek bir "Fabrika Çıkış → Firma Girişi" akışı denesin;
admin_web'de **Seferler** ekranında (6 saniyelik otomatik yenilemeyle)
görünmesi gerekiyor.

---

## Kısa Kontrol Listesi

- [ ] MySQL veritabanı oluşturuldu, `schema.sql` import edildi
- [ ] `backend/` klasörü `public_html/backend/` altına yüklendi (public_html'in
      kendisi değil, bir alt klasör olarak), `config.php` gerçek değerlerle dolduruldu
- [ ] `seed.php` bir kez çalıştırıldı, ardından silindi
- [ ] Talep Eden'lerin gerçek e-postaları Master Veri Yönetimi'nden girildi
- [ ] Domain için SSL aktif
- [ ] `admin_web` derlenip `public_html/` köküne (backend'in yanına) yüklendi, admin girişi test edildi
- [ ] `driver_app` APK olarak derlendi, en az bir şoför telefonuna kuruldu
- [ ] Uçtan uca bir test seferi admin panelde göründü
