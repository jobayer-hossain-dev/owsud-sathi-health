const bcrypt = require('bcryptjs');
const { pool } = require('../config/database');

async function seedDefaultUsers() {
  try {
    // 1. Target User requested by client
    const targetPhone = '01619504428';
    const targetPassword = 'Jovayer1234';
    const targetHash = await bcrypt.hash(targetPassword, 12);
    const targetName = 'Jobayer Hossain';

    await pool.execute(
      `INSERT INTO users (phone, password_hash, name, blood_group, chronic_conditions, emergency_contact_name, emergency_contact_phone)
       VALUES (?, ?, ?, 'B+', 'ডায়াবেটিস, উচ্চ রক্তচাপ', 'জরুরি ফ্রেন্ড', '01600000000')
       ON DUPLICATE KEY UPDATE 
          password_hash = VALUES(password_hash),
          name = VALUES(name),
          is_active = 1`,
      [targetPhone, targetHash, targetName]
    );

    // 2. Secondary Demo User
    const demoPhone = '01712345678';
    const demoPassword = 'Password123!';
    const demoHash = await bcrypt.hash(demoPassword, 12);
    const demoName = 'মো. রফিকুল ইসলাম';

    await pool.execute(
      `INSERT INTO users (phone, password_hash, name, blood_group, chronic_conditions, emergency_contact_name, emergency_contact_phone)
       VALUES (?, ?, ?, 'B+', 'ডায়াবেটিস, উচ্চ রক্তচাপ', 'সাব্বির আহমেদ (ছেলে)', '01812345678')
       ON DUPLICATE KEY UPDATE 
          password_hash = VALUES(password_hash),
          name = VALUES(name),
          is_active = 1`,
      [demoPhone, demoHash, demoName]
    );

    console.log('\n✅ ডিফল্ট ক্রেডেনশিয়াল সফলভাবে ডেটাবেজে সংরক্ষিত হয়েছে:');
    console.log('--------------------------------------------------');
    console.log(`📱 ফোন:     ${targetPhone}`);
    console.log(`🔑 পাসওয়ার্ড: ${targetPassword}`);
    console.log(`👤 নাম:       ${targetName}`);
    console.log('--------------------------------------------------');
    console.log(`📱 ফোন:     ${demoPhone}`);
    console.log(`🔑 পাসওয়ার্ড: ${demoPassword}`);
    console.log(`👤 নাম:       ${demoName}`);
    console.log('--------------------------------------------------\n');

    process.exit(0);
  } catch (error) {
    console.error('❌ Default user seed error:', error.message);
    process.exit(1);
  }
}

seedDefaultUsers();
