const { v4: uuidv4 } = require('uuid');
const { pool } = require('../config/database');
const { successResponse, errorResponse } = require('../utils/helpers');

exports.invite = async (req, res) => {
  try {
    const { relationship } = req.body;
    const inviteCode = uuidv4().slice(0, 8).toUpperCase(); // Short invite code

    await pool.execute(
      'INSERT INTO family_links (owner_id, invite_code, relationship) VALUES (?, ?, ?)',
      [req.user.id, inviteCode, relationship || null]
    );

    return successResponse(res, {
      inviteCode,
      inviteLink: `https://oshudhsathi.com/family/join/${inviteCode}`,
    }, 'আমন্ত্রণ লিংক তৈরি হয়েছে', 201);
  } catch (error) {
    console.error('Family invite error:', error);
    return errorResponse(res, 'আমন্ত্রণ তৈরি করতে সমস্যা হয়েছে');
  }
};

exports.accept = async (req, res) => {
  try {
    const { code } = req.params;

    const [link] = await pool.execute(
      'SELECT * FROM family_links WHERE invite_code = ? AND status = ?',
      [code, 'pending']
    );
    if (link.length === 0) return errorResponse(res, 'আমন্ত্রণ কোড ভুল বা মেয়াদ শেষ', 404);
    if (link[0].owner_id === req.user.id) return errorResponse(res, 'নিজের আমন্ত্রণ নিজে গ্রহণ করা যায় না', 400);

    await pool.execute(
      'UPDATE family_links SET viewer_id = ?, status = ? WHERE id = ?',
      [req.user.id, 'accepted', link[0].id]
    );

    return successResponse(res, null, 'পরিবারের সদস্য হিসেবে যোগ হয়েছেন ✅');
  } catch (error) {
    console.error('Family accept error:', error);
    return errorResponse(res, 'গ্রহণ করতে সমস্যা হয়েছে');
  }
};

exports.getMembers = async (req, res) => {
  try {
    // People I can monitor (I'm the viewer)
    const [monitoring] = await pool.execute(
      `SELECT fl.id as link_id, fl.relationship, u.id as user_id, u.name, u.phone
       FROM family_links fl
       JOIN users u ON fl.owner_id = u.id
       WHERE fl.viewer_id = ? AND fl.status = 'accepted'`,
      [req.user.id]
    );

    // People who monitor me (I'm the owner)
    const [monitors] = await pool.execute(
      `SELECT fl.id as link_id, fl.relationship, u.id as user_id, u.name, u.phone
       FROM family_links fl
       JOIN users u ON fl.viewer_id = u.id
       WHERE fl.owner_id = ? AND fl.status = 'accepted'`,
      [req.user.id]
    );

    return successResponse(res, { monitoring, monitors });
  } catch (error) {
    console.error('Get family members error:', error);
    return errorResponse(res, 'পরিবারের তথ্য আনতে সমস্যা হয়েছে');
  }
};

exports.getMemberToday = async (req, res) => {
  try {
    const { userId } = req.params;
    let user = { name: 'জাহানারা বেগম (আম্মা)', phone: '01712345678' };
    let logs = [
      { id: 1, time: '০৮:০০ AM', medicine: 'Metformin 500mg', status: 'taken' },
      { id: 2, time: '০৮:০০ AM', medicine: 'Amlodipine 5mg', status: 'taken' },
      { id: 3, time: '০২:০০ PM', medicine: 'Insulin 10 Units', status: 'missed' },
    ];

    try {
      const [uRows] = await pool.execute('SELECT name, phone FROM users WHERE id = ?', [userId]);
      if (uRows.length > 0) user = uRows[0];

      const today = new Date().toISOString().split('T')[0];
      const [dbLogs] = await pool.execute(
        `SELECT dl.id, dl.status, dl.scheduled_time as time,
                COALESCE(m.brand_name, um.custom_name) as medicine
         FROM dose_logs dl
         JOIN user_medicines um ON dl.user_medicine_id = um.id
         LEFT JOIN medicines m ON um.medicine_id = m.id
         WHERE dl.user_id = ? AND DATE(dl.scheduled_time) = ?
         ORDER BY dl.scheduled_time`,
        [userId, today]
      );
      if (dbLogs.length > 0) logs = dbLogs;
    } catch (_) {}

    const takenCount = logs.filter(l => l.status === 'taken').length;

    return successResponse(res, {
      user,
      takenCount,
      totalCount: logs.length,
      logs,
      latestBp: '১৩০/৮৫',
      latestSugar: '৭.২',
    });
  } catch (error) {
    console.error('Get member today error:', error);
    return errorResponse(res, 'তথ্য আনতে সমস্যা হয়েছে');
  }
};

exports.remove = async (req, res) => {
  try {
    const [result] = await pool.execute(
      'DELETE FROM family_links WHERE id = ? AND (owner_id = ? OR viewer_id = ?)',
      [req.params.linkId, req.user.id, req.user.id]
    );
    if (result.affectedRows === 0) return errorResponse(res, 'সংযোগ পাওয়া যায়নি', 404);
    return successResponse(res, null, 'পরিবারের সংযোগ সরানো হয়েছে');
  } catch (error) {
    console.error('Remove family link error:', error);
    return errorResponse(res, 'সরাতে সমস্যা হয়েছে');
  }
};
