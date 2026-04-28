# Numpang

A modern, multi-platform Flutter navigation app built with Clean Architecture, MVVM pattern, and BLoC state management. Numpang helps users create and manage multi-destination routes with an intuitive map-based interface.

![Platform Support](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20macOS-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Architecture](https://img.shields.io/badge/Architecture-Clean%20%2B%20MVVM%20%2B%20BLoC-green)

## 🌟 Features

### Core Features

- **Interactive Map Experience**
  - OpenStreetMap via flutter_map (cross-platform including macOS)
  - Real-time location tracking with user location dot
  - Tap-to-add destinations directly on the map
  - Auto-centered map on selected locations

- **Destination Management**
  - Add multiple destinations via map tap or search
  - CRUD operations (Create, Read, Delete) for destinations
  - Bottom sheet interface for destination list
  - Drag-handle bottom sheet with collapsible states

- **Smart Search**
  - Floating search bar with autocomplete
   - Location search with OpenStreetMap Nominatim API
  - Voice search capability
  - Quick access category chips (Restaurants, Gas, Groceries, etc.)

- **Adaptive UI**
  - Responsive design for phone, tablet, and desktop
  - Landscape mode support
  - macOS desktop optimization
  - Fluid layout with 4px baseline grid

- **Settings**
  - Common app settings
  - Theme preferences (Dark/Light mode)
  - Map preferences
  - Unit and measurement settings

## 🏗 Architecture

Numpang follows a robust **Clean Architecture** combined with **MVVM** pattern and **BLoC** state management for maximum maintainability and testability.

```
lib/
├── core/
│   ├── constants/          # App constants and enums
│   ├── errors/             # Error handling classes
│   ├── theme/              # Theme configuration (Amber Design System)
│   ├── utils/              # Utility functions and extensions
│   └── di/                 # Dependency injection (Provider)
├── data/
│   ├── datasources/        # Remote and local data sources
│   ├── models/             # Data models with serialization
│   └── repositories/       # Repository implementations
├── domain/
│   ├── entities/           # Business entities
│   ├── repositories/       # Repository interfaces
│   └── usecases/           # Business logic use cases
├── presentation/
│   ├── bloc/               # BLoC classes for state management
│   ├── screens/            # Screen widgets
│   ├── widgets/            # Reusable widgets
│   └── responsive/         # Responsive layout builders
└── flavors/                # App flavors (dev, prod)
```

### Architecture Layers

1. **Domain Layer**: Pure Dart, no Flutter dependencies. Contains business logic and entities.
2. **Data Layer**: Handles data sources (API, local database) and repository implementations.
3. **Presentation Layer**: UI components, BLoC state management, and user interactions.

## 🎨 Design System

Based on the **Amber Map System** - a utility-first framework designed for high-frequency navigation.

### Colors

| Token | Value | Usage |
|-------|-------|-------|
| Primary | `#FFCA28` | Critical actions, active states |
| Primary Container | `#F3C01A` | Surface tint, elevation |
| User Blue | `#2196F3` | User location, active route |
| Surface (Dark) | `#1A1C1C` | Background surfaces |
| On Surface | `#E2E2E2` | Text on surfaces |

### Typography

Font Family: **Plus Jakarta Sans**

- **Headline LG**: 24px, Bold (700) - Place names
- **Headline MD**: 20px, Semi-Bold (600) - Section titles
- **Title MD**: 16px, Semi-Bold (600) - Card titles
- **Body LG**: 16px, Regular (400) - Body content
- **Body MD**: 14px, Regular (400) - Secondary text
- **Label LG**: 12px, Bold (600), 0.5px tracking - Buttons, chips

### Elevation Levels

- **Level 0**: Map canvas (base)
- **Level 1**: Bottom Sheet (slight surface tint)
- **Level 2**: Search Bar & Chips (medium tint)
- **Level 3**: FABs (highest contrast)

### Components

- **Floating Search Bar**: Top-mounted, 8px radius, with voice search
- **Bottom Navigation**: 5-tab bar with rounded Material Symbols
- **Bottom Sheet**: Drag-handle, 3 states (Collapsed/Half/Full)
- **FABs**: Navigation (Amber), Crosshair, Plus icons
- **Category Chips**: Horizontal scrollable with icons

## 🚀 Getting Started

### Prerequisites

- Flutter SDK >= 3.11.4
- Dart >= 3.11.4
- Android Studio / VS Code
- Xcode (for iOS/macOS development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/numpang_app.git
   cd numpang_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Setup environment variables**
   
   Create a `.env` file in the project root:
   ```env
   MAPBOX_ACCESS_TOKEN=your_mapbox_access_token_here
   GEOCODE_XYZ_API_KEY=your_geocode_xyz_api_key_here
   ```

4. **Generate flavors**
   
   This project uses [flutter_flavorizr](https://pub.dev/packages/flutter_flavorizr). First, generate the flavors:
   
   ```bash
   flutter pub run flutter_flavorizr
   ```
   
   This creates the flavor configurations for Android, iOS, and macOS.

5. **Run the app**
   
   The app supports two flavors: `dev` and `prod`
   
   **Android & iOS:**
   ```bash
   # Development flavor
   flutter run --flavor dev
   
   # Production flavor
   flutter run --flavor prod
   ```
   
   **macOS:**
   > Due to a Flutter SDK bug, macOS flavors cannot be run from terminal. Open `macos/Runner.xcworkspace` in Xcode, select the desired scheme (dev/prod), and press Run.
   
   ```bash
   # Temporary workaround (add buildSettings to flavorizr.yaml)
   flutter run -d macos --flavor dev
   ```

## 📦 Dependencies

### Core Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `bloc` | ^8.1.4 | State management pattern |
| `flutter_bloc` | ^8.1.6 | Flutter BLoC integration |
| `provider` | ^6.1.5 | Dependency injection |
| `dynamic_color` | ^1.8.1 | Material You dynamic colors |
| `flutter_map` | ^8.3.0 | Map rendering (OpenStreetMap) |
| `latlong2` | ^0.9.1 | Geographic coordinates |
| `flutter_flavorizr` | ^2.2.3 | Multi-flavor configuration |
| `flutter_dotenv` | ^5.2.1 | Environment variables |
| `equatable` | ^2.0.7 | Value equality for BLoC |
| `dartz` | ^0.10.1 | Functional programming (Either) |

### Dev Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_test` | sdk:flutter | Testing framework |
| `mockito` | ^5.4.4 | Mock generation for tests |
| `bloc_test` | ^9.1.7 | BLoC testing utilities |
| `flutter_lints` | ^6.0.0 | Linting rules |
| `build_runner` | ^2.4.12 | Code generation |

## 🧪 Testing

### Run all tests
```bash
flutter test
```

### Run tests with coverage
```bash
flutter test --coverage
```

### Run BLoC tests only
```bash
flutter test test/bloc/
```

### Run widget tests
```bash
flutter test test/widgets/
```

## 📱 Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| Android | ✅ Stable | API 21+ |
| iOS | ✅ Stable | iOS 12.0+ |
| macOS | ✅ Stable | macOS 10.15+ |
| Tablet | ✅ Optimized | Landscape support |
| Desktop | ✅ Optimized | Keyboard shortcuts |

### Responsive Breakpoints

- **Phone**: < 600px (single pane)
- **Tablet**: 600px - 1024px (adaptive layouts)
- **Desktop**: > 1024px (multi-pane support)

## 🔧 Configuration

### App Identification

This project uses the following bundle ID structure:

| Flavor | Android Application ID | iOS/macOS Bundle ID |
|--------|------------------------|---------------------|
| dev | `com.rizkyeky.numpangdev` | `com.rizkyeky.numpangdev` |
| prod | `com.rizkyeky.numpang` | `com.rizkyeky.numpang` |

Organization: `com.rizkyeky.{appname}`

### OpenStreetMap Setup

flutter_map uses OpenStreetMap tiles which are free and do not require an API key. For production apps, consider using a tile provider with higher rate limits.

**Tile Providers:**
- OpenStreetMap (default, free)
- MapTiler (requires API key)
- Thunderforest (requires API key)
- Stadia Maps (requires API key)

**Geocoding Services (no API key required):**
- Nominatim (OpenStreetMap, default)
- Geocode.xyz
- Mapbox Geocoding API

### Android Configuration

Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<manifest>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    <uses-permission android:name="android.permission.INTERNET"/>
</manifest>
```

### iOS Configuration

Add to `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to location for navigation features.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>This app needs access to location for background navigation.</string>
<key>io.flutter.embedded_views_preview</key>
<true/>
```

### macOS Configuration

Add to `macos/Runner/DebugProfile.entitlements` and `Release.entitlements`:
```xml
<key>com.apple.security.network.client</key>
<true/>
<key>com.apple.security.personal-information.location</key>
<true/>
```

## 🎯 Key Architectural Decisions

### Why BLoC?
- Predictable state management
- Easy testing with `bloc_test`
- Clear separation of business logic
- Stream-based reactive programming

### Why Provider for DI?
- Simple and lightweight
- Flutter-native solution
- Easy integration with BLoC
- Good for medium-scale apps

### Why Clean Architecture?
- Testable business logic
- Framework independence
- Clear separation of concerns
- Easy to maintain and scale

### Why Flavors?
- Separate environments (dev/staging/prod)
- Different API keys per environment
- Custom app icons and names
- Efficient development workflow

## 📐 Coding Standards

### BLoC Pattern Example

```dart
// destination_bloc.dart
class DestinationBloc extends Bloc<DestinationEvent, DestinationState> {
  final GetDestinationsUseCase _getDestinationsUseCase;
  final AddDestinationUseCase _addDestinationUseCase;
  final DeleteDestinationUseCase _deleteDestinationUseCase;

  DestinationBloc({
    required GetDestinationsUseCase getDestinationsUseCase,
    required AddDestinationUseCase addDestinationUseCase,
    required DeleteDestinationUseCase deleteDestinationUseCase,
  })  : _getDestinationsUseCase = getDestinationsUseCase,
        _addDestinationUseCase = addDestinationUseCase,
        _deleteDestinationUseCase = deleteDestinationUseCase,
        super(DestinationInitial());

  @override
  Stream<DestinationState> mapEventToState(DestinationEvent event) async* {
    if (event is LoadDestinations) {
      yield* _mapLoadDestinationsToState();
    } else if (event is AddDestination) {
      yield* _mapAddDestinationToState(event.destination);
    } else if (event is DeleteDestination) {
      yield* _mapDeleteDestinationToState(event.id);
    }
  }
}
```

### Use Case Example

```dart
// add_destination_use_case.dart
class AddDestinationUseCase {
  final DestinationRepository _repository;

  AddDestinationUseCase(this._repository);

  Future<Either<Failure, Destination>> call(Destination destination) async {
    return await _repository.addDestination(destination);
  }
}
```

### Repository Pattern

```dart
// destination_repository_impl.dart
class DestinationRepositoryImpl implements DestinationRepository {
  final DestinationLocalDataSource _localDataSource;
  final DestinationRemoteDataSource _remoteDataSource;

  DestinationRepositoryImpl({
    required DestinationLocalDataSource localDataSource,
    required DestinationRemoteDataSource remoteDataSource,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, Destination>> addDestination(Destination destination) async {
    try {
      final result = await _localDataSource.insertDestination(destination);
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
```

## 🌐 Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `APP_ENV` | Environment name (dev/prod) | ✅ |
| `API_BASE_URL` | Backend API base URL | ❌ |

> **Note:** This project uses OpenStreetMap via flutter_map and Nominatim/geocode.xyz for geocoding - no API key required.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'feat: add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Commit Message Convention

We follow [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting)
- `refactor:` - Code refactoring
- `test:` - Test additions/modifications
- `chore:` - Build process or auxiliary tool changes

## 🙏 Acknowledgments

- Design System: [Google Stitch - Amber Map System](https://stitch.withgoogle.com/)
- Icons: [Material Symbols Rounded](https://fonts.google.com/icons)
- Font: [Plus Jakarta Sans](https://fonts.google.com/specimen/Plus+Jakarta+Sans)

## 📞 Support

For support, email support@numpang.app or join our Slack channel.

---

**Built with ❤️ using Flutter**
