-- ==========================================
-- OshudhSathi (ওষুধসাথী) Database Schema
-- MySQL 5.7+ / 8.0+
-- Charset: utf8mb4 (Bangla text support)
-- ==========================================

CREATE DATABASE IF NOT EXISTS oshudhsathi_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE oshudhsathi_db;

-- ─── Users ──────────────────────────────
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  phone VARCHAR(15) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  name VARCHAR(100) NOT NULL,
  date_of_birth DATE NULL,
  gender ENUM('male', 'female', 'other') NULL,
  blood_group ENUM('A+','A-','B+','B-','AB+','AB-','O+','O-') NULL,
  allergies TEXT NULL,
  chronic_conditions TEXT NULL,
  emergency_contact_name VARCHAR(100) NULL,
  emergency_contact_phone VARCHAR(15) NULL,
  profile_image_url VARCHAR(500) NULL,
  fcm_token VARCHAR(500) NULL,
  language ENUM('bn', 'en') DEFAULT 'bn',
  is_active TINYINT(1) DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_phone (phone)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── Admins ─────────────────────────────
CREATE TABLE IF NOT EXISTS admins (
  id INT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  name VARCHAR(100) NOT NULL,
  role ENUM('super_admin', 'admin', 'moderator') DEFAULT 'admin',
  is_active TINYINT(1) DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── OTP Codes ──────────────────────────
CREATE TABLE IF NOT EXISTS otp_codes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  phone VARCHAR(15) NOT NULL,
  code VARCHAR(6) NOT NULL,
  purpose ENUM('registration', 'login', 'reset_password') NOT NULL,
  expires_at DATETIME NOT NULL,
  is_used TINYINT(1) DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_phone_code (phone, code, is_used)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── Medicines (Master Data) ────────────
CREATE TABLE IF NOT EXISTS medicines (
  id INT AUTO_INCREMENT PRIMARY KEY,
  brand_name VARCHAR(200) NOT NULL,
  brand_name_bn VARCHAR(200) NULL,
  generic_name VARCHAR(200) NOT NULL,
  generic_name_bn VARCHAR(200) NULL,
  manufacturer VARCHAR(200) NULL,
  dosage_form ENUM('tablet','capsule','syrup','injection','cream','drops','inhaler','suppository') NULL,
  strength VARCHAR(100) NULL,
  unit_price DECIMAL(10,2) NULL,
  pack_size INT NULL,
  is_otc TINYINT(1) DEFAULT 0,
  category VARCHAR(100) NULL,
  indications TEXT NULL,
  indications_bn TEXT NULL,
  composition TEXT NULL,
  composition_bn TEXT NULL,
  side_effects TEXT NULL,
  instructions TEXT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY idx_unique_med (brand_name, strength, dosage_form, manufacturer),
  INDEX idx_brand (brand_name),
  INDEX idx_generic (generic_name),
  FULLTEXT idx_search (brand_name, generic_name, brand_name_bn)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── Drug Interactions ──────────────────
CREATE TABLE IF NOT EXISTS drug_interactions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  medicine_a_generic VARCHAR(200) NOT NULL,
  medicine_b_generic VARCHAR(200) NOT NULL,
  severity ENUM('mild', 'moderate', 'severe') NOT NULL,
  description TEXT NOT NULL,
  description_bn TEXT NULL,
  source VARCHAR(100) NULL,
  INDEX idx_med_a (medicine_a_generic),
  INDEX idx_med_b (medicine_b_generic)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── User Medicines ─────────────────────
CREATE TABLE IF NOT EXISTS user_medicines (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  medicine_id INT NULL,
  custom_name VARCHAR(200) NULL,
  dosage VARCHAR(100) NULL,
  frequency ENUM('once_daily','twice_daily','thrice_daily','weekly','as_needed') NOT NULL,
  times JSON NOT NULL,
  meal_instruction ENUM('before_meal','after_meal','any') DEFAULT 'any',
  start_date DATE NOT NULL,
  end_date DATE NULL,
  total_quantity INT NULL,
  remaining_quantity INT NULL,
  refill_alert_days INT DEFAULT 3,
  notes TEXT NULL,
  is_active TINYINT(1) DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (medicine_id) REFERENCES medicines(id) ON DELETE SET NULL,
  INDEX idx_user (user_id),
  INDEX idx_active (user_id, is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── Dose Logs ──────────────────────────
CREATE TABLE IF NOT EXISTS dose_logs (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_medicine_id INT NOT NULL,
  user_id INT NOT NULL,
  scheduled_time DATETIME NOT NULL,
  status ENUM('taken', 'missed', 'skipped', 'pending') NOT NULL DEFAULT 'pending',
  taken_at DATETIME NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_medicine_id) REFERENCES user_medicines(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_date (user_id, scheduled_time),
  INDEX idx_status (user_id, status, scheduled_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── Health Logs ────────────────────────
CREATE TABLE IF NOT EXISTS health_logs (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  type ENUM('blood_pressure', 'blood_sugar', 'weight') NOT NULL,
  value_1 DECIMAL(10,2) NOT NULL,
  value_2 DECIMAL(10,2) NULL,
  unit VARCHAR(20) NULL,
  meal_context ENUM('fasting', 'after_meal', 'random') NULL,
  notes TEXT NULL,
  recorded_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_type (user_id, type, recorded_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── Prescriptions ──────────────────────
CREATE TABLE IF NOT EXISTS prescriptions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  doctor_name VARCHAR(200) NULL,
  hospital_name VARCHAR(200) NULL,
  diagnosis TEXT NULL,
  visit_date DATE NOT NULL,
  next_visit_date DATE NULL,
  notes TEXT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── Prescription Images ────────────────
CREATE TABLE IF NOT EXISTS prescription_images (
  id INT AUTO_INCREMENT PRIMARY KEY,
  prescription_id INT NOT NULL,
  image_path VARCHAR(500) NOT NULL,
  sort_order INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (prescription_id) REFERENCES prescriptions(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── Family Links ───────────────────────
CREATE TABLE IF NOT EXISTS family_links (
  id INT AUTO_INCREMENT PRIMARY KEY,
  owner_id INT NOT NULL,
  viewer_id INT NULL,
  invite_code VARCHAR(50) UNIQUE NULL,
  relationship VARCHAR(50) NULL,
  status ENUM('pending', 'accepted', 'rejected') DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (viewer_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── Doctor Appointments ────────────────
CREATE TABLE IF NOT EXISTS doctor_appointments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  doctor_name VARCHAR(200) NOT NULL,
  hospital_name VARCHAR(200) NULL,
  phone VARCHAR(15) NULL,
  appointment_date DATETIME NOT NULL,
  reminder_days INT DEFAULT 7,
  notes TEXT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_date (user_id, appointment_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── Seed Default Admin ─────────────────
-- Password: admin123 (bcrypt hash)
INSERT INTO admins (email, password_hash, name, role) VALUES
  ('admin@oshudhsathi.com', '$2a$12$LJ3x5Mj5vQ5z5z5z5z5z5O5z5z5z5z5z5z5z5z5z5z5z5z5z5z5', 'Admin', 'super_admin')
ON DUPLICATE KEY UPDATE name = name;

-- ─── Seed Sample Medicines ──────────────
INSERT INTO medicines (brand_name, brand_name_bn, generic_name, manufacturer, dosage_form, strength, unit_price, category, instructions) VALUES
  ('Napa', 'নাপা', 'Paracetamol', 'Beximco Pharmaceuticals', 'tablet', '500mg', 1.50, 'analgesic', 'খাওয়ার পরে বা আগে যেকোনো সময় খাওয়া যায়'),
  ('Napa Extra', 'নাপা এক্সট্রা', 'Paracetamol + Caffeine', 'Beximco Pharmaceuticals', 'tablet', '500mg + 65mg', 3.00, 'analgesic', 'খাওয়ার পরে খাবেন'),
  ('Seclo', 'সেক্লো', 'Omeprazole', 'Incepta Pharmaceuticals', 'capsule', '20mg', 3.00, 'antacid', 'খালি পেটে সকালে খাবেন'),
  ('Losectil', 'লসেক্টিল', 'Omeprazole', 'Square Pharmaceuticals', 'capsule', '20mg', 8.00, 'antacid', 'খালি পেটে সকালে খাবেন'),
  ('Comet', 'কমেট', 'Metformin HCl', 'Aristopharma', 'tablet', '500mg', 3.50, 'antidiabetic', 'ভরা পেটে খাবেন'),
  ('Diafor', 'ডায়াফর', 'Metformin HCl', 'Healthcare Pharmaceuticals', 'tablet', '500mg', 2.50, 'antidiabetic', 'ভরা পেটে খাবেন'),
  ('Amlodipine', 'অ্যামলোডিপিন', 'Amlodipine', 'Square Pharmaceuticals', 'tablet', '5mg', 4.00, 'antihypertensive', 'প্রতিদিন একই সময়ে খাবেন'),
  ('Novasc', 'নোভাস্ক', 'Amlodipine', 'Novartis', 'tablet', '5mg', 12.00, 'antihypertensive', 'প্রতিদিন একই সময়ে খাবেন'),
  ('Sergel', 'সারজেল', 'Esomeprazole', 'Square Pharmaceuticals', 'capsule', '20mg', 10.00, 'antacid', 'খালি পেটে সকালে খাবেন'),
  ('Monas', 'মোনাস', 'Montelukast', 'Square Pharmaceuticals', 'tablet', '10mg', 12.00, 'antiallergic', 'রাতে ঘুমানোর আগে খাবেন')
ON DUPLICATE KEY UPDATE brand_name = brand_name;
