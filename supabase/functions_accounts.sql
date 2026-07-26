-- Hesap yonetimi RPC'leri. Hepsi SECURITY DEFINER (sahibi postgres) oldugu
-- icin RLS'yi bypass eder (auth.users/auth.identities normal client'tan
-- hic erisilemez), yetki kontrolu fonksiyonun ICINDE yapiliyor. Boylece
-- admin_web hicbir zaman service_role/secret key gormeden, sadece kendi
-- oturum JWT'siyle supabase.rpc(...) cagirarak hesap olusturabiliyor.

create or replace function public.admin_list_accounts()
 returns table(
   id uuid,
   full_name text,
   role app_role,
   aktif boolean,
   email text,
   created_at timestamptz
 )
 language plpgsql
 security definer
 set search_path to 'public'
as $function$
begin
  if not is_manager_or_admin() then
    raise exception 'Bu islem icin yonetici veya admin yetkisi gerekiyor';
  end if;

  return query
    select p.id, p.full_name, p.role, p.aktif, u.email::text, p.created_at
    from public.profiles p
    join auth.users u on u.id = p.id
    order by p.role, p.full_name;
end;
$function$;

create or replace function public.admin_create_account(
  p_full_name text,
  p_email text,
  p_password text,
  p_role app_role
)
 returns uuid
 language plpgsql
 security definer
 set search_path to public, extensions
as $function$
declare
  v_new_id uuid;
  v_template_id uuid;
begin
  if not is_manager_or_admin() then
    raise exception 'Bu islem icin yonetici veya admin yetkisi gerekiyor';
  end if;

  if p_role in ('manager', 'admin') and auth_role() <> 'admin' then
    raise exception 'Yonetici veya admin hesabi olusturmak icin admin yetkisi gerekiyor';
  end if;

  v_new_id := gen_random_uuid();

  -- Yeni auth.users satiri, en eski/en kararli mevcut kullaniciyi sablon
  -- alarak SELECT ile kopyalaniyor (id/email/password/zaman damgalari
  -- degistirilerek). Ayni sutunlari literal INSERT...VALUES ile birebir
  -- ayarlayan bir denemede Supabase Auth (GoTrue) tarafinda sebebi tespit
  -- edilemeyen bir "Database error querying schema" hatasi gozlemlendi;
  -- var olan bir satiri sablon alarak kopyalamak guvenilir sekilde calisti.
  select id into v_template_id from auth.users order by created_at asc limit 1;

  insert into auth.users (
    instance_id, id, aud, role, email, encrypted_password,
    email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at,
    recovery_token, recovery_sent_at, email_change_token_new, email_change,
    email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data,
    is_super_admin, created_at, updated_at, phone, phone_confirmed_at,
    phone_change, phone_change_token, phone_change_sent_at,
    email_change_token_current, email_change_confirm_status, banned_until,
    reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous
  )
  select
    instance_id, v_new_id, aud, role, p_email, crypt(p_password, gen_salt('bf')),
    now(), invited_at, confirmation_token, confirmation_sent_at,
    recovery_token, recovery_sent_at, email_change_token_new, email_change,
    email_change_sent_at, null, raw_app_meta_data, raw_user_meta_data,
    is_super_admin, now(), now(), phone, phone_confirmed_at,
    phone_change, phone_change_token, phone_change_sent_at,
    email_change_token_current, email_change_confirm_status, banned_until,
    reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous
  from auth.users where id = v_template_id;

  insert into auth.identities (
    id, user_id, provider_id, provider, identity_data, last_sign_in_at, created_at, updated_at
  )
  select gen_random_uuid(), v_new_id, v_new_id::text, provider,
    jsonb_build_object('sub', v_new_id::text, 'email', p_email),
    now(), now(), now()
  from auth.identities where user_id = v_template_id and provider = 'email';

  insert into public.profiles (id, full_name, role)
  values (v_new_id, p_full_name, p_role);

  return v_new_id;
end;
$function$;

create or replace function public.admin_update_account(
  p_user_id uuid,
  p_full_name text default null,
  p_email text default null,
  p_password text default null,
  p_role app_role default null,
  p_aktif boolean default null
)
 returns void
 language plpgsql
 security definer
 set search_path to public, extensions
as $function$
declare
  v_current_role app_role;
begin
  if not is_manager_or_admin() then
    raise exception 'Bu islem icin yonetici veya admin yetkisi gerekiyor';
  end if;

  select role into v_current_role from public.profiles where id = p_user_id;
  if v_current_role is null then
    raise exception 'Hesap bulunamadi';
  end if;

  if (v_current_role in ('manager', 'admin') or p_role in ('manager', 'admin'))
     and auth_role() <> 'admin' then
    raise exception 'Yonetici veya admin hesaplarini sadece admin duzenleyebilir';
  end if;

  update auth.users set
    email = coalesce(p_email, email),
    encrypted_password = case when p_password is not null
      then crypt(p_password, gen_salt('bf')) else encrypted_password end,
    updated_at = now()
  where id = p_user_id;

  if p_email is not null then
    update auth.identities set
      identity_data = jsonb_set(identity_data, '{email}', to_jsonb(p_email)),
      updated_at = now()
    where user_id = p_user_id and provider = 'email';
  end if;

  update public.profiles set
    full_name = coalesce(p_full_name, full_name),
    role = coalesce(p_role, role),
    aktif = coalesce(p_aktif, aktif)
  where id = p_user_id;
end;
$function$;
