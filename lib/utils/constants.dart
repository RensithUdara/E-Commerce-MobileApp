class AppConstants {
  // App Info
  static const String appName = 'GemHub';
  static const String appVersion = '1.0.0';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String productsCollection = 'products';
  static const String cartsCollection = 'carts';
  static const String ordersCollection = 'orders';
  static const String auctionsCollection = 'auctions';
  static const String categoriesCollection = 'categories';
  static const String bannersCollection = 'banners';
  
  // Storage Paths
  static const String productImagesPath = 'product_images';
  static const String userImagesPath = 'user_images';
  static const String auctionImagesPath = 'auction_images';
  static const String categoryImagesPath = 'category_images';
  static const String bannerImagesPath = 'banner_images';
  
  // Default Values
  static const int defaultPageSize = 20;
  static const int maxImageUpload = 5;
  static const double minBidIncrement = 1.0;
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxProductTitleLength = 100;
  static const int maxProductDescriptionLength = 500;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 800);
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double buttonHeight = 48.0;
  
  // Network
  static const Duration timeoutDuration = Duration(seconds: 30);
}