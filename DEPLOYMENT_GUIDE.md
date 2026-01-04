# UniLink Ethiopia - Complete Deployment Guide

This guide will help you set up, configure, build, and deploy the UniLink Ethiopia mobile application with MongoDB.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Cloning the Repository](#cloning-the-repository)
3. [Setting Up MongoDB](#setting-up-mongodb)
4. [Backend Setup](#backend-setup)
5. [Flutter App Configuration](#flutter-app-configuration)
6. [Building APK](#building-apk)
7. [Deployment](#deployment)
8. [Pushing Changes to GitHub](#pushing-changes-to-github)
9. [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before you begin, ensure you have the following installed:

- **Node.js** (v14 or higher) - [Download](https://nodejs.org/)
- **MongoDB Compass** or MongoDB Server - [Download](https://www.mongodb.com/try/download/compass)
- **Flutter SDK** (latest stable version) - [Download](https://flutter.dev/docs/get-started/install)
- **Android Studio** (for building APK) - [Download](https://developer.android.com/studio)
- **Git** - [Download](https://git-scm.com/downloads)
- **VS Code** (recommended) or any code editor

---

## Cloning the Repository

### Step 1: Clone from GitHub

Open your terminal/command prompt and run:

```bash
git clone https://github.com/Haile-Tesfa/UniLink-Ethiopia.git
cd UniLink-Ethiopia
```

### Step 2: Verify the Clone

Check that all files are present:

```bash
# Windows
dir

# Linux/Mac
ls -la
```

You should see folders like `backend`, `lib`, `android`, `ios`, etc.

---

## Setting Up MongoDB

### Option 1: MongoDB Compass (Recommended for Local Development)

1. **Install MongoDB Compass** from [mongodb.com/try/download/compass](https://www.mongodb.com/try/download/compass)

2. **Open MongoDB Compass** and connect to:
   - **Local MongoDB**: `mongodb://localhost:27017`
   - Or click "Connect" if MongoDB is running locally

3. **Create a Database**:
   - Click "Create Database"
   - Database Name: `unilink`
   - Collection Name: `users` (or any name, MongoDB will create collections automatically)

4. **Note Your Connection String**:
   - For local: `mongodb://localhost:27017/unilink`
   - For MongoDB Atlas (cloud): `mongodb+srv://username:password@cluster.mongodb.net/unilink`

### Option 2: MongoDB Atlas (Cloud - Recommended for Production)

1. Go to [mongodb.com/cloud/atlas](https://www.mongodb.com/cloud/atlas)
2. Create a free account
3. Create a new cluster
4. Get your connection string (format: `mongodb+srv://username:password@cluster.mongodb.net/unilink`)

---

## Backend Setup

### Step 1: Navigate to Backend Directory

```bash
cd backend
```

### Step 2: Install Dependencies

```bash
npm install
```

This will install:
- express
- mongodb
- cors
- dotenv
- multer

### Step 3: Create Environment File

Create a `.env` file in the `backend` directory:

**Windows (PowerShell):**
```powershell
cd backend
New-Item -Path .env -ItemType File
```

**Linux/Mac:**
```bash
cd backend
touch .env
```

### Step 4: Configure Environment Variables

Open `.env` and add:

```env
# MongoDB Connection String
# For local MongoDB Compass:
MONGODB_URI=mongodb://localhost:27017/unilink

# For MongoDB Atlas (cloud):
# MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/unilink

# Server Port
PORT=5000

# Server Host (use 0.0.0.0 to accept connections from any IP)
HOST=0.0.0.0
```

**Important**: Replace `username` and `password` with your actual MongoDB credentials if using Atlas.

### Step 5: Start the Backend Server

```bash
npm start
```

You should see:
```
Connected to MongoDB
UniLink backend running on port 5000
MongoDB URI: mongodb://localhost:27017/unilink
```

**Keep this terminal open** - the server must be running for the app to work.

### Step 6: Find Your Server IP Address

You need your computer's IP address so the mobile app can connect to it.

**Windows:**
```powershell
ipconfig
```
Look for "IPv4 Address" (e.g., `192.168.1.100`)

**Linux/Mac:**
```bash
ifconfig
# or
ip addr show
```

**Note the IP address** - you'll need it in the next section.

---

## Flutter App Configuration

### Step 1: Navigate to Project Root

```bash
cd ..  # Go back to project root (UniLink-Ethiopia)
```

### Step 2: Install Flutter Dependencies

```bash
flutter pub get
```

### Step 3: Configure API URL

Open `lib/utils/constants.dart` and update the API base URL:

```dart
// Change this line:
static const String apiBaseUrl = 'http://YOUR_SERVER_IP:5000';

// To your actual server IP, for example:
static const String apiBaseUrl = 'http://192.168.1.100:5000';
```

**Important Notes:**
- Replace `YOUR_SERVER_IP` with your computer's IP address (from Step 6 above)
- Use `http://` (not `https://`) for local development
- For production, use your domain name: `https://yourdomain.com`
- Make sure your phone and computer are on the **same Wi-Fi network**

### Step 4: Verify Configuration

Check that all screens are using `AppConstants.apiBaseUrl` (they should be after our updates).

---

## Building APK

### Step 1: Check Flutter Setup

```bash
flutter doctor
```

Fix any issues shown.

### Step 2: Build APK

**For Debug APK (testing):**
```bash
flutter build apk --debug
```

**For Release APK (production):**
```bash
flutter build apk --release
```

The APK will be created at:
- **Debug**: `build/app/outputs/flutter-apk/app-debug.apk`
- **Release**: `build/app/outputs/flutter-apk/app-release.apk`

### Step 3: Install APK on Phone

1. Transfer the APK file to your phone (via USB, email, or cloud storage)
2. On your phone, enable "Install from Unknown Sources" in Settings
3. Open the APK file and install

---

## Deployment

### Local Network Deployment (For Testing)

1. **Start MongoDB** (if using local MongoDB)
2. **Start Backend Server**:
   ```bash
   cd backend
   npm start
   ```
3. **Ensure phone and computer are on same Wi-Fi**
4. **Update API URL** in `lib/utils/constants.dart` with your computer's IP
5. **Build and install APK** on your phone
6. **Test the app** - it should connect to your backend

### Production Deployment

#### Option 1: Deploy Backend to Cloud (Recommended)

**Using Heroku:**
1. Create account at [heroku.com](https://www.heroku.com)
2. Install Heroku CLI
3. In `backend` directory:
   ```bash
   heroku create unilink-backend
   heroku config:set MONGODB_URI=your_mongodb_atlas_connection_string
   git push heroku main
   ```
4. Update `lib/utils/constants.dart` with Heroku URL:
   ```dart
   static const String apiBaseUrl = 'https://unilink-backend.herokuapp.com';
   ```

**Using Railway, Render, or DigitalOcean:**
- Similar process - deploy Node.js app and set environment variables

#### Option 2: Use MongoDB Atlas + Deploy Backend

1. Use MongoDB Atlas (cloud) instead of local MongoDB
2. Deploy backend to cloud service (Heroku, Railway, etc.)
3. Update Flutter app with cloud backend URL
4. Build and distribute APK

---

## Pushing Changes to GitHub

### Step 1: Check Current Status

```bash
git status
```

This shows which files have been modified.

### Step 2: Add Changes

```bash
# Add all changes
git add .

# Or add specific files
git add backend/server.js
git add lib/utils/constants.dart
```

### Step 3: Commit Changes

```bash
git commit -m "Convert SQL to MongoDB and fix deployment configuration"
```

### Step 4: Push to GitHub

```bash
git push origin main
```

**If you get authentication errors:**
- Use Personal Access Token instead of password
- Or set up SSH keys

### Step 5: Verify on GitHub

Go to [github.com/Haile-Tesfa/UniLink-Ethiopia](https://github.com/Haile-Tesfa/UniLink-Ethiopia) and verify your changes are there.

---

## Troubleshooting

### Problem: "Cannot connect to server" on Phone

**Solutions:**
1. ✅ Check backend server is running (`npm start` in backend folder)
2. ✅ Verify API URL in `lib/utils/constants.dart` matches your computer's IP
3. ✅ Ensure phone and computer are on same Wi-Fi network
4. ✅ Check Windows Firewall - allow Node.js through firewall
5. ✅ Try accessing `http://YOUR_IP:5000/api/posts` in phone's browser

### Problem: MongoDB Connection Error

**Solutions:**
1. ✅ Check MongoDB is running (if local)
2. ✅ Verify `MONGODB_URI` in `.env` file is correct
3. ✅ For Atlas, check IP whitelist (allow all IPs: `0.0.0.0/0`)
4. ✅ Verify username/password in connection string

### Problem: APK Installation Fails

**Solutions:**
1. ✅ Enable "Install from Unknown Sources" in phone settings
2. ✅ Check Android version compatibility
3. ✅ Try building debug APK first: `flutter build apk --debug`

### Problem: Git Push Fails

**Solutions:**
1. ✅ Check you have write access to repository
2. ✅ Use Personal Access Token (not password) for GitHub
3. ✅ Pull latest changes first: `git pull origin main`
4. ✅ Resolve merge conflicts if any

### Problem: Backend Crashes

**Solutions:**
1. ✅ Check MongoDB connection string
2. ✅ Verify all dependencies installed: `npm install`
3. ✅ Check port 5000 is not in use by another app
4. ✅ Review error messages in terminal

---

## Quick Reference

### Important Files

- **Backend Server**: `backend/server.js`
- **Backend Config**: `backend/.env`
- **Flutter API Config**: `lib/utils/constants.dart`
- **Package Dependencies**: `backend/package.json`, `pubspec.yaml`

### Common Commands

```bash
# Start backend
cd backend && npm start

# Install Flutter dependencies
flutter pub get

# Build APK
flutter build apk --release

# Check Git status
git status

# Push to GitHub
git add .
git commit -m "Your message"
git push origin main
```

### Default Ports

- **Backend**: `5000`
- **MongoDB**: `27017`

---

## Support

If you encounter issues:
1. Check the Troubleshooting section above
2. Review error messages carefully
3. Ensure all prerequisites are installed
4. Verify network connectivity

---

## Summary of Changes Made

✅ **Database**: Converted from SQL Server to MongoDB
✅ **Backend**: Updated all queries to use MongoDB
✅ **API URLs**: Centralized in `constants.dart` for easy configuration
✅ **Deployment**: Fixed server connection issues
✅ **Documentation**: Complete setup and deployment guide

---

**Last Updated**: January 2026
**Version**: 2.0 (MongoDB Edition)



