-- Yeni rol: manager ("yonetici"). Office'in yaptigi her seyi yapabilir,
-- ustune kullanici yonetimi + master data duzenleme/silme + sefer
-- duzeltme/silme yetkisi var. Bu deger kendi basina/autocommit calismali,
-- bu yuzden dosyanin en basinda ve psql'de BEGIN/COMMIT'e sarilmadan
-- calistirilmali (asagidaki diger statement'lar ayni oturumda calisabilir
-- cunku her biri ayri ayri commit olur).
alter type app_role add value if not exists 'manager';

-- Sadece manager/admin: kullanici yonetimi, master data duzenleme/silme,
-- sefer/durak duzeltme+silme gibi "birinin hatasini duzeltme" islemleri.
create or replace function public.is_manager_or_admin()
 returns boolean
 language sql
 stable security definer
 set search_path to 'public'
as $function$
  select auth_role() in ('manager', 'admin');
$function$;

-- Yonetici artik office'in yaptigi her seyi de yapabilsin diye genisletildi.
-- Bu fonksiyonu kullanan tum RLS politikalari tek yerden guncellenmis olur.
create or replace function public.is_office_or_admin()
 returns boolean
 language sql
 stable security definer
 set search_path to 'public'
as $function$
  select auth_role() in ('office', 'manager', 'admin');
$function$;

-- Duz office artik sefer detaylarini (soforden gelen alanlar) degistiremez;
-- bu artik sadece manager/admin'e acik. Sofor branch'i degismedi.
create or replace function public.enforce_trip_stop_column_permissions()
 returns trigger
 language plpgsql
as $function$
begin
  if auth_role() = 'driver' then
    if new.onay_durumu is distinct from old.onay_durumu
      or new.onaylayan_id is distinct from old.onaylayan_id
      or new.onaylandi_at is distinct from old.onaylandi_at
      or new.sefer_durumu is distinct from old.sefer_durumu
      or new.notlar is distinct from old.notlar then
      raise exception 'Soforler onay/degerlendirme alanlarini degistiremez';
    end if;
  elsif auth_role() = 'office' then
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
      raise exception 'Onay verici sefer detaylarini degistiremez, sadece yonetici/admin degistirebilir';
    end if;
  end if;
  return new;
end;
$function$;

-- Master data yazma (ekleme dahil) artik sadece manager/admin.
drop policy if exists vehicles_write on public.vehicles;
create policy vehicles_write on public.vehicles for all
  using (is_manager_or_admin()) with check (is_manager_or_admin());

drop policy if exists companies_write on public.companies;
create policy companies_write on public.companies for all
  using (is_manager_or_admin()) with check (is_manager_or_admin());

drop policy if exists trip_types_write on public.trip_types;
create policy trip_types_write on public.trip_types for all
  using (is_manager_or_admin()) with check (is_manager_or_admin());

drop policy if exists requesters_write on public.requesters;
create policy requesters_write on public.requesters for all
  using (is_manager_or_admin()) with check (is_manager_or_admin());

drop policy if exists managers_write on public.managers;
create policy managers_write on public.managers for all
  using (is_manager_or_admin()) with check (is_manager_or_admin());

-- trips: office bugune kadar zaten trips'i hic guncellemiyordu (sadece
-- onay islemleri trip_stops uzerinden), bu yuzden bu daralma mevcut akisi
-- bozmuyor.
drop policy if exists trips_update on public.trips;
create policy trips_update on public.trips for update
  using (driver_id = auth.uid() or is_manager_or_admin());

-- Hesap yonetimi (yeni profil olusturma / baskasinin profilini duzenleme)
-- artik sadece manager/admin.
drop policy if exists profiles_office_insert on public.profiles;
create policy profiles_office_insert on public.profiles for insert
  with check (is_manager_or_admin());

drop policy if exists profiles_update_own on public.profiles;
create policy profiles_update_own on public.profiles for update
  using (id = auth.uid() or is_manager_or_admin());

-- Su ana kadar hic DELETE politikasi yoktu (varsayilan olarak engelli).
-- Yanlislikla olusturulmus/mukerrer sefer ve duraklarin manager/admin
-- tarafindan tamamen silinebilmesi icin.
drop policy if exists trips_delete on public.trips;
create policy trips_delete on public.trips for delete
  using (is_manager_or_admin());

drop policy if exists trip_stops_delete on public.trip_stops;
create policy trip_stops_delete on public.trip_stops for delete
  using (is_manager_or_admin());
