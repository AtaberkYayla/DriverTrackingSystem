-- Sofor Firma Giris/Cikis yaptiginda ilgili onay verici + yonetici/admin'e
-- gercek e-posta bildirimi gonderir. pg_net (acik kaynak Postgres extension,
-- Supabase'e ozgu degil, herhangi bir kendi-barindirilan Postgres'e de
-- kurulabilir) ile Gmail API'yi HTTP uzerinden OAuth2 ile cagirir; boylece
-- ucuncu parti bir email sirketine ihtiyac olmuyor, gonderen gercekten bir
-- Gmail hesabi oluyor ve ileride kendi sunuculara tasininca ayni kod
-- (sadece CREATE EXTENSION pg_net ile) aynen calismaya devam eder.

alter table public.profiles add column if not exists notification_email text;
alter table public.profiles add column if not exists email_bildirim_aktif boolean not null default true;

alter table public.requesters add column if not exists profile_id uuid references public.profiles(id);

-- Tek seferlik backfill: requesters ve profiles ayni isimlerle (39/39)
-- olusturulmustu, bu yuzden full_name eslesmesi guvenilir.
update public.requesters r
set profile_id = p.id
from public.profiles p
where p.full_name = r.full_name
  and r.profile_id is null;

create extension if not exists pg_net;

-- Gmail OAuth kimlik bilgileri Vault'ta saklanir (supabase_vault zaten
-- kurulu). Degerler asagidaki gibi ayri bir adimda eklenir (bu dosyada
-- gercek client_id/secret/refresh_token YOK):
--   select vault.create_secret('<deger>', 'gmail_client_id', 'Gmail OAuth client id');
--   select vault.create_secret('<deger>', 'gmail_client_secret', 'Gmail OAuth client secret');
--   select vault.create_secret('<deger>', 'gmail_refresh_token', 'Gmail OAuth refresh token');
--   select vault.create_secret('<deger>', 'gmail_from_email', 'Bildirim gonderen Gmail adresi');

create or replace function public.gmail_access_token()
 returns text
 language plpgsql
 security definer
 set search_path to public, net, vault, extensions
as $function$
declare
  v_client_id text;
  v_client_secret text;
  v_refresh_token text;
  v_request_id bigint;
  v_result net.http_response_result;
  v_response jsonb;
begin
  select decrypted_secret into v_client_id from vault.decrypted_secrets where name = 'gmail_client_id';
  select decrypted_secret into v_client_secret from vault.decrypted_secrets where name = 'gmail_client_secret';
  select decrypted_secret into v_refresh_token from vault.decrypted_secrets where name = 'gmail_refresh_token';

  if v_client_id is null or v_client_secret is null or v_refresh_token is null then
    raise exception 'Gmail OAuth kimlik bilgileri Vault icinde bulunamadi';
  end if;

  select net.http_post(
    url := 'https://oauth2.googleapis.com/token',
    body := jsonb_build_object(
      'client_id', v_client_id,
      'client_secret', v_client_secret,
      'refresh_token', v_refresh_token,
      'grant_type', 'refresh_token'
    )
  ) into v_request_id;

  v_result := net._http_collect_response(v_request_id, false);
  if v_result.status <> 'SUCCESS' then
    raise exception 'Gmail token istegi basarisiz: %', v_result.message;
  end if;
  if v_result.response.status_code <> 200 then
    raise exception 'Gmail token istegi HTTP %: %', v_result.response.status_code, v_result.response.body;
  end if;

  v_response := v_result.response.body::jsonb;
  return v_response ->> 'access_token';
end;
$function$;

revoke execute on function public.gmail_access_token() from public, anon, authenticated;

create or replace function public.send_notification_email(
  p_access_token text,
  p_to_email text,
  p_subject text,
  p_body text
)
 returns void
 language plpgsql
 security definer
 set search_path to public, net, vault, extensions
as $function$
declare
  v_from_email text;
  v_raw_message text;
  v_encoded text;
  v_request_id bigint;
  v_result net.http_response_result;
begin
  select decrypted_secret into v_from_email from vault.decrypted_secrets where name = 'gmail_from_email';
  if v_from_email is null then
    raise exception 'gmail_from_email Vault icinde bulunamadi';
  end if;

  v_raw_message :=
    'From: ' || v_from_email || E'\r\n' ||
    'To: ' || p_to_email || E'\r\n' ||
    'Subject: =?UTF-8?B?' || encode(convert_to(p_subject, 'UTF8'), 'base64') || '?=' || E'\r\n' ||
    'MIME-Version: 1.0' || E'\r\n' ||
    'Content-Type: text/plain; charset="UTF-8"' || E'\r\n\r\n' ||
    p_body;

  -- Gmail API 'raw' alani base64url ister (standart base64'ten farkli:
  -- +/- yerine -_ ve satir sonu/bosluk olmamali).
  v_encoded := regexp_replace(
    translate(encode(convert_to(v_raw_message, 'UTF8'), 'base64'), '+/', '-_'),
    '\s', '', 'g'
  );

  select net.http_post(
    url := 'https://gmail.googleapis.com/gmail/v1/users/me/messages/send',
    body := jsonb_build_object('raw', v_encoded),
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || p_access_token
    )
  ) into v_request_id;

  v_result := net._http_collect_response(v_request_id, false);
  if v_result.status <> 'SUCCESS' or v_result.response.status_code >= 300 then
    raise warning 'Gmail gonderim hatasi (%): %', p_to_email, coalesce(v_result.response.body, v_result.message);
  end if;
end;
$function$;

revoke execute on function public.send_notification_email(text, text, text, text) from public, anon, authenticated;

-- Sofor Firma Girisi/Cikisi yaptiginda ilgili onay verici + tercih eden
-- yonetici/admin'lere mail atar. Mail gonderimi basarisiz olsa bile
-- soforun islemi (trip_stop insert/update) ASLA engellenmemeli; bu yuzden
-- tum mantik exception-guard icinde.
create or replace function public.notify_trip_stop_event()
 returns trigger
 language plpgsql
 security definer
 set search_path to public
as $function$
declare
  v_islem text;
  v_sofor text;
  v_plaka text;
  v_gidilen text;
  v_konu text;
  v_govde text;
  v_access_token text;
  v_alici record;
  v_gonderilenler uuid[] := '{}';
begin
  begin
    v_islem := case when TG_OP = 'INSERT' then 'Firma Girişi' else 'Firma Çıkışı' end;

    select p.full_name, v.plaka into v_sofor, v_plaka
    from public.trips t
    join public.profiles p on p.id = t.driver_id
    join public.vehicles v on v.id = t.vehicle_id
    where t.id = new.trip_id;

    v_gidilen := coalesce(
      nullif(trim(both ' / ' from coalesce(new.gidilen_il, '') || ' / ' || coalesce(new.gidilen_ilce, '')), ''),
      new.gidilen_sirket_free,
      '-'
    );

    v_konu := v_islem || ' - ' || coalesce(v_sofor, '-') || ' - ' || coalesce(v_plaka, '-');
    v_govde := 'Şoför: ' || coalesce(v_sofor, '-') || E'\n' ||
               'Plaka: ' || coalesce(v_plaka, '-') || E'\n' ||
               'İşlem: ' || v_islem || E'\n' ||
               'Gidilen Yer: ' || v_gidilen || E'\n' ||
               'Zaman: ' || to_char(now(), 'DD.MM.YYYY HH24:MI');

    v_access_token := public.gmail_access_token();

    -- Alici 1: bu duragin "Talep Eden Kisi"sine karsilik gelen hesap.
    for v_alici in
      select p.id, p.notification_email
      from public.requesters r
      join public.profiles p on p.id = r.profile_id
      where r.id = new.requester_id
        and p.role in ('office', 'manager', 'admin')
        and p.notification_email is not null
    loop
      perform public.send_notification_email(v_access_token, v_alici.notification_email, v_konu, v_govde);
      v_gonderilenler := array_append(v_gonderilenler, v_alici.id);
    end loop;

    -- Alici 2: bildirim tercihi acik olan tum yonetici/admin'ler.
    for v_alici in
      select p.id, p.notification_email
      from public.profiles p
      where p.role in ('manager', 'admin')
        and p.email_bildirim_aktif = true
        and p.notification_email is not null
        and not (p.id = any(v_gonderilenler))
    loop
      perform public.send_notification_email(v_access_token, v_alici.notification_email, v_konu, v_govde);
    end loop;
  exception when others then
    raise warning 'notify_trip_stop_event basarisiz: %', sqlerrm;
  end;

  return new;
end;
$function$;

drop trigger if exists trip_stops_notify_insert on public.trip_stops;
create trigger trip_stops_notify_insert
  after insert on public.trip_stops
  for each row execute function public.notify_trip_stop_event();

drop trigger if exists trip_stops_notify_update on public.trip_stops;
create trigger trip_stops_notify_update
  after update of firma_cikis_at on public.trip_stops
  for each row
  when (old.firma_cikis_at is null and new.firma_cikis_at is not null)
  execute function public.notify_trip_stop_event();
