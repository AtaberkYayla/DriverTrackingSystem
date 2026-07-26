# Sofor Takip Sistemi - Dedem Mekatronik

Sofor mobil uygulamasi (`driver_app`), yonetim web paneli (`admin_web`) ve
aralarinda paylasilan model/repository kodu (`core`) icin monorepo.

## Proje Yapisi

```
packages/
  core/         Paylasilan modeller, Supabase repository'leri, il/ilce verisi
  driver_app/   Sofor mobil uygulamasi (Android APK)
  admin_web/    Yonetim web paneli (Flutter Web)
supabase/
  schema.sql               Veritabani semasi, RLS politikalari, tetikleyiciler
  seed.sql                 Baslangic master verisi (arac, seyahat turu, talep eden, yonetici)
  migration_001_trip_stops.sql   Var olan bir projeyi trips+trip_stops semasina gecirir
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

### 1. Supabase projesi

1. [supabase.com](https://supabase.com) uzerinde yeni bir proje olusturun.
2. Proje SQL Editor'unde sirasiyla `supabase/schema.sql` ve `supabase/seed.sql`
   dosyalarini calistirin. Daha once eski (trip_stops'suz) semayi kurmus
   bir projeniz varsa, `schema.sql`'i tekrar calistirmak yerine sadece
   `supabase/migration_001_trip_stops.sql` dosyasini calistirmaniz yeterlidir
   (eski `trips` verisini siler, profiles/vehicles/vb. etkilenmez).
3. Settings > API sayfasindan **Project URL** ve **anon/publishable key**
   degerlerini alin.
4. Ilk yonetim (office/admin) kullanicisini Supabase Dashboard > Authentication
   uzerinden e-posta/sifre ile olusturun, ardindan SQL Editor'de:
   ```sql
   insert into profiles (id, full_name, role)
   values ('<auth.users id>', 'Ad Soyad', 'admin');
   ```
5. Sofor hesaplari icin: Supabase Auth kullanicisi
   `{kullanici_adi}@dedemmekatronik.com` e-postasiyla olusturulur
   (bkz. `AuthRepository.usernameToEmail`), sofore ise sadece kullanici adi
   ve sifre iletilir. `profiles` tablosuna `role = 'driver'` ile eklenir.
   Dikkat: kullanici adi, gercek bir personelin e-posta on-ekiyle (ör.
   ofis calisanin e-postasi ahmet@dedemmekatronik.com ise) ayni olmamalidir,
   aksi halde hesap catisir.

Supabase URL ve publishable key kaynak koda gommek yerine her paketin
`env/supabase.json` dosyasindan (`env/supabase.example.json` sablonuna gore
olusturulur) `--dart-define-from-file` ile okunur. Bu dosya `.gitignore`
icindedir, projeye zaten dolu haliyle eklenmistir.

### 2. driver_app (mobil)

```bash
cd packages/driver_app
flutter pub get
flutter run --dart-define-from-file=env/supabase.json
```

APK almak icin:
```bash
flutter build apk --release --dart-define-from-file=env/supabase.json
```

### 3. admin_web (yonetim paneli)

```bash
cd packages/admin_web
flutter pub get
flutter run -d chrome --dart-define-from-file=env/supabase.json
```

Yayina almak icin:
```bash
flutter build web --dart-define-from-file=env/supabase.json
```
uretilen `build/web` klasoru herhangi bir statik hosting (Netlify, Vercel,
Firebase Hosting) uzerine yuklenebilir.

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
