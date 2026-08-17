const express = require('express');
const { body, query } = require('express-validator');
const validate = require('../middleware/validate');
const auth = require('../middleware/auth');
const userMedicineController = require('../controllers/userMedicine.controller');

const router = express.Router();

// All routes require authentication
router.use(auth);

// GET /api/v1/user-medicines — My active medicine list
router.get('/', userMedicineController.getAll);

// POST /api/v1/user-medicines — Add medicine to my list
router.post(
  '/',
  [
    body('frequency').notEmpty().withMessage('কতবার খাবেন তা বলুন'),
    body('times').isArray({ min: 1 }).withMessage('ওষুধ খাওয়ার সময় দিন'),
    body('start_date').notEmpty().withMessage('শুরুর তারিখ দিন'),
  ],
  validate,
  userMedicineController.create
);

// PUT /api/v1/user-medicines/:id — Update
router.put('/:id', userMedicineController.update);

// DELETE /api/v1/user-medicines/:id — Remove
router.delete('/:id', userMedicineController.remove);

// PATCH /api/v1/user-medicines/:id/refill — Refill
router.patch('/:id/refill', userMedicineController.refill);

module.exports = router;
