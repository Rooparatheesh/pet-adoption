const express = require('express');
const router = express.Router();

const authRoutes = require('./authRoutes');
const categoryRoutes = require('./categoryRoutes');
const petRoutes = require('./petRoutes');
const favoriteRoutes = require('./favoriteRoutes');
const adoptionRoutes = require('./adoptionRoutes');

router.use('/auth', authRoutes);
router.use('/categories', categoryRoutes);
router.use('/pets', petRoutes);
router.use('/favorites', favoriteRoutes);
router.use('/adoptions', adoptionRoutes);

module.exports = router;
