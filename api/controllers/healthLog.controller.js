const { pool } = require('../config/database');
const { successResponse, errorResponse } = require('../utils/helpers');

/**
 * GET /api/v1/health-logs?type=blood_pressure&days=30
 */
exports.getAll = async (req, res) => {
  try {
    const { type, days = 30 } = req.query;
    let sql = `SELECT * FROM health_logs WHERE user_id = ? AND recorded_at >= DATE_SUB(NOW(), INTERVAL ? DAY)`;
    const params = [req.user.id, parseInt(days)];

    if (type) {
      sql += ` AND type = ?`;
      params.push(type);
    }

    sql += ` ORDER BY recorded_at DESC`;
    const [logs] = await pool.execute(sql, params);

    return successResponse(res, logs);
  } catch (error) {
    console.error('Get health logs error:', error);
    return errorResponse(res, 'স্বাস্থ্য লগ আনতে সমস্যা হয়েছে');
  }
};

/**
 * POST /api/v1/health-logs
 */
exports.create = async (req, res) => {
  try {
    const { type, value_1, value_2, unit, meal_context, notes, recorded_at } = req.body;

    // Auto-set unit if not provided
    let finalUnit = unit;
    if (!finalUnit) {
      const unitMap = { blood_pressure: 'mmHg', blood_sugar: 'mg/dL', weight: 'kg' };
      finalUnit = unitMap[type];
    }

    const [result] = await pool.execute(
      `INSERT INTO health_logs (user_id, type, value_1, value_2, unit, meal_context, notes, recorded_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [req.user.id, type, value_1, value_2 || null, finalUnit, meal_context || null, 
       notes || null, recorded_at || new Date()]
    );

    // Check for abnormal values and warn
    let warning = null;
    if (type === 'blood_pressure') {
      if (value_1 >= 140 || value_2 >= 90) warning = '⚠️ উচ্চ রক্তচাপ! দ্রুত ডাক্তারের পরামর্শ নিন।';
      if (value_1 < 90 || value_2 < 60) warning = '⚠️ নিম্ন রক্তচাপ! দ্রুত ডাক্তারের পরামর্শ নিন।';
    }
    if (type === 'blood_sugar') {
      if (value_1 >= 200) warning = '⚠️ রক্তে শর্করার মাত্রা অনেক বেশি! জরুরি ভিত্তিতে ডাক্তার দেখান।';
      if (value_1 < 70) warning = '⚠️ রক্তে শর্করা কম (হাইপোগ্লাইসেমিয়া)! কিছু মিষ্টি খান।';
    }

    return successResponse(res, { id: result.insertId, warning }, 'রেকর্ড সংরক্ষিত হয়েছে ✅', 201);
  } catch (error) {
    console.error('Create health log error:', error);
    return errorResponse(res, 'রেকর্ড সংরক্ষণ করতে সমস্যা হয়েছে');
  }
};

/**
 * DELETE /api/v1/health-logs/:id
 */
exports.remove = async (req, res) => {
  try {
    const [result] = await pool.execute(
      'DELETE FROM health_logs WHERE id = ? AND user_id = ?',
      [req.params.id, req.user.id]
    );
    if (result.affectedRows === 0) return errorResponse(res, 'রেকর্ড পাওয়া যায়নি', 404);
    return successResponse(res, null, 'রেকর্ড মুছে ফেলা হয়েছে');
  } catch (error) {
    console.error('Delete health log error:', error);
    return errorResponse(res, 'মুছতে সমস্যা হয়েছে');
  }
};

/**
 * GET /api/v1/health-logs/report/pdf
 * Generate PDF health report using PDFKit
 */
const { generateHealthReportPDF } = require('../services/pdf.service');

exports.generatePDF = async (req, res) => {
  try {
    const { days = 30, format } = req.query;

    const [bpLogs] = await pool.execute(
      `SELECT * FROM health_logs WHERE user_id = ? AND type = 'blood_pressure' 
       AND recorded_at >= DATE_SUB(NOW(), INTERVAL ? DAY) ORDER BY recorded_at`,
      [req.user.id, parseInt(days)]
    );

    const [sugarLogs] = await pool.execute(
      `SELECT * FROM health_logs WHERE user_id = ? AND type = 'blood_sugar' 
       AND recorded_at >= DATE_SUB(NOW(), INTERVAL ? DAY) ORDER BY recorded_at`,
      [req.user.id, parseInt(days)]
    );

    const [users] = await pool.execute(
      'SELECT name, phone, blood_group, chronic_conditions FROM users WHERE id = ?',
      [req.user.id]
    );

    const user = users[0] || { name: 'User' };

    if (format === 'json') {
      return successResponse(res, {
        patient: user,
        period: `Last ${days} days`,
        bloodPressure: { readings: bpLogs.length, data: bpLogs },
        bloodSugar: { readings: sugarLogs.length, data: sugarLogs },
        generatedAt: new Date().toISOString(),
      }, 'রিপোর্ট তৈরি হয়েছে');
    }

    const pdfBuffer = await generateHealthReportPDF({
      user,
      bpLogs,
      sugarLogs,
      days: parseInt(days),
    });

    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader(
      'Content-Disposition',
      `attachment; filename="oshudhsathi_health_report_${Date.now()}.pdf"`
    );
    return res.send(pdfBuffer);
  } catch (error) {
    console.error('Generate report error:', error);
    return errorResponse(res, 'রিপোর্ট তৈরি করতে সমস্যা হয়েছে');
  }
};
