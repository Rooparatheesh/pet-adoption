const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const categoryController = require('../controllers/categoryController');
const auth = require('../middleware/auth');
const validate = require('../middleware/validate');

router.get('/', categoryController.list);

router.post(
  '/',
  auth,
  [
    body('name').notEmpty().withMessage('Category name is required.'),
    validate
  ],
  categoryController.create
);

module.exports = router;
