const { Client } = require('pg');
require('dotenv').config();

const categoriesData = [
  { name: 'Dogs', icon: 'dog' },
  { name: 'Cats', icon: 'cat' },
  { name: 'Birds', icon: 'bird' },
  { name: 'Rabbits', icon: 'rabbit' },
  { name: 'Fish', icon: 'fish' }
];

const petsData = [
  // Dogs (Category 1)
  {
    name: 'Max',
    breed: 'Golden Retriever',
    age: 12, // 1 year
    gender: 'Male',
    size: 'Large',
    description: 'Max is an energetic and extremely friendly Golden Retriever. He loves playing fetch, swimming, and is great with kids and other pets. Vaccinated and house-trained.',
    image_url: 'https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&q=80&w=600',
    location: 'Seattle, WA',
    is_adopted: false
  },
  {
    name: 'Bella',
    breed: 'German Shepherd',
    age: 24, // 2 years
    gender: 'Female',
    size: 'Large',
    description: 'Bella is a highly intelligent and protective German Shepherd. She is quick to learn new tricks, loves outdoor runs, and would make a wonderful loyal companion.',
    image_url: 'https://images.unsplash.com/photo-1589941013453-ec89f33b5e95?auto=format&fit=crop&q=80&w=600',
    location: 'Portland, OR',
    is_adopted: false
  },
  {
    name: 'Rocky',
    breed: 'Pug',
    age: 8, // 8 months
    gender: 'Male',
    size: 'Small',
    description: 'Rocky is a goofy, playful Pug puppy who loves cuddles. He is very social, likes being the center of attention, and snores like a tiny chainsaw when asleep.',
    image_url: 'https://images.unsplash.com/photo-1517849845537-4d257902454a?auto=format&fit=crop&q=80&w=600',
    location: 'San Francisco, CA',
    is_adopted: false
  },
  {
    name: 'Luna',
    breed: 'Siberian Husky',
    age: 18, // 1.5 years
    gender: 'Female',
    size: 'Medium',
    description: 'Luna is a gorgeous Husky with striking blue eyes. She has a sweet temperament, enjoys long walks in cool weather, and is very talkative! Needs an active owner.',
    image_url: 'https://images.unsplash.com/photo-1531804055935-76f44d7c3621?auto=format&fit=crop&q=80&w=600',
    location: 'Denver, CO',
    is_adopted: false
  },
  
  // Cats (Category 2)
  {
    name: 'Milo',
    breed: 'Siamese',
    age: 6, // 6 months
    gender: 'Male',
    size: 'Small',
    description: 'Milo is a curious Siamese kitten who loves investigating everything. He is very vocal, friendly, and enjoys sitting on shoulders while you work.',
    image_url: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?auto=format&fit=crop&q=80&w=600',
    location: 'Los Angeles, CA',
    is_adopted: false
  },
  {
    name: 'Oliver',
    breed: 'British Shorthair',
    age: 36, // 3 years
    gender: 'Male',
    size: 'Medium',
    description: 'Oliver is a calm and independent British Shorthair. He has a gorgeous plush blue coat and enjoys lounging in sunny spots. Low maintenance and perfect for apartment living.',
    image_url: 'https://images.unsplash.com/photo-1513360309081-36f5e878fc9e?auto=format&fit=crop&q=80&w=600',
    location: 'Boston, MA',
    is_adopted: false
  },
  {
    name: 'Chloe',
    breed: 'Calico Cat',
    age: 14,
    gender: 'Female',
    size: 'Medium',
    description: 'Chloe is a beautiful Calico cat who is extremely affectionate. She loves chin scratches, lap naps, and has a very sweet, soft purr.',
    image_url: 'https://images.unsplash.com/photo-1573865526739-10659fec78a5?auto=format&fit=crop&q=80&w=600',
    location: 'Austin, TX',
    is_adopted: false
  },

  // Birds (Category 3)
  {
    name: 'Charlie',
    breed: 'Macaw Parrot',
    age: 48, // 4 years
    gender: 'Male',
    size: 'Large',
    description: 'Charlie is a brilliant, colorful Macaw who can mimic several words and sounds. He is very social and needs a spacious cage and plenty of interaction.',
    image_url: 'https://images.unsplash.com/photo-1552728089-57bdde30ebd3?auto=format&fit=crop&q=80&w=600',
    location: 'Miami, FL',
    is_adopted: false
  },
  {
    name: 'Sunny',
    breed: 'Cockatiel',
    age: 12,
    gender: 'Male',
    size: 'Small',
    description: 'Sunny is a cheerful yellow Cockatiel who loves to whistle tunes. He is hand-tame, enjoys landing on fingers, and loves eating millet treats.',
    image_url: 'https://images.unsplash.com/photo-1522850959516-58f958dba611?auto=format&fit=crop&q=80&w=600',
    location: 'Phoenix, AZ',
    is_adopted: false
  },

  // Rabbits (Category 4)
  {
    name: 'Thumper',
    breed: 'Angora Rabbit',
    age: 10,
    gender: 'Female',
    size: 'Small',
    description: 'Thumper is an incredibly fluffy Angora rabbit. She is gentle, loves eating fresh carrots and parsley, and enjoys being groomed. Perfect indoor rabbit.',
    image_url: 'https://images.unsplash.com/photo-1585110396000-c9ffd4e4b308?auto=format&fit=crop&q=80&w=600',
    location: 'Chicago, IL',
    is_adopted: false
  },

  // Fish (Category 5)
  {
    name: 'Bubbles',
    breed: 'Fancy Goldfish',
    age: 4,
    gender: 'Female',
    size: 'Small',
    description: 'Bubbles is a lively Fancy Goldfish with a beautiful fan tail. She is active, fun to watch swim around, and comes to the front of the tank when it is feeding time.',
    image_url: 'https://images.unsplash.com/photo-1522069169874-c58ec4b76be5?auto=format&fit=crop&q=80&w=600',
    location: 'Seattle, WA',
    is_adopted: false
  },
  {
    name: 'Shadow',
    breed: 'Betta Fish',
    age: 5,
    gender: 'Male',
    size: 'Small',
    description: 'Shadow is a striking blue and red Crowntail Betta fish. He is healthy, active, and has gorgeous flowing fins. Must be housed in a single-specimen tank.',
    image_url: 'https://images.unsplash.com/photo-1534043464124-3be32fe000c9?auto=format&fit=crop&q=80&w=600',
    location: 'Dallas, TX',
    is_adopted: false
  }
];

async function ensureDatabaseExists() {
  const dbName = process.env.DB_NAME || 'pet_adoption';
  const client = new Client({
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5432,
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || 'postgres',
    database: 'postgres'
  });

  try {
    await client.connect();
    const res = await client.query('SELECT 1 FROM pg_database WHERE datname = $1', [dbName]);
    if (res.rowCount === 0) {
      console.log(`Database "${dbName}" does not exist. Creating it...`);
      await client.query(`CREATE DATABASE "${dbName}"`);
      console.log(`Database "${dbName}" created successfully.`);
    }
  } catch (err) {
    console.error('Database pre-check error:', err.message);
  } finally {
    await client.end();
  }
}

async function seed() {
  try {
    // 1. Ensure database exists
    await ensureDatabaseExists();

    // 2. Now import models dynamically after DB is created
    const { sequelize, User, Category, Pet } = require('../models');

    // 3. Sync database (force drops existing tables for a clean seed)
    await sequelize.sync({ force: true });
    console.log('Database tables cleared and synchronized.');

    // 4. Create seed users
    const jane = await User.create({
      name: 'Jane Doe',
      email: 'jane@example.com',
      password: 'password123',
      phone: '+1 555-0199',
      avatar_url: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=200'
    });

    const john = await User.create({
      name: 'John Smith',
      email: 'john@example.com',
      password: 'password123',
      phone: '+1 555-0144',
      avatar_url: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=200'
    });
    console.log('Mock users created.');

    // 5. Create categories
    const categories = await Category.bulkCreate(categoriesData);
    console.log('Categories seeded successfully.');

    // Map categories by name to get their IDs
    const categoryMap = {};
    categories.forEach(cat => {
      categoryMap[cat.name] = cat.id;
    });

    // 6. Create pets and assign category IDs and owner ID (Jane is the owner of all seeded pets)
    const petsWithForeignKeys = petsData.map(pet => {
      let categoryName = 'Dogs'; // Default fallback
      if (pet.breed === 'Siamese' || pet.breed === 'British Shorthair' || pet.breed === 'Calico Cat') {
        categoryName = 'Cats';
      } else if (pet.breed === 'Macaw Parrot' || pet.breed === 'Cockatiel') {
        categoryName = 'Birds';
      } else if (pet.breed === 'Angora Rabbit') {
        categoryName = 'Rabbits';
      } else if (pet.breed === 'Fancy Goldfish' || pet.breed === 'Betta Fish') {
        categoryName = 'Fish';
      }

      return {
        ...pet,
        category_id: categoryMap[categoryName],
        owner_id: jane.id
      };
    });

    await Pet.bulkCreate(petsWithForeignKeys);
    console.log('Pet listings seeded successfully.');

    console.log('Database seeding finished successfully!');
    process.exit(0);
  } catch (error) {
    console.error('Seeding error:', error);
    process.exit(1);
  }
}

seed();
