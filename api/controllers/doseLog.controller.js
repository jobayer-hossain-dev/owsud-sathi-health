const { pool } = require('../config/database');
const { successResponse, errorResponse } = require('../utils/helpers');

async function ensureDoseLogsForDate(userId, targetDate) {
  try {
    const [medicines] = await pool.execute(
      `SELECT id, times FROM user_medicines 
       WHERE user_id = ? AND is_active = 1 
         AND start_date <= ? 
         AND (end_date IS NULL OR end_date >= ?)`,
      [userId, targetDate, targetDate]
    );

    for (const med of medicines) {
      let times = [];
      if (Array.isArray(med.times)) {
        times = med.times;
      } else if (typeof med.times === 'string') {
        try { times = JSON.parse(med.times); } catch (_) { times = [med.times]; }
      }

      for (const timeStr of times) {
        const scheduledTime = `${targetDate} ${timeStr.length === 5 ? timeStr + ':00' : timeStr}`;
        await pool.execute(
          `INSERT INTO dose_logs (user_medicine_id, user_id, scheduled_time, status)
           SELECT ?, ?, ?, 'pending'
           FROM DUAL
           WHERE NOT EXISTS (
             SELECT 1 FROM dose_logs WHERE user_medicine_id = ? AND scheduled_time = ?
           )`,
          [med.id, userId, scheduledTime, med.id, scheduledTime]
        );
      }
    }
  } catch (err) {
    console.error('ensureDoseLogsForDate error:', err);
  }
}

/**
 * GET /api/v1/dose-logs?date=2026-08-17
 */
exports.getByDate = async (req, res) => {
  try {
    const date = req.query.date || new Date().toISOString().split('T')[0];

    // Ensure dose logs exist for active medicines on this date
    await ensureDoseLogsForDate(req.user.id, date);

    const [logs] = await pool.execute(
      `SELECT dl.*, um.dosage, um.meal_instruction,
              COALESCE(m.brand_name, um.custom_name) as medicine_name,
              COALESCE(m.brand_name_bn, um.custom_name) as medicine_name_bn,
              COALESCE(m.brand_name, um.custom_name) as brand_name,
              um.custom_name,
              m.dosage_form, m.strength
       FROM dose_logs dl
       JOIN user_medicines um ON dl.user_medicine_id = um.id
       LEFT JOIN medicines m ON um.medicine_id = m.id
       WHERE dl.user_id = ? AND DATE(dl.scheduled_time) = ?
       ORDER BY dl.scheduled_time ASC`,
      [req.user.id, date]
    );

    // Summary
    const total = logs.length;
    const taken = logs.filter(l => l.status === 'taken').length;
    const missed = logs.filter(l => l.status === 'missed').length;
    const pending = logs.filter(l => l.status === 'pending').length;

    return successResponse(res, {
      date,
      summary: { total, taken, missed, pending, adherence: total > 0 ? Math.round((taken / total) * 100) : 0 },
      logs,
      data: logs,
    });
  } catch (error) {
    console.error('Get dose logs error:', error);
    return errorResponse(res, 'ডোজ লগ আনতে সমস্যা হয়েছে');
  }
};

/**
 * GET /api/v1/dose-logs/stats?days=30
 */
exports.getStats = async (req, res) => {
  try {
    const days = parseInt(req.query.days) || 30;

    const [stats] = await pool.execute(
      `SELECT 
         DATE(scheduled_time) as date,
         COUNT(*) as total,
         SUM(status = 'taken') as taken,
         SUM(status = 'missed') as missed,
         SUM(status = 'skipped') as skipped
       FROM dose_logs
       WHERE user_id = ? AND scheduled_time >= DATE_SUB(NOW(), INTERVAL ? DAY)
       GROUP BY DATE(scheduled_time)
       ORDER BY date DESC`,
      [req.user.id, days]
    );

    // Overall adherence
    const [overall] = await pool.execute(
      `SELECT 
         COUNT(*) as total,
         SUM(status = 'taken') as taken
       FROM dose_logs
       WHERE user_id = ? AND scheduled_time >= DATE_SUB(NOW(), INTERVAL ? DAY)`,
      [req.user.id, days]
    );

    const overallAdherence = overall[0].total > 0 
      ? Math.round((overall[0].taken / overall[0].total) * 100) : 0;

    return successResponse(res, {
      period: `${days} days`,
      overallAdherence,
      dailyStats: stats,
    });
  } catch (error) {
    console.error('Dose stats error:', error);
    return errorResponse(res, 'পরিসংখ্যান আনতে সমস্যা হয়েছে');
  }
};

/** Mark dose status helper */
async function updateStatus(req, res, status) {
  try {
    const { id } = req.params;

    const [currentRows] = await pool.execute(
      'SELECT status, user_medicine_id FROM dose_logs WHERE id = ? AND user_id = ?',
      [id, req.user.id]
    );

    if (currentRows.length === 0) return errorResponse(res, 'ডোজ লগ পাওয়া যায়নি', 404);
    const prevStatus = currentRows[0].status;

    await pool.execute(
      `UPDATE dose_logs SET status = ?, taken_at = ${status === 'taken' ? 'NOW()' : 'NULL'}
       WHERE id = ? AND user_id = ?`,
      [status, id, req.user.id]
    );

    // Stock adjustment: only decrement if changing to taken from non-taken
    if (status === 'taken' && prevStatus !== 'taken') {
      await pool.execute(
        `UPDATE user_medicines SET remaining_quantity = GREATEST(0, remaining_quantity - 1)
         WHERE id = ? AND remaining_quantity IS NOT NULL`,
        [currentRows[0].user_medicine_id]
      );
    } else if (prevStatus === 'taken' && status !== 'taken') {
      await pool.execute(
        `UPDATE user_medicines SET remaining_quantity = remaining_quantity + 1
         WHERE id = ? AND remaining_quantity IS NOT NULL`,
        [currentRows[0].user_medicine_id]
      );
    }

    const messages = { taken: 'ওষুধ খাওয়া হয়েছে ✅', missed: 'মিস হয়েছে ❌', skipped: 'স্কিপ করা হয়েছে ⏭️' };
    return successResponse(res, null, messages[status]);
  } catch (error) {
    console.error(`Mark ${status} error:`, error);
    return errorResponse(res, 'আপডেট করতে সমস্যা হয়েছে');
  }
}

exports.markTaken = (req, res) => updateStatus(req, res, 'taken');
exports.markMissed = (req, res) => updateStatus(req, res, 'missed');
exports.markSkipped = (req, res) => updateStatus(req, res, 'skipped');
