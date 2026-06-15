const { AdoptionRequest, Pet, User, Category } = require('../models');

exports.list = async (req, res, next) => {
  try {
    const { type } = req.query; // 'sent' (default) or 'received'
    const userId = req.user.id;

    if (type === 'received') {
      // Find requests for pets owned by the current user
      const requests = await AdoptionRequest.findAll({
        include: [
          {
            model: Pet,
            as: 'pet',
            where: { owner_id: userId },
            include: [{ model: Category, as: 'category', attributes: ['id', 'name'] }]
          },
          {
            model: User,
            as: 'requester',
            attributes: ['id', 'name', 'email', 'phone', 'avatar_url']
          }
        ],
        order: [['created_at', 'DESC']]
      });
      return res.json(requests);
    }

    // Default: requests sent by the current user
    const requests = await AdoptionRequest.findAll({
      where: { user_id: userId },
      include: [
        {
          model: Pet,
          as: 'pet',
          include: [
            { model: Category, as: 'category', attributes: ['id', 'name'] },
            { model: User, as: 'owner', attributes: ['id', 'name', 'email', 'phone', 'avatar_url'] }
          ]
        }
      ],
      order: [['created_at', 'DESC']]
    });

    res.json(requests);
  } catch (error) {
    next(error);
  }
};

exports.create = async (req, res, next) => {
  try {
    const { pet_id, message } = req.body;
    const userId = req.user.id;

    const pet = await Pet.findByPk(pet_id);
    if (!pet) {
      return res.status(404).json({ error: 'Pet not found.' });
    }

    if (pet.is_adopted) {
      return res.status(400).json({ error: 'This pet has already been adopted.' });
    }

    if (pet.owner_id === userId) {
      return res.status(400).json({ error: 'You cannot submit an adoption request for your own pet.' });
    }

    // Check if request already exists
    const existing = await AdoptionRequest.findOne({
      where: { user_id: userId, pet_id }
    });

    if (existing) {
      return res.status(400).json({ error: 'You have already submitted an adoption request for this pet.' });
    }

    const request = await AdoptionRequest.create({
      user_id: userId,
      pet_id,
      message,
      status: 'pending'
    });

    const detailedRequest = await AdoptionRequest.findByPk(request.id, {
      include: [
        {
          model: Pet,
          as: 'pet',
          include: [{ model: User, as: 'owner', attributes: ['id', 'name', 'email'] }]
        }
      ]
    });

    res.status(201).json(detailedRequest);
  } catch (error) {
    next(error);
  }
};

exports.updateStatus = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { status } = req.body; // 'approved', 'completed', 'rejected'

    if (!['approved', 'completed', 'rejected'].includes(status)) {
      return res.status(400).json({ error: 'Invalid status value.' });
    }

    const request = await AdoptionRequest.findByPk(id, {
      include: [{ model: Pet, as: 'pet' }]
    });

    if (!request) {
      return res.status(404).json({ error: 'Adoption request not found.' });
    }

    // Only the owner of the pet can approve or reject the request
    if (request.pet.owner_id !== req.user.id) {
      return res.status(403).json({ error: 'You are not authorized to update this request status.' });
    }

    request.status = status;
    await request.save();

    // If status is completed/approved, mark pet as adopted
    if (status === 'completed' || status === 'approved') {
      const pet = request.pet;
      pet.is_adopted = true;
      await pet.save();

      // Automatically reject other pending requests for the same pet
      await AdoptionRequest.update(
        { status: 'rejected' },
        {
          where: {
            pet_id: pet.id,
            status: 'pending'
          }
        }
      );
    }

    const updatedRequest = await AdoptionRequest.findByPk(request.id, {
      include: [
        { model: Pet, as: 'pet' },
        { model: User, as: 'requester', attributes: ['id', 'name', 'email', 'phone'] }
      ]
    });

    res.json(updatedRequest);
  } catch (error) {
    next(error);
  }
};
