const express = require('express');
const auth = require('../middleware/auth');
const familyController = require('../controllers/family.controller');

const router = express.Router();

// Public route for shared family link view
router.get('/:userId/today', familyController.getMemberToday);

// All routes below require auth
router.use(auth);

// POST /api/v1/family/invite
router.post('/invite', familyController.invite);

// POST /api/v1/family/accept/:code
router.post('/accept/:code', familyController.accept);

// GET /api/v1/family/members
router.get('/members', familyController.getMembers);

// DELETE /api/v1/family/:linkId
router.delete('/:linkId', familyController.remove);

module.exports = router;
