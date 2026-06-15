const express = require('express');
const router = express.Router();
const favoriteController = require('../controllers/favoriteController');
const auth = require('../middleware/auth');

router.get('/', auth, favoriteController.list);
router.post('/:petId', auth, favoriteController.toggle);

module.exports = router;
