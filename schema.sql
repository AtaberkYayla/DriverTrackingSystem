-- Dedem Mekatronik Sofor Takip Sistemi - MySQL semasi (Supabase/Postgres'in yerini alir).
-- phpMyAdmin'den import edilecek. UTF8MB4, InnoDB (FK destegi icin).

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- Eski profiles + auth.users ayrimi tek tabloda birlesti; giris artik
-- sentetik e-posta yerine gercek bir username sutunuyla yapiliyor.
CREATE TABLE IF NOT EXISTS users (
  id CHAR(36) NOT NULL PRIMARY KEY,
  username VARCHAR(64) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  full_name VARCHAR(255) NOT NULL,
  role ENUM('driver','office','manager','admin') NOT NULL,
  aktif TINYINT(1) NOT NULL DEFAULT 1,
  notification_email VARCHAR(255) NULL,
  email_bildirim_aktif TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS auth_tokens (
  token_hash CHAR(64) NOT NULL PRIMARY KEY,
  user_id CHAR(36) NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  last_used_at DATETIME NULL,
  expires_at DATETIME NOT NULL,
  CONSTRAINT fk_auth_tokens_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_auth_tokens_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS vehicles (
  id CHAR(36) NOT NULL PRIMARY KEY,
  plaka VARCHAR(20) NOT NULL,
  aciklama VARCHAR(255) NULL,
  aktif TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS trip_types (
  id CHAR(36) NOT NULL PRIMARY KEY,
  code VARCHAR(64) NOT NULL,
  label VARCHAR(255) NOT NULL,
  requires_irsaliye TINYINT(1) NOT NULL DEFAULT 0,
  sira INT NOT NULL DEFAULT 0,
  aktif TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS companies (
  id CHAR(36) NOT NULL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  sehir VARCHAR(255) NULL,
  aktif TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Talep Eden'in (Onay Verici) giris hesabi yoktur; onay/bildirim maili
-- dogrudan `email`e gonderilir, mailin icindeki tek-tikla "Onayla" linki
-- approval_tokens tablosundaki bir token ile calisir (bkz. approvals_approve.php).
CREATE TABLE IF NOT EXISTS requesters (
  id CHAR(36) NOT NULL PRIMARY KEY,
  full_name VARCHAR(255) NOT NULL,
  aktif TINYINT(1) NOT NULL DEFAULT 1,
  email VARCHAR(255) NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- tarih kasitli olarak VARCHAR(10) ('YYYY-MM-DD') - Dart tarafi zaten bunu
-- DateTime degil duz string olarak tutup lexicografik karsilastiriyor.
CREATE TABLE IF NOT EXISTS trips (
  id CHAR(36) NOT NULL PRIMARY KEY,
  client_trip_id VARCHAR(64) NOT NULL UNIQUE,
  driver_id CHAR(36) NOT NULL,
  vehicle_id CHAR(36) NOT NULL,
  tarih VARCHAR(10) NOT NULL,
  fabrika_cikis_at DATETIME NULL,
  fabrika_giris_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_trips_driver FOREIGN KEY (driver_id) REFERENCES users(id),
  CONSTRAINT fk_trips_vehicle FOREIGN KEY (vehicle_id) REFERENCES vehicles(id),
  INDEX idx_trips_driver (driver_id),
  INDEX idx_trips_tarih (tarih)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS trip_stops (
  id CHAR(36) NOT NULL PRIMARY KEY,
  client_stop_id VARCHAR(64) NOT NULL UNIQUE,
  trip_id CHAR(36) NOT NULL,
  sira INT NOT NULL DEFAULT 0,
  firma_giris_at DATETIME NOT NULL,
  trip_type_id CHAR(36) NULL,
  requester_id CHAR(36) NULL,
  cikis_nedeni TEXT NULL,
  gidilen_il VARCHAR(100) NULL,
  gidilen_ilce VARCHAR(100) NULL,
  gidilen_sirket_id CHAR(36) NULL,
  gidilen_sirket_free VARCHAR(255) NULL,
  irsaliye_no_giris VARCHAR(100) NULL,
  irsaliye_no_cikis VARCHAR(100) NULL,
  firma_cikis_at DATETIME NULL,
  onay_durumu ENUM('BEKLEMEDE','ONAYLANDI') NOT NULL DEFAULT 'BEKLEMEDE',
  onaylayan_id CHAR(36) NULL,
  onaylandi_at DATETIME NULL,
  sefer_durumu ENUM('DEVAM_EDIYOR','BASARILI','BASARISIZ') NOT NULL DEFAULT 'DEVAM_EDIYOR',
  notlar TEXT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_stops_trip FOREIGN KEY (trip_id) REFERENCES trips(id) ON DELETE CASCADE,
  CONSTRAINT fk_stops_requester FOREIGN KEY (requester_id) REFERENCES requesters(id),
  CONSTRAINT fk_stops_trip_type FOREIGN KEY (trip_type_id) REFERENCES trip_types(id),
  CONSTRAINT fk_stops_company FOREIGN KEY (gidilen_sirket_id) REFERENCES companies(id),
  CONSTRAINT fk_stops_onaylayan FOREIGN KEY (onaylayan_id) REFERENCES users(id),
  INDEX idx_stops_trip (trip_id),
  INDEX idx_stops_requester (requester_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tek satirlik (id her zaman 1) global SMTP yapilandirmasi - Master Veri
-- Yonetimi > Mail Ayarlari ekranindan admin tarafindan girilir. Sifre duz
-- metin tutulur (config.php'deki DB sifresiyle ayni guven seviyesinde);
-- bu tablo da .htaccess'teki gibi dogrudan web erisimine kapali degildir
-- ama zaten API'nin GET yaniti sifreyi hic geri dondurmez (bkz. mail_settings.php).
CREATE TABLE IF NOT EXISTS mail_settings (
  id TINYINT NOT NULL PRIMARY KEY,
  smtp_host VARCHAR(255) NULL,
  smtp_port INT NULL,
  use_ssl TINYINT(1) NOT NULL DEFAULT 1,
  from_email VARCHAR(255) NULL,
  from_name VARCHAR(255) NULL,
  smtp_user VARCHAR(255) NULL,
  smtp_password VARCHAR(255) NULL,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS notification_outbox (
  id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  to_email VARCHAR(255) NOT NULL,
  subject VARCHAR(500) NOT NULL,
  body TEXT NOT NULL,
  is_html TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  sent_at DATETIME NULL,
  attempt_count INT NOT NULL DEFAULT 0,
  last_error TEXT NULL,
  INDEX idx_outbox_pending (sent_at, attempt_count)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Talep Eden'in hesabi olmadan, mailindeki "Onayla" linkine tikladiginda
-- ilgili durak (trip_stop) onaylanir. Token tek kullanimlik (used_at) ve
-- sureli (expires_at); birden fazla bildirimde (girisi/cikisi) her seferinde
-- yeni bir token uretilir, herhangi biriyle onaylamak yeterlidir.
CREATE TABLE IF NOT EXISTS approval_tokens (
  token_hash CHAR(64) NOT NULL PRIMARY KEY,
  stop_id CHAR(36) NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  expires_at DATETIME NOT NULL,
  used_at DATETIME NULL,
  CONSTRAINT fk_approval_tokens_stop FOREIGN KEY (stop_id) REFERENCES trip_stops(id) ON DELETE CASCADE,
  INDEX idx_approval_tokens_stop (stop_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS = 1;
