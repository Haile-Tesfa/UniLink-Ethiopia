# Quick Start Guide - UniLink Ethiopia

## 🚀 Fast Setup (5 Minutes)

### 1. Clone Repository
```bash
git clone https://github.com/Haile-Tesfa/UniLink-Ethiopia.git
cd UniLink-Ethiopia
```

### 2. Setup MongoDB
- Install [MongoDB Compass](https://www.mongodb.com/try/download/compass)
- Connect to `mongodb://localhost:27017`
- Create database: `unilink`

### 3. Setup Backend
```bash
cd backend
npm install
```

Create `backend/.env`:
```env
MONGODB_URI=mongodb://localhost:27017/unilink
PORT=5000
```

Start server:
```bash
npm start
```

### 4. Configure Flutter App
Edit `lib/utils/constants.dart`:
```dart
static const String apiBaseUrl = 'http://YOUR_COMPUTER_IP:5000';
```

Find your IP:
- **Windows**: `ipconfig` → Look for IPv4 Address
- **Mac/Linux**: `ifconfig` → Look for inet address

### 5. Build APK
```bash
cd ..  # Back to project root
flutter pub get
flutter build apk --release
```

APK location: `build/app/outputs/flutter-apk/app-release.apk`

### 6. Install on Phone
1. Transfer APK to phone
2. Enable "Install from Unknown Sources"
3. Install APK
4. **Make sure phone and computer are on same Wi-Fi!**

---

## 📝 Important Notes

- ✅ Backend must be running (`npm start` in backend folder)
- ✅ Phone and computer must be on same Wi-Fi network
- ✅ Update `apiBaseUrl` with your actual IP address
- ✅ MongoDB must be running (if using local MongoDB)

---

## 🔧 Common Issues

**"Cannot connect to server"**
→ Check backend is running and IP address is correct

**"MongoDB connection error"**
→ Verify MongoDB is running and connection string is correct

**APK won't install**
→ Enable "Install from Unknown Sources" in phone settings

---

For detailed instructions, see [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)



