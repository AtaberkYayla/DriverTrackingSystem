-- Sofor Takip Sistemi - Supabase (Postgres) semasi
-- Bu dosyayi Supabase projesinin SQL Editor'unde (veya `supabase db push` ile) calistirin.

create extension if not exists pgcrypto;

-- ============================================================
-- ENUM TIPLERI
-- ============================================================

create type app_role as enum ('driver', 'office', 'admin');
create type onay_durumu as enum ('BEKLEMEDE', 'ONAYLANDI');
create type sefer_durumu as enum ('DEVAM_EDIYOR', 'BASARILI', 'BASARISIZ');

-- ============================================================
-- REFERANS / MASTER VERI TABLOLARI
-- ============================================================

create table profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  full_name text not null,
  role app_role not null default 'driver',
  phone text,
  aktif boolean not null default true,
  created_at timestamptz not null default now()
);

create table vehicles (
  id uuid primary key default gen_random_uuid(),
  plaka text not null unique,
  aciklama text,
  aktif boolean not null default true,
  created_at timestamptz not null default now()
);

create table trip_types (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  label text not null,
  requires_irsaliye boolean not null default false,
  sira int not null default 0,
  aktif boolean not null default true
);

create table requesters (
  id uuid primary key default gen_random_uuid(),
  full_name text not null,
  aktif boolean not null default true
);

create table managers (
  id uuid primary key default gen_random_uuid(),
  full_name text not null,
  aktif boolean not null default true
);

create table companies (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  sehir text,
  aktif boolean not null default true
);

-- ============================================================
-- SEFERLER (TRIPS) - OTURUM TABLOSU
-- ============================================================
-- Bir "sefer" (trip), soforun fabrikadan cikip fabrikaya donene kadarki
-- tum gunudur. Fabrika Cikis opsiyoneldir (sofor evden dogrudan bir
-- firmaya da gidebilir) ama sefer SADECE Fabrika Giris ile kapanir.
-- Bir sefer icinde, araya fabrika girmeden art arda birden fazla firma
-- ziyareti (trip_stops) olabilir.

create table trips (
  id uuid primary key default gen_random_uuid(),
  client_trip_id uuid not null unique,

  driver_id uuid not null references profiles (id),
  vehicle_id uuid not null references vehicles (id),
  tarih date not null default current_date,

  fabrika_cikis_at timestamptz,   -- opsiyonel: sefer fabrikadan basladiysa dolar
  fabrika_giris_at timestamptz,   -- seferi kapatir; bu dolana kadar sefer "aktif" sayilir

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Bir soforun ayni anda sadece bir aktif (kapanmamis) seferi olabilir
create unique index one_active_trip_per_driver
  on trips (driver_id)
  where fabrika_giris_at is null;

create index trips_driver_id_idx on trips (driver_id);
create index trips_tarih_idx on trips (tarih);

-- ============================================================
-- SEFER DURAKLARI (TRIP_STOPS) - HER FIRMA ZIYARETI
-- ============================================================
-- Excel'deki her satir aslinda bir "durak"tir: sefer detaylari
-- (seyahat turu, talep eden, gidilen yer/sirket, irsaliye no) ve
-- onay/degerlendirme burada, durak bazinda tutulur.

create table trip_stops (
  id uuid primary key default gen_random_uuid(),
  client_stop_id uuid not null unique,
  trip_id uuid not null references trips (id) on delete cascade,
  sira int not null default 1,

  -- Firma Giris (+ sofor tarafindan o an girilen sefer detaylari)
  firma_giris_at timestamptz not null,
  trip_type_id uuid references trip_types (id),
  requester_id uuid references requesters (id),
  cikis_nedeni text,
  gidilen_il text,
  gidilen_ilce text,
  gidilen_sirket_id uuid references companies (id),
  gidilen_sirket_free text,
  irsaliye_no text,

  -- Firma Cikis
  firma_cikis_at timestamptz,

  -- Onay / degerlendirme (sadece ofis/yonetim yazabilir)
  onay_durumu onay_durumu not null default 'BEKLEMEDE',
  onaylayan_id uuid references profiles (id),
  onaylandi_at timestamptz,
  sefer_durumu sefer_durumu not null default 'DEVAM_EDIYOR',
  notlar text,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Bir sefer icinde ayni anda sadece bir acik durak (firma_cikis_at is null) olabilir
create unique index one_open_stop_per_trip
  on trip_stops (trip_id)
  where firma_cikis_at is null;

create index trip_stops_trip_id_idx on trip_stops (trip_id);
create index trip_stops_onay_durumu_idx on trip_stops (onay_durumu);

create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger trips_set_updated_at
  before update on trips
  for each row execute function set_updated_at();

create trigger trip_stops_set_updated_at
  before update on trip_stops
  for each row execute function set_updated_at();

-- ============================================================
-- ROL YARDIMCI FONKSIYONU (RLS icinde profiles'a recursive
-- sorgu atmamak icin security definer fonksiyon kullanilir)
-- ============================================================

create or replace function auth_role()
returns app_role as $$
  select role from profiles where id = auth.uid();
$$ language sql stable security definer set search_path = public;

create or replace function is_office_or_admin()
returns boolean as $$
  select auth_role() in ('office', 'admin');
$$ language sql stable security definer set search_path = public;

-- ============================================================
-- TRIP_STOPS: SUTUN BAZLI YAZMA KISITLAMASI
-- Soforler onay/degerlendirme sutunlarini degistiremez;
-- ofis/yonetim sefer detay sutunlarini degistiremez.
-- ============================================================

create or replace function enforce_trip_stop_column_permissions()
returns trigger as $$
begin
  if auth_role() = 'driver' then
    if new.onay_durumu is distinct from old.onay_durumu
      or new.onaylayan_id is distinct from old.onaylayan_id
      or new.onaylandi_at is distinct from old.onaylandi_at
      or new.sefer_durumu is distinct from old.sefer_durumu
      or new.notlar is distinct from old.notlar then
      raise exception 'Soforler onay/degerlendirme alanlarini degistiremez';
    end if;
  elsif is_office_or_admin() then
    if new.firma_giris_at is distinct from old.firma_giris_at
      or new.firma_cikis_at is distinct from old.firma_cikis_at
      or new.trip_type_id is distinct from old.trip_type_id
      or new.requester_id is distinct from old.requester_id
      or new.cikis_nedeni is distinct from old.cikis_nedeni
      or new.gidilen_il is distinct from old.gidilen_il
      or new.gidilen_ilce is distinct from old.gidilen_ilce
      or new.gidilen_sirket_id is distinct from old.gidilen_sirket_id
      or new.gidilen_sirket_free is distinct from old.gidilen_sirket_free
      or new.irsaliye_no is distinct from old.irsaliye_no then
      raise exception 'Ofis/yonetim sefer detaylarini degistiremez';
    end if;
  end if;
  return new;
end;
$$ language plpgsql;

create trigger trip_stops_enforce_column_permissions
  before update on trip_stops
  for each row execute function enforce_trip_stop_column_permissions();

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

alter table profiles enable row level security;
alter table vehicles enable row level security;
alter table trip_types enable row level security;
alter table requesters enable row level security;
alter table managers enable row level security;
alter table companies enable row level security;
alter table trips enable row level security;
alter table trip_stops enable row level security;

-- profiles: herkes kendi satirini gorur; ofis/yonetim hepsini gorur ve yonetir
create policy profiles_select_own on profiles
  for select using (id = auth.uid() or is_office_or_admin());

create policy profiles_update_own on profiles
  for update using (id = auth.uid() or is_office_or_admin());

create policy profiles_office_insert on profiles
  for insert with check (is_office_or_admin());

-- master veri tablolari: giris yapan herkes okuyabilir, sadece ofis/yonetim yazabilir
create policy vehicles_select on vehicles for select using (auth.uid() is not null);
create policy vehicles_write on vehicles for all using (is_office_or_admin()) with check (is_office_or_admin());

create policy trip_types_select on trip_types for select using (auth.uid() is not null);
create policy trip_types_write on trip_types for all using (is_office_or_admin()) with check (is_office_or_admin());

create policy requesters_select on requesters for select using (auth.uid() is not null);
create policy requesters_write on requesters for all using (is_office_or_admin()) with check (is_office_or_admin());

create policy managers_select on managers for select using (auth.uid() is not null);
create policy managers_write on managers for all using (is_office_or_admin()) with check (is_office_or_admin());

create policy companies_select on companies for select using (auth.uid() is not null);
create policy companies_write on companies for all using (is_office_or_admin()) with check (is_office_or_admin());

-- trips: soforler sadece kendi seferlerini gorur/olusturur/gunceller;
-- ofis/yonetim tum seferleri gorur ve gunceller (sutun kisiti trigger'da)
create policy trips_select on trips
  for select using (driver_id = auth.uid() or is_office_or_admin());

create policy trips_insert on trips
  for insert with check (driver_id = auth.uid());

create policy trips_update on trips
  for update using (driver_id = auth.uid() or is_office_or_admin());

-- trip_stops: sahiplik ilgili seferin (trips) driver_id'sinden gelir
create policy trip_stops_select on trip_stops
  for select using (
    is_office_or_admin()
    or exists (select 1 from trips t where t.id = trip_stops.trip_id and t.driver_id = auth.uid())
  );

create policy trip_stops_insert on trip_stops
  for insert with check (
    exists (select 1 from trips t where t.id = trip_stops.trip_id and t.driver_id = auth.uid())
  );

create policy trip_stops_update on trip_stops
  for update using (
    is_office_or_admin()
    or exists (select 1 from trips t where t.id = trip_stops.trip_id and t.driver_id = auth.uid())
  );
