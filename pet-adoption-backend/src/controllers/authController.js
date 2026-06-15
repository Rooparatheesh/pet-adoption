const { User } = require('../models');
const jwt = require('jsonwebtoken');

const generateToken = (userId) => {
  return jwt.sign(
    { id: userId },
    process.env.JWT_SECRET || 'supersecretpetadoptionappkey123!',
    { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
  );
};

exports.register = async (req, res, next) => {
  try {
    const { name, email, password, phone, avatar_url } = req.body;

    const existingUser = await User.findOne({ where: { email } });
    if (existingUser) {
      return res.status(400).json({ error: 'Email already in use.' });
    }

    const user = await User.create({
      name,
      email,
      password,
      phone,
      avatar_url
    });

    const token = generateToken(user.id);
    const userJson = user.toJSON();
    delete userJson.password;

    res.status(201).json({
      message: 'Registration successful.',
      token,
      user: userJson
    });
  } catch (error) {
    next(error);
  }
};

exports.login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    const user = await User.findOne({ where: { email } });
    if (!user || !(await user.comparePassword(password))) {
      return res.status(401).json({ error: 'Invalid email or password.' });
    }

    const token = generateToken(user.id);
    const userJson = user.toJSON();
    delete userJson.password;

    res.json({
      message: 'Login successful.',
      token,
      user: userJson
    });
  } catch (error) {
    next(error);
  }
};

exports.getProfile = async (req, res, next) => {
  try {
    const userJson = req.user.toJSON();
    delete userJson.password;
    res.json({ user: userJson });
  } catch (error) {
    next(error);
  }
};

exports.updateProfile = async (req, res, next) => {
  try {
    const { name, phone, avatar_url, password } = req.body;

    const user = req.user;
    if (name) user.name = name;
    if (phone !== undefined) user.phone = phone;
    if (avatar_url !== undefined) user.avatar_url = avatar_url;
    if (password) user.password = password;

    await user.save();

    const userJson = user.toJSON();
    delete userJson.password;

    res.json({
      message: 'Profile updated successfully.',
      user: userJson
    });
  } catch (error) {
    next(error);
  }
};
