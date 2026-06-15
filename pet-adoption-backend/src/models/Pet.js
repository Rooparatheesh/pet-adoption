const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Pet = sequelize.define('Pet', {
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false
  },
  breed: {
    type: DataTypes.STRING,
    allowNull: false
  },
  age: {
    type: DataTypes.INTEGER, // Age in months
    allowNull: false
  },
  gender: {
    type: DataTypes.STRING,
    allowNull: false
  },
  size: {
    type: DataTypes.STRING,
    allowNull: false
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  image_url: {
    type: DataTypes.TEXT, // Using TEXT in case of long base64 strings or URLs
    allowNull: true
  },
  location: {
    type: DataTypes.STRING,
    allowNull: false
  },
  is_adopted: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  },
  category_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  owner_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  }
}, {
  tableName: 'pets',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: false // We don't need updatedAt for pets unless requested
});

module.exports = Pet;
