const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const petController = require('../controllers/petController');
const auth = require('../middleware/auth');
const validate = require('../middleware/validate');

router.get('/', petController.list);
router.get('/my', auth, petController.myListings);
router.get('/:id', petController.getDetails);


router.post(
  '/',
  auth,
  [
    body('name').notEmpty().withMessage('Name is required.'),
    body('breed').notEmpty().withMessage('Breed is required.'),
    body('age').isInt({ min: 0 }).withMessage('Age must be a positive integer representing months.'),
    body('gender').notEmpty().withMessage('Gender is required.'),
    body('size').notEmpty().withMessage('Size is required.'),
    body('location').notEmpty().withMessage('Location is required.'),
    body('category_id').isInt().withMessage('Category ID must be an integer.'),
    validate
  ],
  petController.create
);

router.put(
  '/:id',
  auth,
  [
    body('age').optional().isInt({ min: 0 }).withMessage('Age must be a positive integer.'),
    body('category_id').optional().isInt().withMessage('Category ID must be an integer.'),
    validate
  ],
  petController.update
);

router.delete('/:id', auth, petController.delete);

module.exports = router;
