-- TEST amacli yonetici (admin) kullanicisi olusturur.
-- Supabase Dashboard > SQL Editor'de calistirin.
-- E-posta: test@dedemmekatronik.com   Sifre: Test1234!
-- Istediginiz e-posta/sifreyi asagida degistirebilirsiniz.

do $$
declare
  new_user_id uuid := gen_random_uuid();
  test_email text := 'test@dedemmekatronik.com';
  test_password text := 'Test1234!';
begin
  insert into auth.users (
    instance_id, id, aud, role, email, encrypted_password,
    email_confirmed_at, recovery_sent_at, last_sign_in_at,
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
    confirmation_token, email_change, email_change_token_new, recovery_token
  ) values (
    '00000000-0000-0000-0000-000000000000',
    new_user_id,
    'authenticated',
    'authenticated',
    test_email,
    crypt(test_password, gen_salt('bf')),
    now(), now(), now(),
    '{"provider":"email","providers":["email"]}',
    '{}',
    now(), now(),
    '', '', '', ''
  );

  insert into auth.identities (
    id, user_id, provider_id, identity_data, provider, last_sign_in_at, created_at, updated_at
  ) values (
    gen_random_uuid(),
    new_user_id,
    new_user_id::text,
    format('{"sub":"%s","email":"%s"}', new_user_id::text, test_email)::jsonb,
    'email',
    now(), now(), now()
  );

  insert into public.profiles (id, full_name, role)
  values (new_user_id, 'Test Yonetici', 'admin');
end $$;
