# Sofor Takip Sistemi - Dedem Mekatronik

Sofor mobil uygulamasi (`driver_app`), yonetim web paneli (`admin_web`),
aralarinda paylasilan model/repository kodu (`core`) ve PHP + MySQL
backend'i (`backend/`) icin monorepo.

## Proje Yapisi

```
backend/        PHP + MySQL API (Hestia'da barinir) - bkz. backend/README.md
packages/
  core/         Paylasilan modeller, API repository'leri, il/ilce verisi
  driver_app/   Sofor mobil uygulamasi (Android APK)
  admin_web/    Yonetim web paneli (Flutter Web)
```

Sefer modeli iki tabloya ayrilmistir: `trips` bir soforun fabrikadan
cikip fabrikaya donene kadarki OTURUMU, `trip_stops` ise o oturum icindeki
her firma ziyaretidir. Fabrika Cikis opsiyoneldir (sofor evden dogrudan
bir firmaya gidebilir); sefer sadece Fabrika Giris ile kapanir. Bir
sefer icinde, araya fabrika girmeden art arda birden fazla firma
ziyareti (trip_stop) yapilabilir.

Her paket kendi bagimliliklarini bagimsiz cozer (`flutter pub get` her
paket klasorunde ayri ayri calistirilir); `core` paketine `path:` bagimliligi
ile baglanirlar.

## Kurulum

### 1. Backend (PHP + MySQL)

Kurulum adimlari icin [backend/README.md](backend/README.md) dosyasina bakin
(Hestia panelinden veritabani + dosya yukleme + cron kurulumu).

Backend'in adresi kaynak koda gommek yerine her paketin `env/api.json`
dosyasindan (`env/api.example.json` sablonuna gore olusturulur) okunur.
Bu dosya `.gitignore` icindedir.

```json
{ "API_BASE_URL": "https://api.dedemmekatronik.com/backend" }
```

### 2. driver_app (mobil)

```bash
cd packages/driver_app
flutter pub get
flutter run --dart-define-from-file=env/api.json
```

APK almak icin:
```bash
flutter build apk --release --dart-define-from-file=env/api.json
```

### 3. admin_web (yonetim paneli)

```bash
cd packages/admin_web
flutter pub get
flutter run -d chrome --dart-define-from-file=env/api.json
```

Yayina almak icin:
```bash
flutter build web --dart-define-from-file=env/api.json
```
uretilen `build/web` klasoru Hestia'da statik dosya olarak (herhangi bir
domain/subdomain'in web kok dizinine yuklenerek) servis edilir - PHP
calistirmaya gerek yoktur.

## Kod Uretimi (build_runner)

`core` ve `driver_app` paketlerinde model/veritabani kodu uretimi gerekir;
kaynak dosyalar degistirildiginde yeniden calistirin:

```bash
cd packages/core && dart run build_runner build --delete-conflicting-outputs
cd packages/driver_app && dart run build_runner build --delete-conflicting-outputs
```

## Test

```bash
cd packages/core && flutter test
```
