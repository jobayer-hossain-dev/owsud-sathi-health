const mysql = require('mysql2/promise');
const fs = require('fs');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '..', '.env') });

async function initializeDatabase() {
  console.log('🔄 XAMPP MySQL সার্ভারে কানেক্ট করার চেষ্টা করা হচ্ছে...');

  const host = process.env.DB_HOST || 'localhost';
  const user = process.env.DB_USER || 'root';
  const password = process.env.DB_PASSWORD || '';
  const port = parseInt(process.env.DB_PORT) || 3306;
  const dbName = process.env.DB_NAME || 'oshudhsathi_db';

  let connection;

  try {
    // 1. Connect without DB first to create database
    connection = await mysql.createConnection({
      host,
      user,
      password,
      port,
      multipleStatements: true,
    });

    console.log('✅ XAMPP MySQL সার্ভারে কানেকশন সফল!');

    // 2. Read schema.sql
    const schemaPath = path.join(__dirname, 'schema.sql');
    const schemaSql = fs.readFileSync(schemaPath, 'utf8');

    console.log(`📦 '${dbName}' ডেটাবেজ ও সব টেবিল তৈরি করা হচ্ছে...`);
    await connection.query(schemaSql);
    console.log('✅ ডেটাবেজ ও ১১টি টেবিল সফলভাবে তৈরি হয়েছে!');

    // 3. Verify created tables
    await connection.changeUser({ database: dbName });
    const [tables] = await connection.query('SHOW TABLES');
    console.log(`\n📋 বর্তমান টেবিলসমূহ (${tables.length} টি):`);
    tables.forEach((t) => {
      console.log(`   • ${Object.values(t)[0]}`);
    });

    console.log('\n🎉 লাইভ MySQL ডেটাবেজ কানেকশন ও সেটআপ সম্পন্ন হয়েছে!\n');
  } catch (error) {
    console.error('\n❌ ডেটাবেজ সেটআপ ব্যর্থ:', error.message);
    if (error.code === 'ECONNREFUSED') {
      console.error('💡 নিশ্চিত করুন XAMPP Control Panel-এ MySQL সার্ভিসটি "Start" করা আছে।');
    }
  } finally {
    if (connection) await connection.end();
  }
}

initializeDatabase();
