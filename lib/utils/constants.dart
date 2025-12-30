class AppConstants {
  static const String appName = 'UniLink';
  static const String appTagline = 'Connect. Share. Grow.';
  static const String version = '1.0.0';
  
  // API Endpoints (Placeholders)
  static const String apiBaseUrl = 'https://api.unilink.edu.et';
  static const String loginEndpoint = '/auth/login';
  static const String signupEndpoint = '/auth/signup';
  static const String postsEndpoint = '/posts';
  static const String marketplaceEndpoint = '/marketplace';
  static const String eventsEndpoint = '/events';
  
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