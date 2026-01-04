class AppConstants {
  static const String appName = 'UniLink';
  static const String appTagline = 'Connect. Share. Grow.';
  static const String version = '1.0.0';
  
  // API Configuration
  // IMPORTANT: Change this to your server's IP address or domain for deployment
  // For local development: 'http://10.0.2.2:5000' (Android Emulator)
  // For local development: 'http://localhost:5000' (iOS Simulator / Web)
  // For deployment: 'http://YOUR_SERVER_IP:5000' or 'https://yourdomain.com'
  // Example: 'http://192.168.1.100:5000' (replace with your computer's local IP)
  static const String apiBaseUrl = 'http://localhost:5000';
  
  // API Endpoints
  static const String loginEndpoint = '/api/auth/login';
  static const String signupEndpoint = '/api/auth/signup';
  static const String postsEndpoint = '/api/posts';
  static const String marketplaceEndpoint = '/api/marketplace';
  static const String eventsEndpoint = '/api/events';
  
  // App Settings
  static const int postsPerPage = 10;
  static const int marketplaceItemsPerPage = 20;
  static const int eventsPerPage = 15;
  
  // Validation Rules
  static const int minPasswordLength = 6;
  static const int maxPostLength = 5000;
  static const int maxCommentLength = 1000;
  
  // Cache Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String themeModeKey = 'theme_mode';
}