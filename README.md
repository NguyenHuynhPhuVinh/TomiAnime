# 🎌 TomiAnime - Ứng dụng Anime Gaming tuyệt vời

> Ứng dụng Flutter hiện đại với giao diện game anime, mang đến trải nghiệm giải trí đa dạng với anime, thẻ bài, phiêu lưu và gacha.

## ✨ Tính năng chính

- 🎬 **Anime Collection** - Khám phá và xem anime yêu thích
- 🃏 **Card Collection** - Thu thập và nâng cấp thẻ bài hiếm
- 🗺️ **Adventure Quest** - Khám phá thế giới phiêu lưu bí ẩn
- 🎁 **Gacha System** - Quay thưởng nhận vật phẩm và nhân vật hiếm
- 👤 **Player Profile** - Quản lý thông tin và thành tích cá nhân
- 🎨 **Dark Theme** - Giao diện tối hiện đại với Material Design 3

## 🏗️ Kiến trúc dự án

### Cấu trúc thư mục

```
lib/
├── main.dart                           # Entry point
├── app/
    ├── routes/                         # Navigation management
    │   ├── app_pages.dart             # Route definitions & bindings
    │   └── app_routes.dart            # Route constants
    └── modules/                       # Feature modules (Clean Architecture)
        ├── home/                      # 🏠 Main navigation container
        │   ├── controllers/           # Business logic
        │   ├── bindings/             # Dependency injection
        │   └── views/                # UI components
        ├── anime/                     # 🎬 Anime collection module
        ├── cards/                     # 🃏 Card collection module
        ├── adventure/                 # 🗺️ Adventure quest module
        ├── gacha/                     # 🎁 Gacha system module
        └── account/                   # 👤 Player profile module
```

### Nguyên tắc thiết kế

#### 🎯 **Clean Architecture + MVC Pattern**

- **Separation of Concerns**: Tách biệt UI, Business Logic và Data
- **SOLID Principles**: Code dễ maintain và mở rộng
- **Dependency Injection**: Quản lý dependencies tự động

#### 📱 **Reactive Programming với GetX**

```dart
// State Management
final currentIndex = 0.obs;            // Observable tab index
final isLoading = false.obs;           // Loading state

// Reactive UI
Obx(() => controller.currentIndex.value == 0
  ? AnimeView()
  : CardsView()
)
```

#### 🔗 **Dependency Injection với Bindings**

```dart
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Lazy loading - chỉ tạo khi cần
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<AnimeController>(() => AnimeController());
    Get.lazyPut<CardsController>(() => CardsController());
  }
}
```

## 🛠️ Tech Stack

### Core Framework

- **Flutter** - Cross-platform UI framework
- **Dart** - Programming language

### State Management & Navigation

- **GetX** - State management, routing, dependency injection
- **Get** - Navigation và dialog management

### UI Components

- **GetWidget** - Rich UI component library
- **Responsive Builder** - Adaptive layouts for mobile/tablet
- **Iconsax** - Beautiful icon set cho gaming theme
- **Material Design 3** - Modern design system với dark theme

### Data & Storage

- **Hive** - Fast NoSQL database cho game data
- **Hive Flutter** - Flutter integration
- **Flutter Secure Storage** - Secure player data storage

### Network & Authentication

- **Dio** - Powerful HTTP client
- **Firebase Core** - Backend infrastructure
- **Firebase Auth** - Player authentication
- **Cloud Firestore** - Real-time database

### UI Enhancements

- **Shimmer** - Loading skeleton effects cho game UI
- **Liquid Pull to Refresh** - Beautiful refresh indicator
- **Smooth Page Indicator** - Page indicators
- **Auto Size Text** - Responsive text sizing
- **Cached Network Image** - Image caching cho anime/card images
- **Flutter ScreenUtil** - Responsive design

### Utilities & Media

- **URL Launcher** - Open external links
- **Flutter SVG** - SVG image support
- **Flutter InAppWebView** - In-app video player cho anime
- **Permission Handler** - Device permissions management
- **Connectivity Plus** - Network status monitoring

## 🚀 Cài đặt và chạy dự án

### Yêu cầu hệ thống

- Flutter SDK >= 3.8.1
- Dart SDK >= 3.0.0
- Android Studio / VS Code
- Git

### Các bước cài đặt

1. **Clone repository**

```bash
git clone https://github.com/your-username/tomianime.git
cd tomianime
```

2. **Cài đặt dependencies**

```bash
flutter pub get
```

3. **Chạy code generation (cho Hive)**

```bash
flutter packages pub run build_runner build
```

4. **Chạy ứng dụng**

```bash
flutter run
```

## 📋 Scripts hữu ích

```bash
# Cài đặt dependencies
flutter pub get

# Chạy code generation
flutter packages pub run build_runner build

# Clean và rebuild
flutter clean && flutter pub get

# Chạy tests
flutter test

# Build APK
flutter build apk --release

# Build iOS
flutter build ios --release
```

## 🏛️ Kiến trúc chi tiết

### 📦 Module Structure

Mỗi module trong dự án tuân theo pattern **MVC + Dependency Injection**:

```
module_name/
├── controllers/           # Business Logic Layer
│   └── module_controller.dart
├── bindings/             # Dependency Injection
│   └── module_binding.dart
└── views/                # Presentation Layer
    └── module_view.dart
```

### 🔄 Data Flow

```
User Action → View → Controller → Business Logic → Update State → View Auto-Update
```

### 🎯 Dependency Injection Flow

```
Route Called → Binding.dependencies() → Controller Created → View Uses Controller → Route Closed → Controller Auto-Disposed
```

## 📱 Screens Overview

### 🏠 Home (Navigation Container)

- **Controller**: Quản lý 5-tab navigation system
- **View**: Custom gaming-style navigation bar
- **Features**: Smooth transitions, responsive design, state persistence

### 🎬 Anime Collection

- **Controller**: Quản lý anime library và streaming
- **View**: Grid layout với anime cards
- **Features**: Search, filter, favorites, watch history

### 🃏 Card Collection

- **Controller**: Quản lý card inventory và upgrades
- **View**: Card gallery với rarity indicators
- **Features**: Card evolution, deck building, trading

### 🗺️ Adventure Quest

- **Controller**: Quest management và progress tracking
- **View**: Interactive map interface
- **Features**: Quest chains, rewards, achievements

### 🎁 Gacha System

- **Controller**: Gacha mechanics và probability
- **View**: Animated pull interface
- **Features**: Multi-pull, pity system, collection tracking

### 👤 Player Profile

- **Controller**: User data và statistics
- **View**: Profile dashboard với achievements
- **Features**: Level system, badges, social features

## 🔧 Development Guidelines

### 📝 Code Style

- **Naming**: camelCase cho variables, PascalCase cho classes
- **Comments**: Tiếng Việt cho business logic, English cho technical
- **Structure**: Một file một class, tối đa 300 lines

### 🧪 Testing Strategy

```bash
# Unit Tests - Business Logic
test/unit/controllers/

# Widget Tests - UI Components
test/widget/views/

# Integration Tests - Full Flow
test/integration/
```

### 🚀 Performance Best Practices

- **Lazy Loading**: Controllers chỉ tạo khi cần
- **Memory Management**: Auto-dispose với GetX
- **Image Caching**: CachedNetworkImage cho anime/card images
- **Database**: Hive cho fast local game data storage
- **Responsive Design**: ScreenUtil cho consistent UI across devices
- **Dark Theme**: Optimized cho battery life và user experience

## 🤝 Contributing

### 📋 Development Workflow

1. **Fork** repository
2. **Create** feature branch: `git checkout -b feature/amazing-feature`
3. **Commit** changes: `git commit -m 'Add amazing feature'`
4. **Push** branch: `git push origin feature/amazing-feature`
5. **Open** Pull Request

### 🐛 Bug Reports

Sử dụng GitHub Issues với template:

- **Environment**: Flutter version, device info
- **Steps to reproduce**: Chi tiết các bước
- **Expected vs Actual**: Kết quả mong đợi vs thực tế
- **Screenshots**: Nếu có

## 📄 License

Dự án này được phân phối dưới MIT License. Xem `LICENSE` file để biết thêm chi tiết.

## 👥 Team

- **Developer**: Your Name
- **UI/UX**: Design Team
- **QA**: Testing Team

## 🙏 Acknowledgments

- **Flutter Team** - Amazing framework
- **GetX Community** - Powerful state management
- **Open Source Contributors** - All the amazing libraries

---

<div align="center">
  <p>Made with ❤️ and Flutter</p>
  <p>⭐ Star this repo if you find it helpful!</p>
</div>
