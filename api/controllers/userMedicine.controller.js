const { pool } = require('../config/database');
const { successResponse, errorResponse } = require('../utils/helpers');

/**
 * GET /api/v1/user-medicines
 */
exports.getAll = async (req, res) => {
  try {
    const [medicines] = await pool.execute(
      `SELECT um.*, m.brand_name, m.brand_name_bn, m.generic_name, 
              m.dosage_form, m.strength, m.unit_price, m.instructions
       FROM user_medicines um
       LEFT JOIN medicines m ON um.medicine_id = m.id
       WHERE um.user_id = ? AND um.is_active = 1
       ORDER BY um.created_at DESC`,
      [req.user.id]
    );

    return successResponse(res, medicines);
  } catch (error) {
    console.error('Get user medicines error:', error);
    return errorResponse(res, 'ওষুধের তালিকা আনতে সমস্যা হয়েছে');
  }
};

/**
 * POST /api/v1/user-medicines
 */
exports.create = async (req, res) => {
  try {
    const { medicine_id, custom_name, dosage, frequency, times, meal_instruction, 
            start_date, end_date, total_quantity, refill_alert_days, notes } = req.body;

    const [result] = await pool.execute(
      `INSERT INTO user_medicines 
       (user_id, medicine_id, custom_name, dosage, frequency, times, meal_instruction,
        start_date, end_date, total_quantity, remaining_quantity, refill_alert_days, notes)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [req.user.id, medicine_id || null, custom_name || null, dosage || null, 
       frequency, JSON.stringify(times), meal_instruction || 'any',
       start_date, end_date || null, total_quantity || null, total_quantity || null,
       refill_alert_days || 3, notes || null]
    );

    return successResponse(res, { id: result.insertId }, 'ওষুধ যোগ করা হয়েছে ✅', 201);
  } catch (error) {
    console.error('Create user medicine error:', error);
    return errorResponse(res, 'ওষুধ যোগ করতে সমস্যা হয়েছে');
  }
};

/**
 * PUT /api/v1/user-medicines/:id
 */
exports.update = async (req, res) => {
  try {
    const { id } = req.params;
    const fields = req.body;

    // Verify ownership
    const [existing] = await pool.execute(
      'SELECT id FROM user_medicines WHERE id = ? AND user_id = ?',
      [id, req.user.id]
    );
    if (existing.length === 0) return errorResponse(res, 'ওষুধ পাওয়া যায়নি', 404);

    // Build dynamic update
    const allowedFields = ['dosage', 'frequency', 'meal_instruction', 'start_date', 
                           'end_date', 'total_quantity', 'remaining_quantity', 
                           'refill_alert_days', 'notes', 'is_active'];
    const updates = [];
    const values = [];

    for (const field of allowedFields) {
      if (fields[field] !== undefined) {
        updates.push(`${field} = ?`);
        values.push(fields[field]);
      }
    }

    if (fields.times) {
      updates.push('times = ?');
      values.push(JSON.stringify(fields.times));
    }

    if (updates.length === 0) return errorResponse(res, 'কিছু পরিবর্তন করুন', 400);

    values.push(id, req.user.id);
    await pool.execute(
      `UPDATE user_medicines SET ${updates.join(', ')} WHERE id = ? AND user_id = ?`,
      values
    );

    return successResponse(res, null, 'ওষুধের তথ্য আপডেট হয়েছে');
  } catch (error) {
    console.error('Update user medicine error:', error);
    return errorResponse(res, 'আপডেট করতে সমস্যা হয়েছে');
  }
};

/**
 * DELETE /api/v1/user-medicines/:id
 */
exports.remove = async (req, res) => {
  try {
    const { id } = req.params;
    const [result] = await pool.execute(
      'UPDATE user_medicines SET is_active = 0 WHERE id = ? AND user_id = ?',
      [id, req.user.id]
    );

    if (result.affectedRows === 0) return errorResponse(res, 'ওষুধ পাওয়া যায়নি', 404);
    return successResponse(res, null, 'ওষুধ তালিকা থেকে সরানো হয়েছে');
  } catch (error) {
    console.error('Remove user medicine error:', error);
    return errorResponse(res, 'সরাতে সমস্যা হয়েছে');
  }
};

/**
 * PATCH /api/v1/user-medicines/:id/refill
 */
exports.refill = async (req, res) => {
  try {
    const { id } = req.params;
    const { quantity } = req.body;

    const [existing] = await pool.execute(
      'SELECT total_quantity FROM user_medicines WHERE id = ? AND user_id = ?',
      [id, req.user.id]
    );
    if (existing.length === 0) return errorResponse(res, 'ওষুধ পাওয়া যায়নি', 404);

    const newQuantity = quantity || existing[0].total_quantity;
    await pool.execute(
      'UPDATE user_medicines SET remaining_quantity = ? WHERE id = ? AND user_id = ?',
      [newQuantity, id, req.user.id]
    );

    return successResponse(res, { remaining_quantity: newQuantity }, 'রিফিল হয়েছে ✅');
  } catch (error) {
    console.error('Refill error:', error);
    return errorResponse(res, 'রিফিল করতে সমস্যা হয়েছে');
  }
};
