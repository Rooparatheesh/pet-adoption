const { Category } = require('../models');

exports.list = async (req, res, next) => {
  try {
    const categories = await Category.findAll({
      order: [['name', 'ASC']]
    });
    res.json(categories);
  } catch (error) {
    next(error);
  }
};

exports.create = async (req, res, next) => {
  try {
    const { name, icon } = req.body;
    
    const existing = await Category.findOne({ where: { name } });
    if (existing) {
      return res.status(400).json({ error: 'Category already exists.' });
    }

    const category = await Category.create({ name, icon });
    res.status(201).json(category);
  } catch (error) {
    next(error);
  }
};
