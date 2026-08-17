const express = require('express');
const auth = require('../middleware/auth');
const doseLogController = require('../controllers/doseLog.controller');

const router = express.Router();
router.use(auth);

// GET /api/v1/dose-logs?date=2026-08-17
router.get('/', doseLogController.getByDate);

// GET /api/v1/dose-logs/stats?days=30
router.get('/stats', doseLogController.getStats);

// POST /api/v1/dose-logs/:id/taken
router.post('/:id/taken', doseLogController.markTaken);

// POST /api/v1/dose-logs/:id/missed
router.post('/:id/missed', doseLogController.markMissed);

// POST /api/v1/dose-logs/:id/skipped
router.post('/:id/skipped', doseLogController.markSkipped);

module.exports = router;
