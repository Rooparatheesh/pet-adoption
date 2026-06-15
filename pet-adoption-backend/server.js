const express = require('express');
const cors = require('cors');
const { Client } = require('pg');
require('dotenv').config();

const { sequelize } = require('./src/models');
const apiRoutes = require('./src/routes');
const errorHandler = require('./src/middleware/errorHandler');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Test Route
app.get('/', (req, res) => {
  res.json({ message: 'Welcome to the Pet Adoption API' });
});

// API Routes
app.use('/api', apiRoutes);

// Global Error Handler
app.use(errorHandler);

// Function to ensure database exists before Sequelize connects to it
async function ensureDatabaseExists() {
  const dbName = process.env.DB_NAME || 'pet_adoption';
  const client = new Client({
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5432,
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || 'postgres',
    database: 'postgres' // Connect to default database
  });

  try {
    await client.connect();
    const res = await client.query('SELECT 1 FROM pg_database WHERE datname = $1', [dbName]);
    if (res.rowCount === 0) {
      console.log(`Database "${dbName}" does not exist. Creating it...`);
      // Run raw query to create database
      await client.query(`CREATE DATABASE "${dbName}"`);
      console.log(`Database "${dbName}" created successfully.`);
    } else {
      console.log(`Database "${dbName}" already exists.`);
    }
  } catch (err) {
    console.error('Database pre-check error:', err.message);
    console.log('Attempting to proceed with Sequelize connection anyway...');
  } finally {
    await client.end();
  }
}

// Start Server
async function startServer() {
  try {
    // 1. Ensure database exists
    await ensureDatabaseExists();

    // 2. Authenticate Sequelize connection
    await sequelize.authenticate();
    console.log('Database connection has been established successfully.');

    // 3. Sync models (alter table structures if they change in development)
    await sequelize.sync({ alter: true });
    console.log('Database synchronized.');

    // 4. Start listening
    app.listen(PORT, () => {
      console.log(`Server is running on port ${PORT}`);
    });
  } catch (error) {
    console.error('Unable to start the server:', error);
    process.exit(1);
  }
}

startServer();
