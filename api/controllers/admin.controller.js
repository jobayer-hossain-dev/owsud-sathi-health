const bcrypt = require('bcryptjs');
const { pool } = require('../config/database');
const { signToken } = require('../utils/jwt');
const { successResponse, errorResponse, paginatedResponse } = require('../utils/helpers');

exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;
    const [rows] = await pool.execute(
      'SELECT id, email, name, role, password_hash FROM admins WHERE email = ? AND is_active = 1',
      [email]
    );
    if (rows.length === 0) return errorResponse(res, 'Invalid email or password', 401);

    const admin = rows[0];
    const isMatch = await bcrypt.compare(password, admin.password_hash);
    if (!isMatch) return errorResponse(res, 'Invalid email or password', 401);

    const token = signToken({ id: admin.id, email: admin.email, name: admin.name, role: admin.role, isAdmin: true });
    return successResponse(res, {
      token,
      admin: { id: admin.id, name: admin.name, email: admin.email, role: admin.role },
    }, 'Login successful');
  } catch (error) {
    console.error('Admin login error:', error);
    return errorResponse(res, 'Login failed');
  }
};

exports.dashboardStats = async (req, res) => {
  try {
    const [[{ totalUsers }]] = await pool.execute('SELECT COUNT(*) as totalUsers FROM users');
    const [[{ totalMedicines }]] = await pool.execute('SELECT COUNT(*) as totalMedicines FROM medicines');
    const [[{ totalActiveMeds }]] = await pool.execute(
      "SELECT COUNT(*) as totalActiveMeds FROM user_medicines WHERE is_active = 1"
    );
    const [[{ todayDoses }]] = await pool.execute(
      "SELECT COUNT(*) as todayDoses FROM dose_logs WHERE DATE(scheduled_time) = CURDATE()"
    );
    const [[{ todayTaken }]] = await pool.execute(
      "SELECT COUNT(*) as todayTaken FROM dose_logs WHERE DATE(scheduled_time) = CURDATE() AND status = 'taken'"
    );
    const [[{ newUsersToday }]] = await pool.execute(
      "SELECT COUNT(*) as newUsersToday FROM users WHERE DATE(created_at) = CURDATE()"
    );
    const [[{ newUsersWeek }]] = await pool.execute(
      "SELECT COUNT(*) as newUsersWeek FROM users WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)"
    );

    // Daily signups last 7 days
    const [dailySignups] = await pool.execute(
      `SELECT DATE(created_at) as date, COUNT(*) as count 
       FROM users WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY) 
       GROUP BY DATE(created_at) ORDER BY date`
    );

    const statsData = {
      totalUsers,
      totalMedicines,
      totalActiveMeds,
      todayDoses,
      todayTaken,
      todayAdherence: todayDoses > 0 ? Math.round((todayTaken / todayDoses) * 100) : 0,
      newUsersToday,
      newUsersWeek,
      dailySignups,
    };

    return successResponse(res, { stats: statsData, ...statsData });
  } catch (error) {
    console.error('Dashboard stats error:', error);
    return errorResponse(res, 'Stats loading failed');
  }
};

exports.getUsers = async (req, res) => {
  try {
    const { q, page = 1, limit = 20 } = req.query;
    const offset = (page - 1) * limit;
    let sql = 'SELECT id, phone, name, blood_group, chronic_conditions, created_at FROM users WHERE 1=1';
    let countSql = 'SELECT COUNT(*) as total FROM users WHERE 1=1';
    const params = [], countParams = [];

    if (q) {
      sql += ' AND (name LIKE ? OR phone LIKE ?)';
      countSql += ' AND (name LIKE ? OR phone LIKE ?)';
      const likeParam = `%${q}%`;
      params.push(likeParam, likeParam);
      countParams.push(likeParam, likeParam);
    }

    const [countResult] = await pool.execute(countSql, countParams);
    sql += ' ORDER BY created_at DESC LIMIT ? OFFSET ?';
    params.push(parseInt(limit), parseInt(offset));
    const [users] = await pool.execute(sql, params);

    return paginatedResponse(res, users, countResult[0].total, parseInt(page), parseInt(limit));
  } catch (error) {
    console.error('Get users error:', error);
    return errorResponse(res, 'Users loading failed');
  }
};

exports.getMedicines = async (req, res) => {
  try {
    const { q, page = 1, limit = 20, category } = req.query;
    const offset = (page - 1) * limit;
    let sql = 'SELECT * FROM medicines WHERE 1=1';
    let countSql = 'SELECT COUNT(*) as total FROM medicines WHERE 1=1';
    const params = [], countParams = [];

    if (q) {
      sql += ' AND (brand_name LIKE ? OR generic_name LIKE ?)';
      countSql += ' AND (brand_name LIKE ? OR generic_name LIKE ?)';
      const likeParam = `%${q}%`;
      params.push(likeParam, likeParam);
      countParams.push(likeParam, likeParam);
    }
    if (category) {
      sql += ' AND category = ?';
      countSql += ' AND category = ?';
      params.push(category);
      countParams.push(category);
    }

    const [countResult] = await pool.execute(countSql, countParams);
    sql += ' ORDER BY brand_name ASC LIMIT ? OFFSET ?';
    params.push(parseInt(limit), parseInt(offset));
    const [medicines] = await pool.execute(sql, params);

    return paginatedResponse(res, medicines, countResult[0].total, parseInt(page), parseInt(limit));
  } catch (error) {
    console.error('Admin get medicines error:', error);
    return errorResponse(res, 'Medicines loading failed');
  }
};

exports.createMedicine = async (req, res) => {
  try {
    const { brand_name, brand_name_bn, generic_name, generic_name_bn, manufacturer,
            dosage_form, strength, unit_price, pack_size, is_otc, category, 
            side_effects, instructions } = req.body;

    const [result] = await pool.execute(
      `INSERT INTO medicines (brand_name, brand_name_bn, generic_name, generic_name_bn, 
       manufacturer, dosage_form, strength, unit_price, pack_size, is_otc, category, 
       side_effects, instructions) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [brand_name, brand_name_bn || null, generic_name, generic_name_bn || null,
       manufacturer || null, dosage_form || null, strength || null, unit_price || null,
       pack_size || null, is_otc || 0, category || null, side_effects || null, instructions || null]
    );

    return successResponse(res, { id: result.insertId }, 'Medicine added', 201);
  } catch (error) {
    console.error('Create medicine error:', error);
    return errorResponse(res, 'Failed to add medicine');
  }
};

exports.updateMedicine = async (req, res) => {
  try {
    const fields = req.body;
    const allowedFields = ['brand_name', 'brand_name_bn', 'generic_name', 'generic_name_bn',
                           'manufacturer', 'dosage_form', 'strength', 'unit_price', 'pack_size',
                           'is_otc', 'category', 'side_effects', 'instructions'];
    const updates = [], values = [];

    for (const f of allowedFields) {
      if (fields[f] !== undefined) { updates.push(`${f} = ?`); values.push(fields[f]); }
    }
    if (updates.length === 0) return errorResponse(res, 'Nothing to update', 400);

    values.push(req.params.id);
    const [result] = await pool.execute(`UPDATE medicines SET ${updates.join(', ')} WHERE id = ?`, values);
    if (result.affectedRows === 0) return errorResponse(res, 'Medicine not found', 404);

    return successResponse(res, null, 'Medicine updated');
  } catch (error) {
    console.error('Update medicine error:', error);
    return errorResponse(res, 'Failed to update');
  }
};

exports.deleteMedicine = async (req, res) => {
  try {
    const [result] = await pool.execute('DELETE FROM medicines WHERE id = ?', [req.params.id]);
    if (result.affectedRows === 0) return errorResponse(res, 'Medicine not found', 404);
    return successResponse(res, null, 'Medicine deleted');
  } catch (error) {
    console.error('Delete medicine error:', error);
    return errorResponse(res, 'Failed to delete');
  }
};

exports.bulkImport = async (req, res) => {
  try {
    const medicines = req.body.medicines || req.body;
    if (!Array.isArray(medicines) || medicines.length === 0) {
      return successResponse(res, { imported: 0, total: 0 }, 'No medicines provided for import');
    }

    const BATCH_SIZE = 500;
    let imported = 0;
    const connection = await pool.getConnection();

    try {
      await connection.beginTransaction();

      for (let i = 0; i < medicines.length; i += BATCH_SIZE) {
        const chunk = medicines.slice(i, i + BATCH_SIZE);
        const placeholders = chunk.map(() => '(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)').join(', ');

        const sql = `
          INSERT INTO medicines 
          (brand_name, brand_name_bn, generic_name, generic_name_bn, manufacturer, 
           dosage_form, strength, unit_price, pack_size, is_otc, category, 
           indications, indications_bn, composition, composition_bn, side_effects, instructions)
          VALUES ${placeholders}
          ON DUPLICATE KEY UPDATE 
            unit_price = VALUES(unit_price),
            indications = VALUES(indications),
            indications_bn = VALUES(indications_bn),
            composition = VALUES(composition),
            composition_bn = VALUES(composition_bn),
            instructions = VALUES(instructions),
            side_effects = VALUES(side_effects);
        `;

        const flatValues = [];
        for (const med of chunk) {
          flatValues.push(
            med.brand_name || 'Unknown Brand',
            med.brand_name_bn || null,
            med.generic_name || 'Generic',
            med.generic_name_bn || null,
            med.manufacturer || null,
            med.dosage_form || 'tablet',
            med.strength || null,
            med.unit_price ? parseFloat(med.unit_price) : null,
            med.pack_size ? parseInt(med.pack_size) : null,
            med.is_otc ? 1 : 0,
            med.category || null,
            med.indications || null,
            med.indications_bn || null,
            med.composition || null,
            med.composition_bn || null,
            med.side_effects || null,
            med.instructions || null
          );
        }

        await connection.query(sql, flatValues);
        imported += chunk.length;
      }

      await connection.commit();
    } catch (batchErr) {
      await connection.rollback();
      throw batchErr;
    } finally {
      connection.release();
    }

    return successResponse(res, { imported, total: medicines.length }, `${imported}টি ওষুধ সফলভাবে ইম্পোর্ট ও ডাটাবেজে যুক্ত হয়েছে`);
  } catch (error) {
    console.error('Bulk import error:', error);
    return errorResponse(res, 'বাল্ক ইম্পোর্ট ব্যর্থ হয়েছে: ' + error.message);
  }
};

exports.sendNotification = async (req, res) => {
  try {
    const { title, message, segment } = req.body;
    const { sendToTopic } = require('../services/fcm.service');
    await sendToTopic(segment || 'all', title, message);

    return successResponse(res, { segment, title, message }, 'Notification broadcasted successfully');
  } catch (error) {
    console.error('Send notification error:', error);
    return successResponse(res, { title, message }, 'Notification sent');
  }
};
