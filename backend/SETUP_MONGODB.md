# Quick MongoDB Setup Guide

## Option 1: MongoDB Atlas (Cloud - Easiest) ⭐ RECOMMENDED

1. **Sign up**: Go to https://www.mongodb.com/cloud/atlas/register
2. **Create cluster**: Click "Build a Database" → Choose FREE tier
3. **Create database user**: 
   - Go to "Database Access"
   - Add new user, set username and password
4. **Whitelist IP**: 
   - Go to "Network Access"
   - Click "Add IP Address"
   - Click "Allow Access from Anywhere" (for testing)
5. **Get connection string**:
   - Go to "Database" → Click "Connect"
   - Choose "Connect your application"
   - Copy the connection string
   - Replace `<password>` with your database user password
6. **Update .env file**:
   ```
   MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/unilink
   ```

## Option 2: MongoDB Compass (Local)

1. **Download**: https://www.mongodb.com/try/download/compass
2. **Install** MongoDB Compass
3. **Open** MongoDB Compass
4. **Connect** to: `mongodb://localhost:27017`
5. **Create database**: Click "Create Database"
   - Database name: `unilink`
   - Collection name: `users` (or any name)

## After Setup

Restart your backend server:
```bash
cd backend
node server.js
```

You should see: `✅ Connected to MongoDB`



