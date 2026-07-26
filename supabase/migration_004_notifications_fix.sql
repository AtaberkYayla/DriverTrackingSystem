-- migration_003'teki gmail_access_token()/send_notification_email() ilk
-- halinde bir sorun cikti: pg_net'in arka plan iscisi, AYNI transaction
-- icinde henuz commit edilmemis bir istegi goremiyor (Postgres MVCC'nin
-- dogal sonucu), bu yuzden "istek at ve cevabi bekle" deseni bir trigger/
-- fonksiyon icinde DOGRUDAN kullanilinca sonsuza kadar asiliyordu.
--
-- Cozum: token yenileme (nadir, ~saatte bir) icin dblink ile KISA SURELI
-- ayri bir baglanti acilip istek ORADA commit ediliyor, sonra ana
-- fonksiyon net._http_response'u dogrudan (dblink'siz) sorgulayip cevabi
-- bekliyor - bu noktada satir zaten commit edilmis oldugu icin gorunur.
-- Gonderim (send) tarafi ise zaten cevabi beklemeye ihtiyac duymuyor
-- (fire-and-forget yeterli), o kisim degismiyor, sadece basitlestiriliyor.

create extension if not exists dblink;

create table if not exists public.gmail_token_cache (
  id boolean primary key default true,
  access_token text,
  expires_at timestamptz,
  constraint gmail_token_cache_single_row check (id)
);

insert into public.gmail_token_cache (id) values (true) on conflict (id) do nothing;

create or replace function public.gmail_access_token()
 returns text
 language plpgsql
 security definer
 set search_path to public, net, vault, extensions
as $function$
declare
  v_access_token text;
  v_expires_at timestamptz;
  v_client_id text;
  v_client_secret text;
  v_refresh_token text;
  v_db_password text;
  v_conn text;
  v_request_id_text text;
  v_request_id bigint;
  v_resp net._http_response;
  v_body jsonb;
  v_expires_in int;
  v_deneme int := 0;
begin
  select access_token, expires_at into v_access_token, v_expires_at
  from public.gmail_token_cache where id = true;

  if v_access_token is not null and v_expires_at > now() + interval '2 minutes' then
    return v_access_token;
  end if;

  select decrypted_secret into v_client_id from vault.decrypted_secrets where name = 'gmail_client_id';
  select decrypted_secret into v_client_secret from vault.decrypted_secrets where name = 'gmail_client_secret';
  select decrypted_secret into v_refresh_token from vault.decrypted_secrets where name = 'gmail_refresh_token';
  select decrypted_secret into v_db_password from vault.decrypted_secrets where name = 'db_self_connect_password';

  if v_client_id is null or v_client_secret is null or v_refresh_token is null or v_db_password is null then
    raise exception 'Gmail OAuth kimlik bilgileri Vault icinde eksik';
  end if;

  v_conn := format(
    'host=aws-0-eu-central-1.pooler.supabase.com port=5432 dbname=postgres user=postgres.jrdwuhfoepgrwawzesgy password=%s',
    v_db_password
  );

  -- dblink'in tek-atimlik cagrisi kendi baglantisinda calisip biter bicer
  -- commit eder; boylece http_post'un ekledigi satir pg_net iscisine hemen
  -- gorunur olur (ana transaction'da beklesek asilir).
  select t.request_id into v_request_id_text
  from dblink(
    v_conn,
    format(
      'select net.http_post(%L, %L::jsonb)::text',
      'https://oauth2.googleapis.com/token',
      jsonb_build_object(
        'client_id', v_client_id,
        'client_secret', v_client_secret,
        'refresh_token', v_refresh_token,
        'grant_type', 'refresh_token'
      )
    )
  ) as t(request_id text);

  v_request_id := v_request_id_text::bigint;

  loop
    select * into v_resp from net._http_response where id = v_request_id;
    exit when found;
    v_deneme := v_deneme + 1;
    if v_deneme > 25 then
      raise exception 'Gmail token istegi zaman asimina ugradi';
    end if;
    perform pg_sleep(0.2);
  end loop;

  if v_resp.status_code is distinct from 200 then
    raise exception 'Gmail token istegi HTTP %: %', v_resp.status_code, v_resp.content;
  end if;

  v_body := v_resp.content::jsonb;
  v_access_token := v_body ->> 'access_token';
  v_expires_in := coalesce((v_body ->> 'expires_in')::int, 3600);

  if v_access_token is null then
    raise exception 'Gmail token yaniti beklenmedik: %', v_resp.content;
  end if;

  update public.gmail_token_cache
  set access_token = v_access_token, expires_at = now() + make_interval(secs => v_expires_in)
  where id = true;

  return v_access_token;
end;
$function$;

revoke execute on function public.gmail_access_token() from public, anon, authenticated;

-- Gonderim tarafi fire-and-forget kaliyor (cevabi beklemeye gerek yok);
-- pg_net isteği kuyruga ekler, ana transaction commit olunca isci onu
-- islemeye baslar.
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

  v_encoded := regexp_replace(
    translate(encode(convert_to(v_raw_message, 'UTF8'), 'base64'), '+/', '-_'),
    '\s', '', 'g'
  );

  perform net.http_post(
    url := 'https://gmail.googleapis.com/gmail/v1/users/me/messages/send',
    body := jsonb_build_object('raw', v_encoded),
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || p_access_token
    )
  );
end;
$function$;

revoke execute on function public.send_notification_email(text, text, text, text) from public, anon, authenticated;
