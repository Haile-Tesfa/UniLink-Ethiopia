# UniLink Ethiopia

A university social network mobile application built with Flutter and Node.js, connecting students across Ethiopian universities.

## 🎯 Features

- **Social Feed**: Share posts, images, and updates
- **Marketplace**: Buy and sell items within the university community
- **Messaging**: Real-time chat with other students
- **Notifications**: Stay updated with activity on your posts
- **User Profiles**: Showcase your university journey

## 🛠️ Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Node.js (Express)
- **Database**: MongoDB
- **File Storage**: Local file system (uploads folder)

## 📋 Prerequisites

- Node.js (v14+)
- Flutter SDK (latest stable)
- MongoDB Compass or MongoDB Server
- Android Studio (for building APK)

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/Haile-Tesfa/UniLink-Ethiopia.git
cd UniLink-Ethiopia
```

### 2. Setup Backend

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

### 3. Configure Flutter App

Edit `lib/utils/constants.dart` and set your server IP:
```dart
static const String apiBaseUrl = 'http://YOUR_COMPUTER_IP:5000';
```

### 4. Build APK

```bash
flutter pub get
flutter build apk --release
```

## 📚 Documentation

- **[Quick Start Guide](QUICK_START.md)** - Get up and running in 5 minutes
- **[Complete Deployment Guide](DEPLOYMENT_GUIDE.md)** - Detailed setup and deployment instructions

## 📱 Building for Production

See [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) for:
- Setting up MongoDB (local or cloud)
- Configuring the backend server
- Building release APK
- Deploying to production
- Troubleshooting common issues

## 🔧 Configuration

### Backend Configuration

Edit `backend/.env`:
- `MONGODB_URI`: MongoDB connection string
- `PORT`: Server port (default: 5000)

### Flutter Configuration

Edit `lib/utils/constants.dart`:
- `apiBaseUrl`: Backend server URL

## 📝 Recent Changes

- ✅ Migrated from SQL Server to MongoDB
- ✅ Centralized API configuration
- ✅ Fixed deployment and connection issues
- ✅ Added comprehensive documentation

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License.

## 👥 Authors

- Haile Tesfa - [GitHub](https://github.com/Haile-Tesfa)

## 🙏 Acknowledgments

- Flutter community
- MongoDB documentation
- All contributors

---

**Need Help?** Check the [Deployment Guide](DEPLOYMENT_GUIDE.md) or [Quick Start Guide](QUICK_START.md)
