const { Pet, Category, User, Favorite } = require('../models');
const { Op } = require('sequelize');

exports.list = async (req, res, next) => {
  try {
    const { category_id, gender, size, search } = req.query;
    const whereClause = { is_adopted: false }; // Only list unadopted pets by default

    if (category_id) {
      whereClause.category_id = category_id;
    }
    if (gender) {
      whereClause.gender = gender;
    }
    if (size) {
      whereClause.size = size;
    }
    if (search) {
      whereClause[Op.or] = [
        { name: { [Op.iLike]: `%${search}%` } },
        { breed: { [Op.iLike]: `%${search}%` } },
        { location: { [Op.iLike]: `%${search}%` } }
      ];
    }

    const pets = await Pet.findAll({
      where: whereClause,
      include: [
        { model: Category, as: 'category', attributes: ['id', 'name', 'icon'] },
        { model: User, as: 'owner', attributes: ['id', 'name', 'email', 'phone', 'avatar_url'] }
      ],
      order: [['created_at', 'DESC']]
    });

    res.json(pets);
  } catch (error) {
    next(error);
  }
};

// Get pets listed by the currently authenticated user
exports.myListings = async (req, res, next) => {
  try {
    const pets = await Pet.findAll({
      where: { owner_id: req.user.id },
      include: [
        { model: Category, as: 'category', attributes: ['id', 'name', 'icon'] },
        { model: User, as: 'owner', attributes: ['id', 'name', 'email', 'phone', 'avatar_url'] }
      ],
      order: [['created_at', 'DESC']]
    });
    res.json(pets);
  } catch (error) {
    next(error);
  }
};



exports.getDetails = async (req, res, next) => {
  try {
    const { id } = req.params;
    const pet = await Pet.findByPk(id, {
      include: [
        { model: Category, as: 'category', attributes: ['id', 'name', 'icon'] },
        { model: User, as: 'owner', attributes: ['id', 'name', 'email', 'phone', 'avatar_url'] }
      ]
    });

    if (!pet) {
      return res.status(404).json({ error: 'Pet not found.' });
    }

    res.json(pet);
  } catch (error) {
    next(error);
  }
};

exports.create = async (req, res, next) => {
  try {
    const { name, breed, age, gender, size, description, image_url, location, category_id } = req.body;

    // Verify category exists
    const category = await Category.findByPk(category_id);
    if (!category) {
      return res.status(400).json({ error: 'Invalid category ID.' });
    }

    const pet = await Pet.create({
      name,
      breed,
      age,
      gender,
      size,
      description,
      image_url,
      location,
      category_id,
      owner_id: req.user.id
    });

    const detailedPet = await Pet.findByPk(pet.id, {
      include: [
        { model: Category, as: 'category', attributes: ['id', 'name', 'icon'] },
        { model: User, as: 'owner', attributes: ['id', 'name', 'email', 'phone', 'avatar_url'] }
      ]
    });

    res.status(201).json(detailedPet);
  } catch (error) {
    next(error);
  }
};

exports.update = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { name, breed, age, gender, size, description, image_url, location, category_id, is_adopted } = req.body;

    const pet = await Pet.findByPk(id);
    if (!pet) {
      return res.status(404).json({ error: 'Pet not found.' });
    }

    if (pet.owner_id !== req.user.id) {
      return res.status(403).json({ error: 'You are not authorized to update this listing.' });
    }

    if (category_id) {
      const category = await Category.findByPk(category_id);
      if (!category) {
        return res.status(400).json({ error: 'Invalid category ID.' });
      }
      pet.category_id = category_id;
    }

    if (name) pet.name = name;
    if (breed) pet.breed = breed;
    if (age !== undefined) pet.age = age;
    if (gender) pet.gender = gender;
    if (size) pet.size = size;
    if (description !== undefined) pet.description = description;
    if (image_url !== undefined) pet.image_url = image_url;
    if (location) pet.location = location;
    if (is_adopted !== undefined) pet.is_adopted = is_adopted;

    await pet.save();

    const detailedPet = await Pet.findByPk(pet.id, {
      include: [
        { model: Category, as: 'category', attributes: ['id', 'name', 'icon'] },
        { model: User, as: 'owner', attributes: ['id', 'name', 'email', 'phone', 'avatar_url'] }
      ]
    });

    res.json(detailedPet);
  } catch (error) {
    next(error);
  }
};

exports.delete = async (req, res, next) => {
  try {
    const { id } = req.params;
    const pet = await Pet.findByPk(id);

    if (!pet) {
      return res.status(404).json({ error: 'Pet not found.' });
    }

    if (pet.owner_id !== req.user.id) {
      return res.status(403).json({ error: 'You are not authorized to delete this listing.' });
    }

    await pet.destroy();
    res.json({ message: 'Pet listing deleted successfully.' });
  } catch (error) {
    next(error);
  }
};
