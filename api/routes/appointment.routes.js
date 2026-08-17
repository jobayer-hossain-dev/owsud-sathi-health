const express = require('express');
const { body } = require('express-validator');
const validate = require('../middleware/validate');
const auth = require('../middleware/auth');
const appointmentController = require('../controllers/appointment.controller');

const router = express.Router();
router.use(auth);

router.get('/', appointmentController.getAll);

router.post(
  '/',
  [
    body('doctor_name').notEmpty().withMessage('ডাক্তারের নাম দিন'),
    body('appointment_date').notEmpty().withMessage('তারিখ দিন'),
  ],
  validate,
  appointmentController.create
);

router.put('/:id', appointmentController.update);
router.delete('/:id', appointmentController.remove);

module.exports = router;
