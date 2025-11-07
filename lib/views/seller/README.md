# Seller Views - Folder Structure

This directory contains all seller-related views organized by functionality for better maintainability and code organization.

## 📁 Folder Structure

```
lib/views/seller/
├── dashboard/                  # Seller dashboard and home screens
│   ├── seller_home_view.dart   # Main seller dashboard with navigation
│   └── dashboard.dart          # Exports for dashboard module
├── products/                   # Product management screens
│   ├── product_listing_view.dart       # Create/edit product listings
│   ├── seller_products_view.dart       # View all seller products
│   ├── seller_listed_products_view.dart # Manage listed products
│   └── products.dart                   # Exports for products module
├── auctions/                   # Auction management screens
│   ├── seller_auction_product_view.dart    # Create auction listings
│   ├── seller_listed_auctions_view.dart    # Manage active auctions
│   └── auctions.dart                       # Exports for auctions module
├── orders/                     # Order management screens
│   ├── seller_order_history_view.dart     # View and manage orders
│   └── orders.dart                        # Exports for orders module
├── profile/                    # Seller profile management
│   ├── seller_profile_view.dart           # Edit seller profile
│   └── profile.dart                       # Exports for profile module
├── notifications/              # Notification management
│   ├── seller_notifications_view.dart     # View and manage notifications
│   └── notifications.dart                 # Exports for notifications module
└── seller_views.dart          # Main exports file for all seller views
```

## 🔗 Usage

### Import Individual Modules
```dart
// Import specific functionality
import 'package:your_app/views/seller/products/products.dart';
import 'package:your_app/views/seller/auctions/auctions.dart';
import 'package:your_app/views/seller/dashboard/dashboard.dart';
```

### Import All Seller Views
```dart
// Import everything at once
import 'package:your_app/views/seller/seller_views.dart';
```

### Import Specific Views
```dart
// Import individual views
import 'package:your_app/views/seller/products/seller_products_view.dart';
import 'package:your_app/views/seller/auctions/seller_listed_auctions_view.dart';
```

## 📋 Modules Overview

### 🏠 Dashboard Module
- **Purpose**: Main seller interface and navigation hub
- **Files**: `seller_home_view.dart`
- **Features**: Navigation tabs, seller statistics, quick actions

### 📦 Products Module
- **Purpose**: Complete product lifecycle management
- **Files**: 
  - `product_listing_view.dart` - Create/edit products
  - `seller_products_view.dart` - Browse all products
  - `seller_listed_products_view.dart` - Manage active listings
- **Features**: CRUD operations, status management, inventory tracking

### 🔨 Auctions Module
- **Purpose**: Auction creation and management
- **Files**:
  - `seller_auction_product_view.dart` - Create auction listings
  - `seller_listed_auctions_view.dart` - Manage ongoing auctions
- **Features**: Auction creation, bidding management, time tracking

### 📋 Orders Module
- **Purpose**: Order processing and fulfillment
- **Files**: `seller_order_history_view.dart`
- **Features**: Order status updates, shipping management, payment tracking

### 👤 Profile Module
- **Purpose**: Seller account and profile management
- **Files**: `seller_profile_view.dart`
- **Features**: Profile editing, seller statistics, account settings

### 🔔 Notifications Module
- **Purpose**: Communication and alert management
- **Files**: `seller_notifications_view.dart`
- **Features**: Notification viewing, marking as read, filtering

## 🏗️ Architecture Notes

- All views follow MVC (Model-View-Controller) architecture
- Controllers are consumed via Provider pattern for state management
- Consistent error handling and loading states across all views
- Responsive design with proper animations and transitions
- Form validation and user input handling

## 🚀 Navigation Integration

The seller views are integrated with the app's navigation system through:
- Route definitions in `config/routes.dart`
- Route management in `config/route_manager.dart`
- Bottom navigation in the seller dashboard

## 🧩 Dependencies

Each module depends on:
- **Controllers**: Business logic and state management
- **Models**: Data structures and validation
- **Widgets**: Reusable UI components
- **Utils**: Helper functions and validators

This organization promotes:
- ✅ Better code maintainability
- ✅ Easier testing and debugging
- ✅ Clearer separation of concerns
- ✅ Improved developer experience
- ✅ Scalable architecture for future features