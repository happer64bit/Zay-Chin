class ApiConfig {
  // Change this to your backend URL
  // For Android emulator, use: http://10.0.2.2:3000
  // For iOS simulator, use: http://localhost:3000
  // For physical device, use your computer's IP address: http://192.168.x.x:3000
  static const String baseUrl =
      String.fromEnvironment('BASE_URL', defaultValue: 'http://localhost:3000');

  
  static const String authPrefix = '/auth';
  static const String profilePrefix = '/profile';
  static const String groupPrefix = '/group';
  static const String cartPrefix = '/cart';
}

