const { Favorite, Pet, Category, User } = require('../models');

exports.list = async (req, res, next) => {
  try {
    const favorites = await Favorite.findAll({
      where: { user_id: req.user.id },
      include: [
        {
          model: Pet,
          as: 'pet',
          include: [
            { model: Category, as: 'category', attributes: ['id', 'name', 'icon'] },
            { model: User, as: 'owner', attributes: ['id', 'name', 'email', 'phone', 'avatar_url'] }
          ]
        }
      ],
      order: [['created_at', 'DESC']]
    });

    // Extract the pets from favorites records, filtering out deleted pets (if any)
    const favoritedPets = favorites
      .filter(fav => fav.pet !== null)
      .map(fav => fav.pet);

    res.json(favoritedPets);
  } catch (error) {
    next(error);
  }
};

exports.toggle = async (req, res, next) => {
  try {
    const { petId } = req.params;
    const userId = req.user.id;

    // Verify pet exists
    const pet = await Pet.findByPk(petId);
    if (!pet) {
      return res.status(404).json({ error: 'Pet not found.' });
    }

    const existingFavorite = await Favorite.findOne({
      where: { user_id: userId, pet_id: petId }
    });

    if (existingFavorite) {
      await existingFavorite.destroy();
      return res.json({ favorited: false, message: 'Removed from favorites.' });
    } else {
      await Favorite.create({ user_id: userId, pet_id: petId });
      return res.status(201).json({ favorited: true, message: 'Added to favorites.' });
    }
  } catch (error) {
    next(error);
  }
};
