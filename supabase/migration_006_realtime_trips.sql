-- admin_web'in surucu uygulamasindan (driver_app) gelen sefer/durak
-- degisikliklerini (yeni sefer, firma giris/cikis, onay) 60 saniyelik
-- periyodik yenilemeyi beklemeden ANINDA gormesi icin 'trips' ve
-- 'trip_stops' tablolarini Supabase Realtime yayinina (publication) ekler.
-- Idempotent yazildi: bu migration birden fazla kez calistirilsa bile
-- (tablo zaten yayinda ise) hata vermez.
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'trips'
  ) then
    alter publication supabase_realtime add table public.trips;
  end if;

  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'trip_stops'
  ) then
    alter publication supabase_realtime add table public.trip_stops;
  end if;
end $$;
