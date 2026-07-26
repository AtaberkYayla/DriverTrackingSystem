-- Sistem admin hesabi + 39 "Onay Verecek Kisi" icin admin_web giris
-- hesaplari. Ayni teknik: auth.users/auth.identities dogrudan insert
-- (gercek mail atilmiyor, sadece Supabase Auth'un login mekanizmasi
-- kullaniliyor). Sifre hepsinde DedemMekatronik123!.
-- 4 kisi (Anil Bulut, Koray Mete, Sercan Karatas, Kubra Ezgi Sen) manager
-- (yonetici) rolunde, digerleri office (onay verici) rolunde.
do $$
declare
  v_password text := 'DedemMekatronik123!';
  v_rows text[][] := array[
    array['Sistem Yöneticisi', 'admin@dedemmekatronik.com', 'admin'],
    array['Anıl Bulut', 'anil.bulut@dedemmekatronik.com', 'manager'],
    array['Koray Mete', 'koray.mete@dedemmekatronik.com', 'manager'],
    array['Sercan Karataş', 'sercan.karatas@dedemmekatronik.com', 'manager'],
    array['Kübra Ezgi Şen', 'kubra.sen@dedemmekatronik.com', 'manager'],
    array['Hande Ankacık', 'hande.ankacik@dedemmekatronik.com', 'office'],
    array['Merve Akar', 'merve.akar@dedemmekatronik.com', 'office'],
    array['Radina Mardanova', 'radina.mardanova@dedemmekatronik.com', 'office'],
    array['Osman Bozcaarmutlu', 'osman.bozcaarmutlu@dedemmekatronik.com', 'office'],
    array['Umut Özdemir', 'umut.ozdemir@dedemmekatronik.com', 'office'],
    array['Gökhan Ersan', 'gokhan.ersan@dedemmekatronik.com', 'office'],
    array['Serkan Topaloğlu', 'serkan.topaloglu@dedemmekatronik.com', 'office'],
    array['Umut Aksu', 'umut.aksu@dedemmekatronik.com', 'office'],
    array['Dilek Akbal', 'dilek.akbal@dedemmekatronik.com', 'office'],
    array['Şengül İmrenci', 'sengul.imrenci@dedemmekatronik.com', 'office'],
    array['Nalan Kaynar', 'nalan.kaynar@dedemmekatronik.com', 'office'],
    array['Hakan Yavas', 'hakan.yavas@dedemmekatronik.com', 'office'],
    array['Dilan Koksoy', 'dilan.koksoy@dedemmekatronik.com', 'office'],
    array['Esma Rana İmrenci Kocatürk', 'esma.kocaturk@dedemmekatronik.com', 'office'],
    array['Şahin Yılmaz', 'sahin.yilmaz@dedemmekatronik.com', 'office'],
    array['Nisa Sarıbıyık', 'nisa.saribiyik@dedemmekatronik.com', 'office'],
    array['Aslıhan Ünal', 'aslihan.unal@dedemmekatronik.com', 'office'],
    array['Gülşah Yarımca', 'gulsah.yarimca@dedemmekatronik.com', 'office'],
    array['Mert Uğraş', 'mert.ugras@dedemmekatronik.com', 'office'],
    array['Caner Yeşil', 'caner.yesil@dedemmekatronik.com', 'office'],
    array['Recep Çakanlar', 'recep.cakanlar@dedemmekatronik.com', 'office'],
    array['Ulaş Özbent', 'ulas.ozbent@dedemmekatronik.com', 'office'],
    array['Feyza Hilal Sağlam', 'feyza.saglam@dedemmekatronik.com', 'office'],
    array['Halil Ekmekçi', 'halil.ekmekci@dedemmekatronik.com', 'office'],
    array['Barışcan Çaylak', 'bariscan.caylak@dedemmekatronik.com', 'office'],
    array['Furkan Yüksel', 'furkan.yuksel@dedemmekatronik.com', 'office'],
    array['Erdal Temel', 'erdal.temel@dedemmekatronik.com', 'office'],
    array['Ewa Magdalena Warachowska', 'ewa.warachowska@dedemmekatronik.com', 'office'],
    array['Mustafa Sarıoğlu', 'mustafa.sarioglu@dedemmekatronik.com', 'office'],
    array['Onurcan Tosun', 'onurcan.tosun@dedemmekatronik.com', 'office'],
    array['Sema Esmer Filiz', 'sema.filiz@dedemmekatronik.com', 'office'],
    array['Elçin Yeği', 'elcin.yegi@dedemmekatronik.com', 'office'],
    array['Sergen Doğanlı', 'sergen.doganli@dedemmekatronik.com', 'office'],
    array['Şiyar Adıbelli', 'siyar.adibelli@dedemmekatronik.com', 'office'],
    array['Murat Çoban', 'murat.coban@dedemmekatronik.com', 'office']
  ];
  v_row text[];
  v_new_id uuid;
  v_template_id uuid;
begin
  -- Yeni satirlar, en eski (halihazirda calistigi dogrulanmis) kullaniciyi
  -- sablon alarak SELECT ile kopyalaniyor. Literal INSERT...VALUES ile
  -- birebir ayni sutun degerleriyle olusturulan satirlarda Supabase Auth
  -- (GoTrue) tarafinda sebebi tespit edilemeyen bir "Database error
  -- querying schema" login hatasi gozlemlendi; mevcut calisan bir satiri
  -- sablon alarak kopyalamak guvenilir sekilde calisti.
  select id into v_template_id from auth.users order by created_at asc limit 1;

  foreach v_row slice 1 in array v_rows loop
    if exists (select 1 from auth.users where email = v_row[2]) then
      continue;
    end if;

    v_new_id := gen_random_uuid();

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
      instance_id, v_new_id, aud, role, v_row[2], crypt(v_password, gen_salt('bf')),
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
      jsonb_build_object('sub', v_new_id::text, 'email', v_row[2]),
      now(), now(), now()
    from auth.identities where user_id = v_template_id and provider = 'email';

    insert into public.profiles (id, full_name, role)
    values (v_new_id, v_row[1], v_row[3]::app_role);
  end loop;
end;
$$;
