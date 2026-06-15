const sequelize = require('../config/database');
const User = require('./User');
const Category = require('./Category');
const Pet = require('./Pet');
const Favorite = require('./Favorite');
const AdoptionRequest = require('./AdoptionRequest');

// Associations

// User -> Pet (listings)
User.hasMany(Pet, { foreignKey: 'owner_id', as: 'listedPets' });
Pet.belongsTo(User, { foreignKey: 'owner_id', as: 'owner' });

// Category -> Pet
Category.hasMany(Pet, { foreignKey: 'category_id', as: 'pets' });
Pet.belongsTo(Category, { foreignKey: 'category_id', as: 'category' });

// User -> Favorite
User.hasMany(Favorite, { foreignKey: 'user_id', as: 'favorites' });
Favorite.belongsTo(User, { foreignKey: 'user_id' });

// Pet -> Favorite
Pet.hasMany(Favorite, { foreignKey: 'pet_id', as: 'favoritedBy' });
Favorite.belongsTo(Pet, { foreignKey: 'pet_id', as: 'pet' });

// User -> AdoptionRequest
User.hasMany(AdoptionRequest, { foreignKey: 'user_id', as: 'adoptionRequests' });
AdoptionRequest.belongsTo(User, { foreignKey: 'user_id', as: 'requester' });

// Pet -> AdoptionRequest
Pet.hasMany(AdoptionRequest, { foreignKey: 'pet_id', as: 'adoptionRequests' });
AdoptionRequest.belongsTo(Pet, { foreignKey: 'pet_id', as: 'pet' });

module.exports = {
  sequelize,
  User,
  Category,
  Pet,
  Favorite,
  AdoptionRequest
};
