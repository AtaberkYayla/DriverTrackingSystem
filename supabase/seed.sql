-- Sofor Takip Sistemi - baslangic (seed) verisi
-- schema.sql calistirildiktan sonra bu dosyayi calistirin.
-- Buradaki arac/talep eden/yonetici isimleri mevcut Excel tablosundan alinmis
-- ornek verilerdir; web panelindeki master veri ekranlarindan duzenlenebilir/silinebilir.

insert into trip_types (code, label, requires_irsaliye, sira) values
  ('SATIN_ALMA_SEVKIYATI', 'Satin Alma Sevkiyati', true, 1),
  ('FASON_SEVKIYAT', 'Fason Sevkiyat', true, 2),
  ('URETIM_SEVKIYATI', 'Uretim Sevkiyati', true, 3),
  ('PERSONEL_ALIMI', 'Personel Alimi', false, 4),
  ('SGK', 'SGK', false, 5),
  ('ISKUR', 'Iskur', false, 6),
  ('BANKA', 'Banka', false, 7),
  ('KARGO', 'Kargo', false, 8),
  ('ARAC_TAMIRI', 'Arac Tamiri', false, 9),
  ('ARAC_BAKIM', 'Arac Bakim', false, 10),
  ('YEMEKHANE_MALZEME', 'Yemekhane Malzeme', false, 11),
  ('ARAC_VIZE', 'Arac Vize', false, 12),
  ('IKRAMLIK', 'Ikramlik', false, 13);

insert into vehicles (plaka) values
  ('45 BBR 668'), ('45 BBR 669'), ('45 BBR 670'), ('45 BBR 672'), ('45 BBR 673'),
  ('35 BBA 714'), ('35 BBB 899'), ('35 BBA 713'), ('35 BBA 712'), ('35 BBA 711'),
  ('35 BBA 710'), ('35 AZT 506'), ('35 ESM 95'), ('35 BTZ 274'), ('35 BTZ 275'),
  ('35 BTZ 276'), ('35 BTZ 281'), ('35 BUB 086'), ('35 BTZ 277'), ('35 BTZ 279'),
  ('35 BTZ 280'), ('35 BUD 397'), ('35 BTZ 278'), ('35 BUD 465'), ('35 BUD 474'),
  ('35 CBY 225'), ('35 CAS 760'), ('35 CYB 212'), ('35 CBY 218'), ('35 CBY 240'),
  ('35 CAS 890'), ('35 CAS 892'), ('35 CAS 893'), ('35 CAS 891'), ('34 GPL 593'),
  ('34 HFP 784'), ('34 HFP 916'), ('34 KIR 166'), ('34 KTJ 245'), ('34 KTJ 047'),
  ('34 GZL 323'), ('34 GZL 146'), ('34 GPF 478'), ('34 GZL 351'), ('34 HFP 795'),
  ('34 KSP 962'), ('34 KLF 899')
on conflict (plaka) do nothing;

insert into requesters (full_name) values
  ('Anil Bulut'), ('Koray Mete'), ('Sercan Karatas'), ('Kubra Ezgi Sen'),
  ('Hande Ahkacik'), ('Merve Akar'), ('Radina Mardanova'), ('Osman Bozcaarmutlu'),
  ('Umut Ozdemir'), ('Gokhan Ersan'), ('Serkan Topaloglu'), ('Umut Aksu'),
  ('Dilek Akbal'), ('Sengul Imrenci'), ('Nalan Kaynar'), ('Hakan Yavas'),
  ('Dilan Koksoy'), ('Esma Rana Imrenci Kocaturk'), ('Sahin Yilmaz'), ('Nisa Saribiyik'),
  ('Aslihan Unal'), ('Gulsah Yarimca'), ('Mert Ugras'), ('Caner Yesil'),
  ('Recep Cakanlar'), ('Ulas Ozbent'), ('Feyza Hilal Saglam'), ('Halil Ekmekci'),
  ('Barascan Caylak'), ('Furkan Yuksel'), ('Erdal Temel'), ('Ewa Magdalena Warachowska'),
  ('Mustafa Sarioglu'), ('Onurcan Tosun'), ('Sema Esmer Filiz'), ('Elcin Yegi'),
  ('Sergen Dogantli'), ('Siyar Adibelli'), ('Murat Coban');

insert into managers (full_name) values
  ('Oktay Yakut'), ('Anil Bulut'), ('Koray Mete'), ('Sercan Karatas'), ('Ali Ihsan Duran'),
  ('Levent Uzun');
