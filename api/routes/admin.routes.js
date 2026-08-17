const express = require('express');
const { body } = require('express-validator');
const validate = require('../middleware/validate');
const adminAuth = require('../middleware/adminAuth');
const adminController = require('../controllers/admin.controller');

const router = express.Router();

// Admin login (no auth needed)
router.post(
  '/auth/login',
  [
    body('email').isEmail().withMessage('Valid email required'),
    body('password').notEmpty().withMessage('Password required'),
  ],
  validate,
  adminController.login
);

// All routes below require admin auth
router.use(adminAuth);

// Dashboard
router.get('/dashboard/stats', adminController.dashboardStats);

// Users
router.get('/users', adminController.getUsers);

// Medicines CRUD
router.get('/medicines', adminController.getMedicines);
router.post('/medicines', adminController.createMedicine);
router.put('/medicines/:id', adminController.updateMedicine);
router.delete('/medicines/:id', adminController.deleteMedicine);

// Bulk import
router.post('/medicines/bulk-import', adminController.bulkImport);

// Push notifications
router.post('/notifications/send', adminController.sendNotification);

module.exports = router;
