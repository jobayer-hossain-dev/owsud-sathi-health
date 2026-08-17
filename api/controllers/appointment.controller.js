const { pool } = require('../config/database');
const { successResponse, errorResponse } = require('../utils/helpers');

exports.getAll = async (req, res) => {
  try {
    const [appointments] = await pool.execute(
      `SELECT * FROM doctor_appointments WHERE user_id = ? ORDER BY appointment_date ASC`,
      [req.user.id]
    );
    return successResponse(res, appointments);
  } catch (error) {
    console.error('Get appointments error:', error);
    return errorResponse(res, 'অ্যাপয়েন্টমেন্ট আনতে সমস্যা হয়েছে');
  }
};

exports.create = async (req, res) => {
  try {
    const { doctor_name, hospital_name, phone, appointment_date, reminder_days, notes } = req.body;
    const [result] = await pool.execute(
      `INSERT INTO doctor_appointments (user_id, doctor_name, hospital_name, phone, appointment_date, reminder_days, notes)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [req.user.id, doctor_name, hospital_name || null, phone || null, 
       appointment_date, reminder_days || 7, notes || null]
    );
    return successResponse(res, { id: result.insertId }, 'অ্যাপয়েন্টমেন্ট যোগ হয়েছে ✅', 201);
  } catch (error) {
    console.error('Create appointment error:', error);
    return errorResponse(res, 'অ্যাপয়েন্টমেন্ট যোগ করতে সমস্যা হয়েছে');
  }
};

exports.update = async (req, res) => {
  try {
    const { id } = req.params;
    const { doctor_name, hospital_name, phone, appointment_date, reminder_days, notes } = req.body;
    const [result] = await pool.execute(
      `UPDATE doctor_appointments SET doctor_name=?, hospital_name=?, phone=?, 
       appointment_date=?, reminder_days=?, notes=? WHERE id=? AND user_id=?`,
      [doctor_name, hospital_name || null, phone || null, appointment_date, 
       reminder_days || 7, notes || null, id, req.user.id]
    );
    if (result.affectedRows === 0) return errorResponse(res, 'অ্যাপয়েন্টমেন্ট পাওয়া যায়নি', 404);
    return successResponse(res, null, 'অ্যাপয়েন্টমেন্ট আপডেট হয়েছে');
  } catch (error) {
    console.error('Update appointment error:', error);
    return errorResponse(res, 'আপডেট করতে সমস্যা হয়েছে');
  }
};

exports.remove = async (req, res) => {
  try {
    const [result] = await pool.execute(
      'DELETE FROM doctor_appointments WHERE id = ? AND user_id = ?',
      [req.params.id, req.user.id]
    );
    if (result.affectedRows === 0) return errorResponse(res, 'অ্যাপয়েন্টমেন্ট পাওয়া যায়নি', 404);
    return successResponse(res, null, 'অ্যাপয়েন্টমেন্ট মুছে ফেলা হয়েছে');
  } catch (error) {
    console.error('Delete appointment error:', error);
    return errorResponse(res, 'মুছতে সমস্যা হয়েছে');
  }
};
