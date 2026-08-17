const express = require('express');
const auth = require('../middleware/auth');
const upload = require('../middleware/upload');
const prescriptionController = require('../controllers/prescription.controller');

const router = express.Router();
router.use(auth);

// GET /api/v1/prescriptions
router.get('/', prescriptionController.getAll);

// POST /api/v1/prescriptions (multipart/form-data)
router.post('/', upload.any(), prescriptionController.create);

// GET /api/v1/prescriptions/:id
router.get('/:id', prescriptionController.getById);

// DELETE /api/v1/prescriptions/:id
router.delete('/:id', prescriptionController.remove);

module.exports = router;
