# Numpang Agent Instructions

## General Rules

### Token Efficiency
- Output diffs only. Use `// ... existing code ...` for unchanged sections
- Output whole file only if <200 lines, otherwise changed sections only
- Cap responses at 300 words unless architecting/debugging
- No docstrings or obvious comments. Comments only for complex business "why"
- Use early returns, guard clauses, flat logic

### Skill Usage
- All permission granted, no need to ask for using skills
- Always use related skill in any task
- Always use related skill for this project before using MCP tools
- Read the skill name and description first

### MCP & Tool Usage
- Use `context7` for codebase context and understanding
- Use `github` for external references and best practices
- Plan First, Execute Second: form clear plan before invoking tools
- One tool call per information need. Combine queries with patterns/filters
- Verify capabilities from tool descriptions. Never hallucinate features
- Cache results. Never re-fetch identical data
- Restrict to read-only unless write explicitly approved

### Code Quality
- YAGNI > over-engineering. KISS > clever. DRY only when duplicated 3+ times
- Strict typing: no `any`, `dynamic`, `Object` unless unavoidable
- Max 25 lines per non-UI function; aggressively extract private widgets to keep build() methods lean.
- Prefer composition over inheritance. Explicit dependency injection
- Meaningful names: verb-noun for functions, PascalCase types, snake_case files
- Follow existing project patterns. No new paradigms unless asked
- Minimal diff: least code changes possible

### Security & Validation
- Fail-fast on invalid state. Never swallow errors
- Sanitize inputs at boundary. Escape outputs. Assume external data is malicious
- Never hardcode secrets. Use environment variables + runtime validation
- No security shortcuts (SSL, CORS, standards)

### Workflow
- Plan → Spec → Impl → Verify. Output file tree before coding
- Wait for explicit "Proceed" before writing code/modifying files
- Evidence-based debugging: reproduce → isolate → verify → propose → test

### Error Handling
- Propagate errors to explicit boundaries. Never empty catch blocks
- User-friendly message + detailed stack trace in dev mode
- Structured error types with codes and context

### State & File Management
- Delete dead code immediately
- No `// TODO` without timeline or issue reference
- Update type definitions before implementation

### Response Format
- Output file path followed by code block
- Separate multiple files with `---`
- No explanatory text outside code blocks unless asked

## Quick Commands

```bash
flutter pub get                              # install deps
flutter pub run flutter_flavorizr            # generate flavors (run once after clone)
flutter run --flavor dev                     # run dev flavor
flutter run --flavor prod                    # run prod flavor
flutter test --coverage                      # all tests with coverage
flutter test test/bloc/                      # BLoC tests only
flutter pub run build_runner build --delete-conflicting-outputs
```

**Note:** macOS flavors must be run from Xcode due to a Flutter SDK bug. Select the scheme (dev/prod) in Xcode and press Run.

## Architecture

**Clean Architecture + MVVM + BLoC**

```
lib/
├── core/          # constants, errors, theme, utils
├── data/          # datasources, models, repositories
├── domain/        # entities, repositories, usecases (pure Dart, NO Flutter imports)
├── presentation/  # bloc/, screens/, widgets/, responsive/
└── flavors/       # main_dev.dart, main_prod.dart
```

**Rules:**
- BLoC handles state
- Provider handles DI (Dependency Injection)
- Use `Either<Failure, T>` from `dartz` for error handling
- All BLoC states/events extend `Equatable`

## Environment

**Required `.env` in project root:**
```env
MAPBOX_ACCESS_TOKEN=your_key_here
GEOCODE_XYZ_API_KEY=your_key_here
```

> **Note:** This project uses `flutter_map` with OpenStreetMap which does NOT require an API key.

**NEVER commit:** `.env`, API keys, credentials

## Design System

**Amber Map System** (see `DESIGN.md`):

- **Primary**: `#FFCA28` (critical actions, active states)
- **User Blue**: `#2196F3` (user location, active route ONLY)
- **Surface (Dark)**: `#1A1C1C`
- **Font**: Plus Jakarta Sans
- **Elevation**: Level 0 (map) → Level 3 (FABs)

## Platform Support

| Platform | Target | Notes |
|----------|--------|-------|
| Android | `--flavor dev/prod` | API 21+ |
| iOS | `--flavor dev/prod` | iOS 12+ |
| macOS | `-d macos --flavor` | 10.15+ |

### Bundle ID Organization

| Flavor | Android Application ID | iOS/macOS Bundle ID |
|--------|------------------------|---------------------|
| dev | `com.rizkyeky.numpangdev` | `com.rizkyeky.numpangdev` |
| prod | `com.rizkyeky.numpang` | `com.rizkyeky.numpang` |

**Breakpoints:** Phone <600px | Tablet 600-1024px | Desktop >1024px

## Project Skill Usage

- flutter-expert skill is primary skill for this project.
- Use related flutter skills if it is not covered by flutter-expert skill
- Use any skills related to your task
- Do not use flutter-getit-architecture skill in this project

## Library & API Implementation

When implementing any library or API, follow this hierarchy:

1. **Flutter related skills** - Always check skills first (flutter-expert (Primary), flutter-*, etc.)
2. **Official documentation** - If skills lack content, read official docs:
   - **Geocode.xyz**: https://geocode.xyz/api
   - **Mapbox**: https://docs.mapbox.com/api/search/geocoding/
   - **flutter_map**: https://docs.fleaflet.dev/
   - **Dio**: https://pub.dev/packages/dio
3. **Community code** - If no official docs available, search:
   - `context7` MCP for library documentation
   - `grep_search` for patterns in this codebase
   - `mcp7_search_code` for real-world GitHub examples

**Rules:**
- Never assume API behavior
- Never hallucinate method signatures or response structures
- Verify all parameters and return types against official sources
- Copy-paste exact API endpoint URLs and method names from docs

## Git & GitHub

This project uses **GitHub MCP** (not `gh` CLI) for GitHub operations. All GitHub interactions via `github-mcp-*` tools.

### Branch Naming

```
feature/add-destination-search
fix/map-centering-issue
chore/update-dependencies
docs/api-changes
refactor/auth-flow
```

### Committing

```bash
git add .
git commit -m "feat: add destination search"
```

**Conventional Commits:** `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`

AI commits MUST include:
```
Co-Authored-By: (agent name and attribution)
```

### Pushing

```bash
git push origin feature/add-destination-search
```

### Creating Pull Requests

Use `github-mcp_create_pull_request` tool:
- `head`: your branch name
- `base`: target branch (e.g., `main`)
- `title`: clear PR title with conventional commit prefix
- `body`: summary of changes

### GitHub MCP Tools

| Operation | Tool |
|-----------|------|
| Create PR | `github-mcp_create_pull_request` |
| List PRs | `github-mcp_list_pull_requests` |
| Get PR details | `github-mcp_pull_request_read` |
| Create branch | `github-mcp_create_branch` |
| Commit changes | `github-mcp_push_files` |
| Merge PR | `github-mcp_merge_pull_request` |

### Git Expert Skill

For complex Git operations (rebase, merge conflicts, recovery), use the **git-expert** skill:
```
/git-expert
```

**NEVER commit:** `.env`, API keys, credentials

## Testing

- Unit tests: `test/bloc/`, `test/domain/`, `test/data/`
- Widget tests: `test/widgets/`
- Use `bloc_test` for BLoC testing
- No integration tests (project constraint)

## Key Patterns

```dart
// BLoC Event/State - all extend Equatable
abstract class DestinationEvent extends Equatable {}
abstract class DestinationState extends Equatable {}

// Use Case with Either return type
class AddDestinationUseCase {
  Future<Either<Failure, Destination>> call(Destination destination);
}

// Repository interface
abstract class DestinationRepository {
  Future<Either<Failure, Destination>> addDestination(Destination destination);
}
```

## Gotchas

1. **Flavors** require separate entry points (`lib/flavors/main_*.dart`)
2. **flutter_map** uses OpenStreetMap - no API key needed for maps or geocoding
3. **Geocoding** uses Nominatim (primary), Geocode.xyz, Mapbox (secondary) - no API key required
4. **Location permissions** required for Android, iOS, macOS
5. **Bottom sheet** has 3 states: Collapsed → Half → Full
6. **No update** for destinations - only add/delete (CRUD without U)
7. **Map tap** adds destination, **search** centers then user adds

## References

- `README.md` - Full setup, dependencies, configuration
- `DESIGN.md` - Amber design system tokens, components, typography
- `pubspec.yaml` - Dependencies and versions
