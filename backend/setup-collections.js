// Script to create all required collections for UniLink Ethiopia
require('dotenv').config();
const { MongoClient } = require('mongodb');

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/unilink';

async function setupCollections() {
    let client;
    
    try {
        console.log('🔌 Connecting to MongoDB...');
        client = await MongoClient.connect(MONGODB_URI);
        const db = client.db();
        
        console.log(`📊 Database: ${db.databaseName}`);
        console.log('\n📋 Checking existing collections...');
        
        // Get existing collections
        const existingCollections = await db.listCollections().toArray();
        const existingNames = existingCollections.map(c => c.name);
        console.log('Existing collections:', existingNames.join(', '));
        
        // Required collections
        const requiredCollections = [
            'users',
            'posts',
            'likes',
            'comments',
            'marketplaceItems',
            'messages',
            'chatMessages',
            'notifications'
        ];
        
        console.log('\n🔧 Setting up collections...\n');
        
        for (const collectionName of requiredCollections) {
            const exists = existingNames.includes(collectionName);
            
            if (exists) {
                const count = await db.collection(collectionName).countDocuments();
                console.log(`✅ ${collectionName} - exists (${count} documents)`);
            } else {
                // Create collection by inserting an empty document and deleting it
                await db.collection(collectionName).insertOne({ _temp: true });
                await db.collection(collectionName).deleteOne({ _temp: true });
                console.log(`✨ ${collectionName} - created`);
            }
        }
        
        // Handle migration: if 'listings' exists, rename to 'marketplaceItems'
        if (existingNames.includes('listings') && !existingNames.includes('marketplaceItems')) {
            console.log('\n🔄 Migrating "listings" to "marketplaceItems"...');
            const listings = await db.collection('listings').find({}).toArray();
            if (listings.length > 0) {
                await db.collection('marketplaceItems').insertMany(listings);
                console.log(`✅ Migrated ${listings.length} items from "listings" to "marketplaceItems"`);
            }
        }
        
        // Create indexes for better performance
        console.log('\n📇 Creating indexes...');
        
        // Users indexes
        await db.collection('users').createIndex({ universityEmail: 1 }, { unique: true, sparse: true });
        await db.collection('users').createIndex({ studentId: 1 }, { unique: true, sparse: true });
        console.log('✅ Users indexes created');
        
        // Posts indexes
        await db.collection('posts').createIndex({ userId: 1 });
        await db.collection('posts').createIndex({ createdAt: -1 });
        console.log('✅ Posts indexes created');
        
        // Likes indexes
        await db.collection('likes').createIndex({ postId: 1, userId: 1 }, { unique: true });
        await db.collection('likes').createIndex({ postId: 1 });
        console.log('✅ Likes indexes created');
        
        // Comments indexes
        await db.collection('comments').createIndex({ postId: 1 });
        await db.collection('comments').createIndex({ createdAt: 1 });
        console.log('✅ Comments indexes created');
        
        // Marketplace indexes
        await db.collection('marketplaceItems').createIndex({ sellerId: 1 });
        await db.collection('marketplaceItems').createIndex({ category: 1 });
        await db.collection('marketplaceItems').createIndex({ isActive: 1 });
        console.log('✅ Marketplace indexes created');
        
        // Chat messages indexes
        await db.collection('chatMessages').createIndex({ senderId: 1, receiverId: 1 });
        await db.collection('chatMessages').createIndex({ timestamp: -1 });
        console.log('✅ Chat messages indexes created');
        
        // Notifications indexes
        await db.collection('notifications').createIndex({ userId: 1 });
        await db.collection('notifications').createIndex({ timestamp: -1 });
        await db.collection('notifications').createIndex({ isRead: 1 });
        console.log('✅ Notifications indexes created');
        
        console.log('\n✅ All collections set up successfully!');
        console.log('\n📊 Final collection list:');
        const finalCollections = await db.listCollections().toArray();
        for (const col of finalCollections) {
            const count = await db.collection(col.name).countDocuments();
            console.log(`   - ${col.name}: ${count} documents`);
        }
        
    } catch (error) {
        console.error('❌ Error setting up collections:', error.message);
        process.exit(1);
    } finally {
        if (client) {
            await client.close();
            console.log('\n🔌 Connection closed');
        }
    }
}

setupCollections();



