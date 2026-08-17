const { pool } = require('../config/database');
const { successResponse, errorResponse, paginatedResponse } = require('../utils/helpers');

exports.search = async (req, res) => {
  try {
    const { q, limit = 20, page = 1, category } = req.query;
    const offset = (page - 1) * limit;

    let sql = 'SELECT * FROM medicines WHERE 1=1';
    let countSql = 'SELECT COUNT(*) as total FROM medicines WHERE 1=1';
    const params = [], countParams = [];
    let searchTerm = '';

    if (q && q.trim().length >= 1) {
      searchTerm = q.trim();
      const prefixTerm = `${searchTerm}%`;
      const containsTerm = `%${searchTerm}%`;

      sql += ' AND (brand_name LIKE ? OR generic_name LIKE ? OR brand_name_bn LIKE ? OR manufacturer LIKE ?)';
      countSql += ' AND (brand_name LIKE ? OR generic_name LIKE ? OR brand_name_bn LIKE ? OR manufacturer LIKE ?)';
      
      params.push(prefixTerm, prefixTerm, containsTerm, containsTerm);
      countParams.push(prefixTerm, prefixTerm, containsTerm, containsTerm);
    }

    if (category) {
      sql += ' AND category = ?';
      countSql += ' AND category = ?';
      params.push(category);
      countParams.push(category);
    }

    const [countResult] = await pool.execute(countSql, countParams);
    const total = countResult[0]?.total || 0;

    if (searchTerm) {
      const p500 = `${searchTerm} 500%`;
      const pAny = `${searchTerm}%`;
      sql += ` ORDER BY 
        CASE 
          WHEN LOWER(brand_name) = LOWER(?) THEN 1
          WHEN LOWER(brand_name) LIKE LOWER(?) THEN 2
          WHEN LOWER(brand_name) LIKE LOWER(?) THEN 3
          WHEN LOWER(generic_name) = LOWER(?) THEN 4
          ELSE 5
        END ASC,
        (dosage_form = 'tablet') DESC,
        unit_price ASC 
        LIMIT ? OFFSET ?`;
      params.push(searchTerm, p500, pAny, searchTerm, parseInt(limit), parseInt(offset));
    } else {
      sql += ' ORDER BY brand_name ASC, unit_price ASC LIMIT ? OFFSET ?';
      params.push(parseInt(limit), parseInt(offset));
    }

    const [medicines] = await pool.execute(sql, params);

    // Parallel variant grouping matching exact generic_name & manufacturer
    await Promise.all(
      medicines.map(async (med) => {
        const baseBrand = med.brand_name.split(' ')[0];
        const [variants] = await pool.execute(
          `SELECT id, brand_name, brand_name_bn, dosage_form, strength, unit_price, manufacturer 
           FROM medicines 
           WHERE brand_name LIKE ? AND generic_name = ? AND manufacturer = ? 
           ORDER BY unit_price ASC`,
          [`${baseBrand}%`, med.generic_name, med.manufacturer]
        );
        med.variants = variants;
      })
    );

    return paginatedResponse(res, medicines, total, parseInt(page), parseInt(limit));
  } catch (error) {
    console.error('Medicine search error:', error);
    return errorResponse(res, 'ওষুধ খুঁজতে সমস্যা হয়েছে: ' + error.message, 500);
  }
};

exports.getById = async (req, res) => {
  try {
    const { id } = req.params;
    const [rows] = await pool.execute(
      `SELECT * FROM medicines WHERE id = ? OR brand_name = ? ORDER BY (dosage_form = 'tablet') DESC, id ASC LIMIT 1`,
      [id, id]
    );
    
    if (rows.length === 0) {
      return errorResponse(res, 'ওষুধটি ডাটাবেজে পাওয়া যায়নি', 404);
    }

    const mainMed = rows[0];
    const baseBrand = mainMed.brand_name.split(' ')[0];

    const [variants] = await pool.execute(
      `SELECT id, brand_name, brand_name_bn, dosage_form, strength, unit_price, manufacturer, composition, composition_bn
       FROM medicines 
       WHERE brand_name LIKE ? AND generic_name = ? AND manufacturer = ? 
       ORDER BY unit_price ASC`,
      [`${baseBrand}%`, mainMed.generic_name, mainMed.manufacturer]
    );

    mainMed.variants = variants;

    return successResponse(res, mainMed);
  } catch (error) {
    console.error('Medicine getById error:', error);
    return errorResponse(res, 'ওষুধের তথ্য আনতে সমস্যা হয়েছে: ' + error.message, 500);
  }
};

exports.getAlternatives = async (req, res) => {
  try {
    const { id } = req.params;
    const [rows] = await pool.execute(
      `SELECT * FROM medicines WHERE id = ? OR brand_name = ? ORDER BY (dosage_form = 'tablet') DESC, id ASC LIMIT 1`,
      [id, id]
    );
    
    if (rows.length === 0) {
      return errorResponse(res, 'মূল ওষুধটি পাওয়া যায়নি', 404);
    }

    const mainMed = rows[0];
    const baseBrand = mainMed.brand_name.split(' ')[0];

    // Fetch up to 30 distinct brand alternatives with same generic name
    const [alts] = await pool.execute(
      `SELECT * FROM medicines 
       WHERE generic_name = ? 
         AND brand_name NOT LIKE ?
       ORDER BY unit_price ASC 
       LIMIT 30`,
      [mainMed.generic_name, `${baseBrand}%`]
    );

    // Calculate savings
    const enrichedAlts = alts.map(alt => {
      const savingsPerUnit = mainMed.unit_price ? Math.max(0, (mainMed.unit_price - alt.unit_price)).toFixed(2) : 0;
      const savingsPercent = mainMed.unit_price > 0 && alt.unit_price < mainMed.unit_price
        ? Math.round(((mainMed.unit_price - alt.unit_price) / mainMed.unit_price) * 100)
        : 0;

      return {
        ...alt,
        savings_per_unit: parseFloat(savingsPerUnit),
        savings_percent: savingsPercent,
      };
    });

    return successResponse(res, {
      original: mainMed,
      original_generic: mainMed.generic_name,
      alternatives: enrichedAlts,
      total: enrichedAlts.length,
      data: enrichedAlts,
    }, enrichedAlts.length > 0 ? `${enrichedAlts.length}টি সস্তা বিকল্প পাওয়া গেছে` : 'কোনো বিকল্প পাওয়া যায়নি');
  } catch (error) {
    console.error('Alternatives error:', error);
    return errorResponse(res, 'বিকল্প ওষুধ খুঁজতে সমস্যা হয়েছে: ' + error.message, 500);
  }
};
