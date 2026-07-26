-- Migrasyon: seferleri (trips) tek satirlik yapidan, "sefer oturumu" (trips)
-- + "firma ziyareti" (trip_stops) iki tabloya ayirir.
-- Neden: Fabrika Cikis artik opsiyonel (sofor evden dogrudan firmaya
-- gidebilir), sefer sadece Fabrika Giris ile kapanir, ve araya fabrika
-- girmeden art arda birden fazla firma ziyareti yapilabilir.
--
-- Bu migrasyon eski `trips` tablosunu (ve icindeki test verilerini) siler.
-- profiles/vehicles/trip_types/requesters/managers/companies etkilenmez.
-- Supabase Dashboard > SQL Editor'de calistirin.

drop table if exists trips cascade;
drop function if exists enforce_trip_column_permissions();

-- ============================================================
-- SEFERLER (TRIPS) - OTURUM TABLOSU
-- ============================================================

create table trips (
  id uuid primary key default gen_random_uuid(),
  client_trip_id uuid not null unique,

  driver_id uuid not null references profiles (id),
  vehicle_id uuid not null references vehicles (id),
  tarih date not null default current_date,

  fabrika_cikis_at timestamptz,
  fabrika_giris_at timestamptz,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create unique index one_active_trip_per_driver
  on trips (driver_id)
  where fabrika_giris_at is null;

create index trips_driver_id_idx on trips (driver_id);
create index trips_tarih_idx on trips (tarih);

-- ============================================================
-- SEFER DURAKLARI (TRIP_STOPS) - HER FIRMA ZIYARETI
-- ============================================================

create table trip_stops (
  id uuid primary key default gen_random_uuid(),
  client_stop_id uuid not null unique,
  trip_id uuid not null references trips (id) on delete cascade,
  sira int not null default 1,

  firma_giris_at timestamptz not null,
  trip_type_id uuid references trip_types (id),
  requester_id uuid references requesters (id),
  cikis_nedeni text,
  gidilen_il text,
  gidilen_ilce text,
  gidilen_sirket_id uuid references companies (id),
  gidilen_sirket_free text,
  irsaliye_no text,

  firma_cikis_at timestamptz,

  onay_durumu onay_durumu not null default 'BEKLEMEDE',
  onaylayan_id uuid references profiles (id),
  onaylandi_at timestamptz,
  sefer_durumu sefer_durumu not null default 'DEVAM_EDIYOR',
  notlar text,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create unique index one_open_stop_per_trip
  on trip_stops (trip_id)
  where firma_cikis_at is null;

create index trip_stops_trip_id_idx on trip_stops (trip_id);
create index trip_stops_onay_durumu_idx on trip_stops (onay_durumu);

create trigger trips_set_updated_at
  before update on trips
  for each row execute function set_updated_at();

create trigger trip_stops_set_updated_at
  before update on trip_stops
  for each row execute function set_updated_at();

-- ============================================================
-- TRIP_STOPS: SUTUN BAZLI YAZMA KISITLAMASI
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

alter table trips enable row level security;
alter table trip_stops enable row level security;

create policy trips_select on trips
  for select using (driver_id = auth.uid() or is_office_or_admin());

create policy trips_insert on trips
  for insert with check (driver_id = auth.uid());

create policy trips_update on trips
  for update using (driver_id = auth.uid() or is_office_or_admin());

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
