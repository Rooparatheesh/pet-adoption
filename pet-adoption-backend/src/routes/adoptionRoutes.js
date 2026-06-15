const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const adoptionController = require('../controllers/adoptionController');
const auth = require('../middleware/auth');
const validate = require('../middleware/validate');

router.get('/', auth, adoptionController.list);

router.post(
  '/',
  auth,
  [
    body('pet_id').isInt().withMessage('Pet ID must be an integer.'),
    validate
  ],
  adoptionController.create
);

router.put(
  '/:id',
  auth,
  [
    body('status').notEmpty().withMessage('Status is required.'),
    validate
  ],
  adoptionController.updateStatus
);

module.exports = router;
