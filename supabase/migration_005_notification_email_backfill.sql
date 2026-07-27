-- "Profilim" ekranindaki "Bildirim E-postasi" alani, mevcut hesaplarin
-- coğunda hic doldurulmadigi icin bos gorunuyordu; bu da kullaniciya
-- "hicbir e-posta kayitli degil, gercek olani girin" gibi yanlis bir izlenim
-- veriyordu. Gercekte her hesabin zaten bir giris e-postasi var
-- (auth.users.email, ör. ad.soyad@dedemmekatronik.com) - bu artik gecerli/
-- gercek e-posta olarak kabul edilip notification_email alanina kopyalanir.
-- Kullanici dilerse bunu daha sonra "Profilim" ekranindan kendi kisisel
-- e-postasiyla degistirebilir (bu alan zaten serbestce duzenlenebilir).
update public.profiles p
set notification_email = u.email
from auth.users u
where p.id = u.id
  and p.notification_email is null;
