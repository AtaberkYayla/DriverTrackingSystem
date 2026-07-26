-- Gelistirme asamasinda kullanilan test hesabini kaldirir.
-- auth.users silinince profiles satiri cascade ile otomatik silinir.
delete from auth.users where email = 'test@dedemmekatronik.com';
