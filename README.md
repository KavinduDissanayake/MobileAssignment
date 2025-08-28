# MobileAssignment

A SwiftUI iOS app that lists random users from an API with basic navigation to a detail screen. The project demonstrates a clean MVVM structure, dependency separation (Domains, Utility, Core), navigation routing, and a lightweight networking layer.

## Architecture Diagram
![Architecture Diagram](https://raw.githubusercontent.com/KavinduDissanayake/MobileAssignment/dev/architecture_diagram.png)

## Requirements
- Xcode 15+ / iOS 17+ (min compatible with your local setup)
- Swift Concurrency (async/await)

## Getting Started
1. Open `MobileAssignment.xcodeproj` in Xcode.
2. Select the `Dev` or `Prod` scheme.
3. Build and run on a simulator or device.

## Folder Structure
```text
MobileAssignment/
  App/
    RandomUserApp.swift        // App entry point
    RootView.swift             // Root SwiftUI view and routing modifier
  CommonViews/
    CachedAsyncImage.swift     // Simple cached async image loader
  Core/
    BaseAction.swift           // Analytics/action ID protocols
    BaseViewModel.swift        // Generic base VM with loading/error handling
  Domains/
    User+Preview.swift         // Preview data
    UserDomain.swift           // Domain layer & endpoints
    UserListResponse.swift     // API models (User, Info, etc.)
  Extensions/
    String++.swift             // String helpers
  SupportFiles/
    Assets.xcassets/           // App assets & icons
    Config/
      Constants.swift          // Build-time configuration helpers
      DevConfig.xcconfig       // Dev configuration
      ProdConfig.xcconfig      // Prod configuration
    Info.plist                 // App info plist
  Utility/
    Logger.swift               // Centralized logging utility
    Navigations/
      Destination.swift        // Route destinations
      NavigationItem.swift     // Navigation item model
      Router.swift             // Router with stack management
      ViewFactory.swift        // Maps destinations to views
    NetworkService/
      NetworkError.swift       // Typed network errors
      NetworkService.swift     // Networking adapter (encoding/headers)
      NetworkTypes.swift       // HTTP method, parameter encoding
  View+ViewModel/
    UserDetailView/
      UserDetailView.swift     // User detail screen
    UserListView/
      SubViews/
        ErrorView.swift        // Error state UI
        LoadingView.swift      // Loading state UI
        UserListContentView.swift // List content
        UserRowView.swift      // Single row UI
      UserListActions.swift    // Action & UIAction enums
      UserListView.swift       // Entry list view
      UserListViewModel.swift  // View model for list screen
```

## Key Types and Functions

### App & Views
- `RandomUserApp: App` — app lifecycle and scene setup.
- `RootView: View` — wraps navigation and applies route handling.
- `UserListView: View` — shows list with loading and error states.
- `UserDetailView: View` — details for a selected user.
- `UserListContentView`, `UserRowView`, `LoadingView`, `ErrorView` — UI components.

### MVVM Core
- `BaseViewModel<ActionId, UIAction>`
  - `setLoading(_:for:)`, `isLoading(for:)`, `error(for:)`
  - `onError(actionId:error:)`, `onStatusUpdate(actionId:isLoading:)`
  - `dispatchUIAction(_:)`, `triggerUIAction(actionId:)`, `onUIAction(_:)`, `logUIAction(_:)`
- `BaseAction.swift`
  - `ActionIdType`, `UIActionType`, `AnalyticsIdentifiable`, `AnalyticsEventsInfo`

### User List Feature
- `UserListViewModel`
  - `loadUsers()` — initial load
  - `loadMoreUsers()` — pagination
  - `refreshUsers()` — pull-to-refresh
  - Internal: `generateNewSeed()`, `filterUsers()`
- `UserListActions` / `UserListUIActions` — action identifiers.

### Domain Layer
- `UserDomainProtocol`
  - `fetchUsers(page:results:) async throws -> [User]`
- `UserDomain` — implements `fetchUsers` using `UserEndPoint`.
- Models in `UserListResponse.swift`: `User`, `Info`, `Name`, `Location`, etc.

### Navigation
- `Router`
  - `navigate(to:_:)`, `navigateBack()`, `navigateToRoot()`, `navigationPathRest()`
- `Destination` — enum of all app routes.
- `ViewFactory`
  - `setViewForDestination(_:_: ) -> some View`, `setRootView()`, `isAuthenticated() -> Bool`

### Networking
- `NetworkService`
  - Internals: `getAlamofireEncoding(_:)`, `getHeaders(encoding:method:)`
- `NetworkError: LocalizedError` — error cases.
- `NetworkTypes` — `HTTPMethod`, `APIParameterEncoding`.

### Utilities
- `Logger`
  - `configure(_:)`, `log(...)`
  - Convenience: `error(_:)`, `warning(_:)`, `success(_:)`, `info(_:)`, `action(_:)`, `canceled(_:)`, `debug(_:)`, `network(_:)`
  - Maintenance: `getLogFiles()`, `clearLogs()`, `getLogContent(for:)`
- `Constants`
  - `isLoggingEnabled()` and plist helpers
- `String++`
  - `formatDate()` — date string formatting helper
- `CachedAsyncImage`
  - Async image loading with in-memory cache

## Running Tests
- Unit tests: open the `MobileAssignmentTests` scheme and run tests in Xcode.
- UI tests: open the `MobileAssignmentUITests` scheme and run.

## Notes
- Architecture: MVVM with a thin domain layer and lightweight navigation routing.
- Configuration: `Dev` and `Prod` schemes using `.xcconfig` files and `Constants` helpers.
- Logging: centralized via `Logger` with multiple destinations (console, OSLog, file, remote-ready).
