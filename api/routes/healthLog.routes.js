const express = require('express');
const { body } = require('express-validator');
const validate = require('../middleware/validate');
const auth = require('../middleware/auth');
const healthLogController = require('../controllers/healthLog.controller');

const router = express.Router();
router.use(auth);

// GET /api/v1/health-logs?type=blood_pressure&days=30
router.get('/', healthLogController.getAll);

// POST /api/v1/health-logs
router.post(
  '/',
  [
    body('type').isIn(['blood_pressure', 'blood_sugar', 'weight']).withMessage('সঠিক ধরন দিন'),
    body('value_1').isNumeric().withMessage('মান দিন'),
  ],
  validate,
  healthLogController.create
);

// DELETE /api/v1/health-logs/:id
router.delete('/:id', healthLogController.remove);

// GET /api/v1/health-logs/report/pdf
router.get('/report/pdf', healthLogController.generatePDF);

module.exports = router;
