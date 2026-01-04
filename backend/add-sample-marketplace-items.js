// Script to add sample marketplace items
require('dotenv').config();
const { MongoClient } = require('mongodb');

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/unilink';

const sampleItems = [
    {
        sellerId: '1',
        title: 'Calculus Textbook - 3rd Edition',
        description: 'Like new condition, used for one semester only. No markings or highlights.',
        price: 250,
        category: 'Books',
        condition: 'Like New',
        isNegotiable: true,
        isActive: true,
        imageUrl: null,
        postedDate: new Date()
    },
    {
        sellerId: '1',
        title: 'Laptop - HP Pavilion',
        description: 'Good working condition, 8GB RAM, 256GB SSD. Perfect for students.',
        price: 8500,
        category: 'Electronics',
        condition: 'Good',
        isNegotiable: true,
        isActive: true,
        imageUrl: null,
        postedDate: new Date()
    },
    {
        sellerId: '1',
        title: 'Study Desk',
        description: 'Wooden study desk with drawer. Good condition, moving out sale.',
        price: 1200,
        category: 'Furniture',
        condition: 'Good',
        isNegotiable: false,
        isActive: true,
        imageUrl: null,
        postedDate: new Date()
    },
    {
        sellerId: '1',
        title: 'Physics Lab Manual',
        description: 'Complete physics lab manual, all experiments included.',
        price: 150,
        category: 'Books',
        condition: 'Fair',
        isNegotiable: true,
        isActive: true,
        imageUrl: null,
        postedDate: new Date()
    },
    {
        sellerId: '1',
        title: 'Smartphone - Samsung Galaxy',
        description: 'Used smartphone, good condition, comes with charger.',
        price: 3500,
        category: 'Electronics',
        condition: 'Good',
        isNegotiable: true,
        isActive: true,
        imageUrl: null,
        postedDate: new Date()
    },
    {
        sellerId: '1',
        title: 'Office Chair',
        description: 'Comfortable office chair, adjustable height, good for studying.',
        price: 800,
        category: 'Furniture',
        condition: 'Like New',
        isNegotiable: true,
        isActive: true,
        imageUrl: null,
        postedDate: new Date()
    },
    {
        sellerId: '1',
        title: 'Chemistry Reference Book',
        description: 'Organic chemistry reference book, comprehensive guide.',
        price: 300,
        category: 'Books',
        condition: 'New',
        isNegotiable: false,
        isActive: true,
        imageUrl: null,
        postedDate: new Date()
    },
    {
        sellerId: '1',
        title: 'Tablet - iPad',
        description: 'iPad for note-taking and studying, comes with stylus.',
        price: 12000,
        category: 'Electronics',
        condition: 'Like New',
        isNegotiable: true,
        isActive: true,
        imageUrl: null,
        postedDate: new Date()
    }
];

async function addSampleItems() {
    let client;
    
    try {
        console.log('🔌 Connecting to MongoDB...');
        client = await MongoClient.connect(MONGODB_URI);
        const db = client.db();
        
        console.log(`📊 Database: ${db.databaseName}`);
        
        // Check if items already exist
        const existingCount = await db.collection('marketplaceItems').countDocuments();
        if (existingCount > 0) {
            console.log(`⚠️  Found ${existingCount} existing items. Skipping...`);
            console.log('💡 To add sample items, delete existing items first or modify this script.');
            return;
        }
        
        console.log('\n📦 Adding sample marketplace items...\n');
        
        const result = await db.collection('marketplaceItems').insertMany(sampleItems);
        
        console.log(`✅ Added ${result.insertedCount} sample items!`);
        console.log('\n📋 Items by category:');
        
        const categories = await db.collection('marketplaceItems').aggregate([
            { $group: { _id: '$category', count: { $sum: 1 } } },
            { $sort: { _id: 1 } }
        ]).toArray();
        
        categories.forEach(cat => {
            console.log(`   - ${cat._id}: ${cat.count} items`);
        });
        
        console.log('\n✅ Sample marketplace items added successfully!');
        
    } catch (error) {
        console.error('❌ Error adding sample items:', error.message);
        process.exit(1);
    } finally {
        if (client) {
            await client.close();
            console.log('\n🔌 Connection closed');
        }
    }
}

addSampleItems();



