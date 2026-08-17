const express = require('express');
const { query } = require('express-validator');
const validate = require('../middleware/validate');
const medicineController = require('../controllers/medicine.controller');

const router = express.Router();

// GET /api/v1/medicines?q=met&limit=10 — Search medicines (FULLTEXT)
router.get(
  '/',
  [
    query('q').optional().isString(),
    query('limit').optional().isInt({ min: 1, max: 50 }),
    query('page').optional().isInt({ min: 1 }),
    query('category').optional().isString(),
  ],
  validate,
  medicineController.search
);

// GET /api/v1/medicines/:id — Medicine detail
router.get('/:id', medicineController.getById);

// GET /api/v1/medicines/:id/alternatives — Generic alternatives
router.get('/:id/alternatives', medicineController.getAlternatives);

module.exports = router;
