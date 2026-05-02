# Numpang - Development Plan (PRD)

## 1. Executive Summary

### Problem Statement
Users need a simple, intuitive way to create and manage multi-destination routes on a map interface. Existing navigation apps focus on point-to-point routing without flexible destination management for trip planning.

### Proposed Solution
Numpang is a Flutter-based multi-platform navigation app with Clean Architecture, BLoC state management, and OpenStreetMap integration (via flutter_map). Users can tap locations on a map or search to build destination lists, manage them via a bottom sheet interface, with responsive design for phone, tablet, and desktop.

### Success Criteria
- ✅ App runs on Android, iOS, and macOS with flavors (dev/prod)
- ✅ Map displays with custom Amber theme styling
- ✅ Users can add destinations via map tap and search
- ✅ Bottom sheet shows destination list with add/delete CRUD
- ✅ Responsive layout adapts to 3 breakpoints (phone/tablet/desktop)
- ✅ All BLoC states are testable with >80% unit test coverage
- ✅ App achieves 60 FPS on target devices
- ✅ Geocoding API integration complete with fallback (Nominatim → Mapbox)
- ✅ Rate-limit handling with client-side caching (LRU, 24h TTL)

### Platform Requirements

| Platform | Minimum Version | Note |
|----------|-----------------|------|
| Android  | Android 11 (API 30) | Required for modern location APIs |
| iOS      | iOS 16.0+       | Required for Liquid Glass components |
| macOS    | macOS 15.0+     | Required for specialized desktop features |

---

## 2. User Experience & Functionality

### User Personas

| Persona | Description | Goals |
|---------|-------------|-------|
| **Trip Planner** | Plans multi-stop journeys | Add multiple destinations, organize route |
| **Commuter** | Daily navigation with errands | Quick add destinations, fast search |
| **Explorer** | Discovers new places | Search locations, save interesting spots |

### User Stories

#### EPIC 1: Map & Location Core

**US-1.1**: As a user, I want to see an interactive map so I can explore locations.
- **AC**:
  - Map loads with flutter_map + OpenStreetMap
  - Map uses Amber theme custom styling
  - User location dot displays with blue pulse animation
  - Map centers on user's current location on launch

**US-1.2**: As a user, I want to tap on the map to add a destination so I can mark locations quickly.
- **AC**:
  - Tap on map shows marker at tapped location
  - "Add Destination" button appears on marker tap
  - Destination is added to list after confirmation
  - Map does not recenter after adding (stays on tapped location)

**US-1.3**: As a user, I want to search for locations so I can find specific places.
- **AC**:
  - Search bar at top with "Search here" placeholder
   - Autocomplete suggestions from OpenStreetMap Nominatim API
  - Selecting suggestion centers map on location
  - User must manually add to destination list (no auto-add)

#### EPIC 2: Destination Management

**US-2.1**: As a user, I want to see my added destinations in a bottom sheet so I can review my route.
- **AC**:
  - Bottom sheet shows list of added destinations
  - Each destination shows: name, address, distance from previous
  - Bottom sheet has 3 states: Collapsed (header only) → Half (3 items) → Full (all items)
  - Drag handle at top for gesture control

**US-2.2**: As a user, I want to delete destinations so I can correct mistakes.
- **AC**:
  - Swipe-to-delete or delete button per destination
  - Confirmation dialog before deletion
  - List updates immediately after deletion
  - Map markers update to reflect deletion

**US-2.3**: As a user, I want to add destinations from search results so I can plan precise routes.
- **AC**:
  - After selecting search result, "Add to Destinations" button appears
  - Button is disabled if location already in list
  - Success feedback shown after adding (snackbar/toast)

**US-2.4**: As a user, I want to reorder destinations so I can organize my trip sequence. (Stretch Goal)
- **AC**:
  - Drag handle on each destination list item
  - Destinations can be reordered via drag-and-drop
  - Map markers update to reflect new order
  - Order persists across sessions

#### EPIC 3: Responsive Design

**US-3.1**: As a tablet user, I want the app to use landscape layout so I can see more map context.
- **AC**:
  - Layout switches at 600px breakpoint
  - Bottom sheet becomes side panel in landscape
  - Map uses remaining screen space

**US-3.2**: As a desktop user, I want keyboard shortcuts so I can navigate efficiently.
- **AC**:
  - `Ctrl/Cmd + F` focuses search bar
  - `Esc` closes bottom sheet/dialogs
  - `Ctrl/Cmd + D` adds destination from selected location

#### EPIC 4: Settings

**US-4.1**: As a user, I want a settings page so I can customize app behavior.
- **AC**:
  - Settings accessible from app bar or side menu
  - Sections: Theme (Dark/Light), Map Preferences, Units
  - Settings persist across app sessions

### Non-Goals (Out of Scope)

- ❌ Real-time traffic data
- ❌ Turn-by-turn navigation
- ❌ User authentication or accounts
- ❌ Cloud sync of destinations
- ❌ Sharing routes with other users
- ❌ Offline map support
- ❌ Voice navigation
- ❌ Public transit routing
- ❌ Road distance/time API (straight-line distance only)
- ❌ Turn-by-turn directions

### Stretch Goals

- **US-2.4**: Reorder destinations via drag handle
- **Distance between destinations**: Compute using OSRM/GraphHopper API (road distance, not turn-by-turn)

---

## 3. Technical Specifications

### Architecture Overview

```
lib/
├── core/              # Constants, errors, theme, utils
├── data/              # Models, datasources, repository implementations
│   ├── datasources/   # Remote (API) and local (in-memory/Hive)
│   ├── models/        # Data models with JSON serialization
│   └── repositories/  # Repository implementations
├── domain/            # Pure Dart (NO Flutter imports)
│   ├── entities/      # Destination, UserLocation, PlaceSuggestion
│   ├── repositories/  # Abstract interfaces (DestinationRepository, GeocodingRepository)
│   ├── usecases/      # AddDestination, GetDestinations, SearchAddress, ReverseGeocode
│   └── errors/        # Failure classes
└── presentation/      # Flutter UI
    ├── bloc/          # DestinationBloc, MapBloc, SearchBloc
    ├── screens/      # MapScreen, SettingsScreen
    └── widgets/       # Reusable widgets
```

**Dependency Rule:** Source code dependencies point inward. Domain has NO Flutter imports.

### Integration Points

| Component | Technology | Purpose |
|-----------|------------|---------|
| Maps | `flutter_map` ^8.3.0 + `latlong2` | Map rendering via OpenStreetMap |
| Geocoding | `dio` ^5.9.2 | API calls to mapbox/geocode.xyz/nominatim |
| State | `bloc` ^8.1.4 + `flutter_bloc` ^8.1.6 | State management |
| DI | `provider` ^6.1.5 | Dependency injection |
| Theme | `dynamic_color` ^1.8.1 | Material You colors |
| Env | `flutter_dotenv` ^5.2.1 | API key management |
| Flavors | `flutter_flavorizr` ^2.2.3 | Dev/Prod environments |
| Functional | `dartz` ^0.10.1 | Either type for error handling |
| Equality | `equatable` ^2.0.7 | Value equality for BLoC |

### Data Models

```dart
// domain/entities/destination.dart
class Destination extends Equatable {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  
  const Destination({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
  });
}

// domain/entities/user_location.dart
class UserLocation extends Equatable {
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;
  
  const UserLocation({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
  });
}
```

### BLoC States

```dart
// presentation/bloc/destination/destination_bloc.dart

// Events
abstract class DestinationEvent extends Equatable {}
class LoadDestinations extends DestinationEvent {}
class AddDestination extends DestinationEvent {
  final Destination destination;
}
class DeleteDestination extends DestinationEvent {
  final String id;
}
class UpdateMapCenter extends DestinationEvent {
  final LatLng position;
}

// States
abstract class DestinationState extends Equatable {}
class DestinationInitial extends DestinationState {}
class DestinationsLoading extends DestinationState {}
class DestinationsLoaded extends DestinationState {
  final List<Destination> destinations;
}
class DestinationError extends DestinationState {
  final String message;
}
class MapCenterUpdated extends DestinationState {
  final LatLng position;
}
```

### API Requirements

| API | Endpoint | Usage |
|-----|----------|-------|
| OpenStreetMap Tiles | `tile.openstreetmap.org` | Map tiles |
| Nominatim | `nominatim.openstreetmap.org` | Geocoding, search (Default) |
| Mapbox Geocoding | `api.mapbox.com/search/geocode/v6/` | Geocoding, search (Fallback) |
| Geocode.xyz | `geocode.xyz/api` | Geocoding, search (Option 3) |

#### Geocoding Service Architecture

```dart
// domain/repositories/geocoding_repository.dart
abstract class GeocodingRepository {
  Future<Either<Failure, LatLng>> searchAddress(String query);
  Future<Either<Failure, String>> reverseGeocode(LatLng position);
  Future<Either<Failure, List<PlaceSuggestion>>> autocomplete(String input);
}
```

**Fallback Strategy:**
- **Default:** Nominatim (free, no key required)
- **Limitations:** 1 request/second rate limit
- **Mitigation:**
  - Client-side LRU caching for reverse geocoding results (24h TTL)
  - Queue with 300ms debounce for autocomplete
  - Optional Mapbox API key for production (higher quota)
  - Configurable via `GEOCODING_PROVIDER` env variable

**Environment Configuration:**
```env
GEOCODING_PROVIDER=nominatim   # or mapbox
MAPBOX_API_KEY=your_key_here
```

**Testing Requirements:**
- Unit tests for API response parsing (mock HTTP client)
- Error simulation: 429 rate limit, 500 server error → verify `Either<Failure, T>` handling
- Integration test (optional) with local Nominatim Docker container

### Security Requirements

- ✅ API keys stored in `.env` (never committed)
- ✅ API keys configured in platform manifests with restrictions
- ✅ Location permissions requested at runtime with rationale
- ✅ No personal data stored locally without encryption
- ✅ HTTPS enforced for all network requests

---

## 4. Development Phases

### Phase 1: Foundation (Days 1-3)

**Agent A: Core Setup**
- [x] Initialize Flutter project with flavors (dev/prod)
- [x] Configure `.env` setup with `flutter_dotenv`
- [x] Setup folder structure (Clean Architecture)
- [x] Configure Provider for DI
- [x] Setup BLoC infrastructure
- [x] Create base theme with Amber colors
- [x] Configure Android/iOS/macOS platform files
- [x] Add location permissions to all platforms

**Agent B: Domain Layer**
- [x] Create `Destination` entity
- [x] Create `UserLocation` entity
- [x] Define `DestinationRepository` interface
- [x] Create `AddDestinationUseCase`
- [x] Create `GetDestinationsUseCase`
- [x] Create `DeleteDestinationUseCase`
- [x] Create `Failure` classes (domain/errors/)
- [x] Write unit tests for all use cases

**Milestone M1**: Project builds successfully on all 3 platforms with flavors

### Phase 2: Data Layer & Geocoding API (Days 4-7)

> **Agent A only – no UI work until Phase 3**

- [x] Create `GeocodingRepository` interface
- [x] Implement `NominatimGeocodingRepository` with Dio + caching
- [x] Implement fallback to Mapbox (configurable via `.env`)
- [x] Create `LocationService` (permission handling, stream of user location)
- [x] Implement `DestinationLocalDataSource` (in-memory with Hive/VMO for persistence)
- [x] Implement `DestinationRemoteDataSource` (save/load from local – cloud out of scope)
- [x] Create `DestinationModel` with JSON serialization
- [x] Implement `DestinationRepositoryImpl`
- [x] Add LRU cache for reverse geocoding (24h TTL)
- [x] Add debounce for autocomplete (300ms)
- [x] Write unit tests for all repository methods (>=90% coverage)
- [x] Provide mock implementations for Agent B to use during UI development

**Testing Strategy:**
- [x] Unit tests for API response parsing (mock HTTP client)
- [x] Error simulation: 429 rate limit, 500 server error → verify `Either<Failure, T>` handling

**Milestone M2**: All data layer tests pass, geocoding works with real API

### Phase 3: Map Core (Days 8-11)

**Agent A: Map BLoC & Service**
- [x] Create `MapBloc` for map-specific state
- [x] Implement `MapService` wrapper for flutter_map
- [x] Create `SearchBloc` for search state
- [x] Wire geocoding services to BLoC handlers
- [x] Write BLoC tests with `bloc_test`

**Agent B: Map UI** (uses mock repositories until M2 is complete)
- [x] Create `MapScreen` with flutter_map widget
- [x] Implement custom Amber map styling
- [x] Add user location dot with pulse animation
- [x] Implement map tap handler with marker
- [x] Add "Add Destination" dialog on marker tap
- [x] Implement map centering on location update
- [x] Add crosshair FAB for recenter
- [x] Write widget tests for map interactions

**Milestone M3**: Map displays with user location, tap adds marker

### Phase 4: Destination Management (Days 12-16)

**Agent A: BLoC Implementation**
- [ ] Create `DestinationBloc` with all events/states
- [ ] Wire use cases to BLoC handlers
- [ ] Implement error handling with Either type
- [ ] Add state persistence (save/restore)
- [ ] Write BLoC tests with `bloc_test`
- [ ] Achieve >80% test coverage

**Bottom Sheet UI**
- [ ] Create `DestinationBottomSheet` widget
- [ ] Implement 3-state drag handle (Collapsed/Half/Full)
- [ ] Create destination list item widget
- [ ] Add swipe-to-delete gesture
- [ ] Add delete confirmation dialog
- [ ] Implement empty state UI
- [ ] Add FAB for manual add from current position
- [ ] Connect BLoC to UI with `BlocBuilder`/`BlocListener`

**Milestone M4**: Full CRUD flow works (add via tap, delete from list)

### Phase 5: Search & Discovery (Days 17-20)

**Agent A: Search Logic**
- [ ] Implement Places API autocomplete with debounce
- [ ] Implement place details fetching
- [ ] Add recent searches (local storage)
- [ ] Create category chips data structure
- [ ] Write unit tests for search logic

**Agent B: Search UI**
- [ ] Create `FloatingSearchBar` widget
- [ ] Implement autocomplete dropdown
- [ ] Add voice search button (placeholder)
- [ ] Create `CategoryChips` horizontal scroll
- [ ] Implement search result selection handler
- [ ] Add "Add to Destinations" button on selection
- [ ] Show loading state during search
- [ ] Handle search errors gracefully

**Milestone M5**: Search returns results, selecting centers map, user can add

### Phase 6: Responsive Design (Days 21-24)

**Agent A: Layout System**
- [ ] Create `ResponsiveLayout` widget
- [ ] Implement breakpoint detection (600/1024px)
- [ ] Create `LayoutContext` for responsive values
- [ ] Add landscape mode detection
- [ ] Implement adaptive spacing system
- [ ] Create responsive typography scaler

**Agent B: Adaptive Components**
- [ ] Convert bottom sheet to side panel for tablet
- [ ] Implement desktop keyboard shortcuts
- [ ] Add split-view for landscape tablet
- [ ] Create adaptive app bar (hamburger for desktop)
- [ ] Implement multi-pane layout for desktop
- [ ] Add settings page with adaptive layout
- [ ] Test all layouts on target breakpoints

**Milestone M6**: App adapts to phone/tablet/desktop with appropriate layouts

### Phase 7: Polish & Testing (Days 25-30)

**Agent A: Testing**
- [ ] Write unit tests for all BLoCs
- [ ] Write unit tests for all use cases
- [ ] Write widget tests for key components
- [ ] Achieve >80% code coverage
- [ ] Fix all failing tests
- [ ] Add integration test prerequisites
- [ ] Document manual testing checklist

**Agent B: Polish & UX**
- [ ] Add loading skeletons for async operations
- [ ] Implement error boundary UI
- [ ] Add snackbar/toast for feedback
- [ ] Polish animations (60 FPS target)
- [ ] Add haptic feedback on interactions
- [ ] Implement dark/light theme toggle
- [ ] Add app icon and splash screen
- [ ] Performance profiling and optimization

**Milestone M7**: All tests pass, app is production-ready

---

## 5. Parallel Workstream Coordination

### Agent A Responsibilities
- Domain layer (entities, use cases, repositories)
- Data layer (models, datasources, repository implementations) — **Phase 2 first**
- BLoC state management
- Unit testing
- API integrations

### Agent B Responsibilities
- Presentation layer (screens, widgets)
- UI/UX implementation
- Responsive design
- Widget testing
- Theme and styling

### Phase Dependencies

> **Critical:** Agent A must complete Phase 2 (Data Layer) before Agent B can start Phase 4 (Map UI with real geocoding). Agent B uses `MockGeocodingRepository` for UI prototyping in Phase 3.

### Sync Points

| Sync | When | Purpose |
|------|------|---------|
| **M1 Review** | After Phase 1 | Verify architecture alignment |
| **M2 Review** | After Phase 2 | Verify data layer contracts, provide mocks to Agent B |
| **M4 Review** | After Phase 4 | Test BLoC ↔ UI integration |
| **M6 Review** | After Phase 6 | Verify responsive layouts |
| **Daily** | End of each day | Merge conflicts, API contracts |

### Shared Contracts

```dart
// Both agents must agree on these interfaces

// BLoC Events (Agent A defines, Agent B dispatches)
abstract class DestinationEvent extends Equatable {}

// BLoC States (Agent A emits, Agent B consumes)
abstract class DestinationState extends Equatable {}

// Repository Interface (Agent A implements, both use via DI)
abstract class DestinationRepository {
  Future<Either<Failure, Destination>> addDestination(Destination destination);
  Future<Either<Failure, List<Destination>>> getDestinations();
  Future<Either<Failure, void>> deleteDestination(String id);
}

// Geocoding Repository (Agent A implements in Phase 2, Agent B uses via DI)
abstract class GeocodingRepository {
  Future<Either<Failure, LatLng>> getCoordinatesFromAddress(String address);
  Future<Either<Failure, String>> getAddressFromCoordinates(LatLng position);
}
```

---

## 6. Risks & Mitigation

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| OpenStreetMap tile rate limits | High | Medium | Implement caching, use multiple tile providers |
| Geocoding API rate limits (429) | High | Medium | LRU cache (24h TTL), debounce autocomplete (300ms), fallback to Mapbox |
| Location permission denied | High | Low | Graceful fallback, show settings dialog, disable location features |
| BLoC state complexity | Medium | High | Keep states simple, use `Equatable`, write tests first |
| Responsive layout bugs | Medium | Medium | Test on real devices, use golden tests, define clear breakpoints |
| Merge conflicts (parallel) | Medium | High | Daily syncs, clear file ownership, feature branches |
| API key exposure | Critical | Low | `.env` in `.gitignore`, manifest placeholders, restricted keys |

---

## 7. Definition of Done

### Per Feature
- [ ] Code follows Clean Architecture
- [ ] BLoC pattern implemented correctly
- [ ] Unit tests written and passing
- [ ] Widget tests for UI components
- [ ] Responsive on all 3 breakpoints
- [ ] Dark theme tested
- [ ] No linting errors
- [ ] Documentation updated

### Per Phase
- [ ] All phase checkboxes complete
- [ ] Milestone demo successful
- [ ] Code reviewed by other agent
- [ ] No critical bugs open
- [ ] Performance targets met

### Project Completion
- [ ] All 7 phases complete
- [ ] >80% test coverage
- [ ] 60 FPS on target devices
- [ ] App Store / Play Store ready
- [ ] README.md updated
- [ ] AGENTS.md reflects final architecture

---

## 8. Appendix

### File Naming Conventions
- Entities: `destination.dart`, `user_location.dart`
- Models: `destination_model.dart`
- Repositories: `destination_repository.dart`, `destination_repository_impl.dart`
- Use Cases: `add_destination_use_case.dart`
- BLoC: `destination_bloc.dart`, `destination_event.dart`, `destination_state.dart`
- Screens: `map_screen.dart`, `settings_screen.dart`
- Widgets: `destination_list_item.dart`, `floating_search_bar.dart`

### Git Branch Strategy
```
main (protected)
├── develop
│   ├── feature/map-core
│   ├── feature/destination-management
│   ├── feature/search
│   └── feature/responsive-design
```

### Commit Convention
```
<type>(<scope>): <subject>

Types: feat, fix, docs, style, refactor, test, chore
Scope: map, destinations, search, ui, bloc, data, domain
```

Example:
```bash
git commit -m "feat(destinations): add swipe-to-delete gesture"
git commit -m "fix(map): center on user location after permission grant"
git commit -m "test(bloc): add destination_bloc unit tests"
```

---

**Version**: 1.0  
**Last Updated**: $(date +%Y-%m-%d)  
**Authors**: AI Development Team  
**Status**: Approved for Development
