const path = require('path');
const fs = require('fs');
const { pool } = require('../config/database');
const { successResponse, errorResponse } = require('../utils/helpers');

exports.getAll = async (req, res) => {
  try {
    const [rows] = await pool.execute(
      `SELECT p.*, 
        (SELECT JSON_ARRAYAGG(JSON_OBJECT('id', pi.id, 'image_path', pi.image_path, 'sort_order', pi.sort_order))
         FROM prescription_images pi WHERE pi.prescription_id = p.id) as images
       FROM prescriptions p
       WHERE p.user_id = ?
       ORDER BY p.visit_date DESC`,
      [req.user.id]
    );

    const prescriptions = rows.map(p => {
      let parsedImages = [];
      if (p.images) {
        if (typeof p.images === 'string') {
          try { parsedImages = JSON.parse(p.images); } catch (_) {}
        } else if (Array.isArray(p.images)) {
          parsedImages = p.images;
        }
      }
      return { ...p, images: parsedImages };
    });

    return successResponse(res, prescriptions);
  } catch (error) {
    console.error('Get prescriptions error:', error);
    return errorResponse(res, 'প্রেসক্রিপশন আনতে সমস্যা হয়েছে');
  }
};

exports.create = async (req, res) => {
  try {
    const { doctor_name, hospital_name, diagnosis, visit_date, next_visit_date, notes } = req.body;

    const [result] = await pool.execute(
      `INSERT INTO prescriptions (user_id, doctor_name, hospital_name, diagnosis, visit_date, next_visit_date, notes)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [req.user.id, doctor_name || null, hospital_name || null, diagnosis || null,
       visit_date, next_visit_date || null, notes || null]
    );

    const prescriptionId = result.insertId;

    // Save uploaded images
    if (req.files && req.files.length > 0) {
      for (let i = 0; i < req.files.length; i++) {
        const relativePath = `uploads/prescriptions/user_${req.user.id}/${req.files[i].filename}`;
        await pool.execute(
          'INSERT INTO prescription_images (prescription_id, image_path, sort_order) VALUES (?, ?, ?)',
          [prescriptionId, relativePath, i]
        );
      }
    }

    return successResponse(res, { id: prescriptionId }, 'প্রেসক্রিপশন সংরক্ষিত হয়েছে ✅', 201);
  } catch (error) {
    console.error('Create prescription error:', error);
    return errorResponse(res, 'প্রেসক্রিপশন সংরক্ষণ করতে সমস্যা হয়েছে');
  }
};

exports.getById = async (req, res) => {
  try {
    const [prescriptions] = await pool.execute(
      'SELECT * FROM prescriptions WHERE id = ? AND user_id = ?',
      [req.params.id, req.user.id]
    );
    if (prescriptions.length === 0) return errorResponse(res, 'প্রেসক্রিপশন পাওয়া যায়নি', 404);

    const [images] = await pool.execute(
      'SELECT * FROM prescription_images WHERE prescription_id = ? ORDER BY sort_order',
      [req.params.id]
    );

    return successResponse(res, { ...prescriptions[0], images });
  } catch (error) {
    console.error('Get prescription error:', error);
    return errorResponse(res, 'প্রেসক্রিপশন আনতে সমস্যা হয়েছে');
  }
};

exports.remove = async (req, res) => {
  try {
    // Get images to delete from disk
    const [images] = await pool.execute(
      `SELECT pi.image_path FROM prescription_images pi
       JOIN prescriptions p ON pi.prescription_id = p.id
       WHERE p.id = ? AND p.user_id = ?`,
      [req.params.id, req.user.id]
    );

    // Delete from DB (cascade deletes images)
    const [result] = await pool.execute(
      'DELETE FROM prescriptions WHERE id = ? AND user_id = ?',
      [req.params.id, req.user.id]
    );
    if (result.affectedRows === 0) return errorResponse(res, 'প্রেসক্রিপশন পাওয়া যায়নি', 404);

    // Delete files from disk
    for (const img of images) {
      const filePath = path.join(__dirname, '..', img.image_path);
      if (fs.existsSync(filePath)) fs.unlinkSync(filePath);
    }

    return successResponse(res, null, 'প্রেসক্রিপশন মুছে ফেলা হয়েছে');
  } catch (error) {
    console.error('Delete prescription error:', error);
    return errorResponse(res, 'মুছতে সমস্যা হয়েছে');
  }
};
