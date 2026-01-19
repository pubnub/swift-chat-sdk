# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

PubNub Swift Chat SDK - A Swift wrapper providing idiomatic iOS/macOS/tvOS APIs for real-time chat functionality. The SDK wraps the Kotlin Multiplatform (KMP) Chat SDK core via the `PubNubChat` dependency.

**Requirements:** iOS 14+, macOS 11+, tvOS 14+, Xcode 15+, Swift 5+

## Build Commands

```bash
# Build with Swift Package Manager
swift build

# Build with Xcode
xcodebuild -workspace PubNubSwiftChatSDK.xcworkspace -scheme PubNubSwiftChatSDK build

# Resolve package dependencies
swift package resolve
```

## Testing

Tests are integration tests that require PubNub API keys.

### Running Tests Locally

1. Configure test credentials in `Tests/PubNubSwiftChatSDKTests.plist`:
   ```xml
   <key>publishKey</key>
   <string>YOUR_PUBLISH_KEY</string>
   <key>subscribeKey</key>
   <string>YOUR_SUBSCRIBE_KEY</string>
   ```

2. Run tests:
   ```bash
   # Via Xcode (recommended)
   xcodebuild test -workspace PubNubSwiftChatSDK.xcworkspace \
     -scheme PubNubSwiftChatSDK \
     -destination 'platform=iOS Simulator,name=iPhone 15'

   # Via fastlane (requires Ruby/Bundler and env vars)
   export SDK_PUB_KEY="your_key"
   export SDK_SUB_KEY="your_key"
   bundle exec fastlane test --env ios
   ```

### Test Schemes

- `PubNubSwiftChatSDK` - Main SDK scheme
- `PubNubSwiftChatSDKTests` - Closure-based integration tests
- `PubNubSwiftChatSDKAsyncTests` - Async/await integration tests

## Linting

```bash
swiftlint
```

Configuration in `.swiftlint.yml` - line length 150, includes Sources/ and Tests/.

## Documentation Snippets

`Snippets/` contains compilable code examples used in PubNub documentation. These are validated during CI/CD to ensure customer-facing docs remain accurate.

**When modifying public APIs**, update corresponding snippets to prevent build failures.

## Architecture

### Dependency Chain

```
PubNubSwiftChatSDK (this repo)
    └── PubNubChat (KMP compiled for Swift) - core implementation
    └── PubNubSDK (Swift SDK) - low-level PubNub APIs
```

### Source Structure

- **`Sources/Chat/`** - Main entry point
  - `Chat.swift` - Protocol defining all chat operations
  - `ChatImpl.swift` - Implementation wrapping KMP `PubNubChat.ChatImpl`
  - `ChatConfiguration.swift` - SDK configuration options

- **`Sources/Entities/`** - Domain objects (each has protocol + impl + async extension)
  - `Channel`, `User`, `Message`, `Membership`, `ThreadChannel`, `ThreadMessage`, `ChannelGroup`
  - Pattern: `Entity.swift` (protocol) + `EntityImpl.swift` (KMP wrapper) + `Entity+AsyncAwait.swift`

- **`Sources/MessageDraft/`** - Message composition with mentions/references

- **`Sources/Extensions/`** - Type conversions between Swift and KMP types

- **`Sources/Models/`** - Data transfer objects (`Event`, `EventContent`, `File`, etc.)

### Key Patterns

1. **Protocol + Implementation**: Each entity has a public protocol (e.g., `Channel`) and internal implementation (e.g., `ChannelImpl`) that wraps the KMP type

2. **Dual API Surface**: All async operations have both:
   - Closure-based: `func getUser(userId:completion:)`
   - Async/await: `func getUser(userId:) async throws -> User`

3. **KMP Bridge**: `ChatImpl` creates the KMP core via `ChatImpl.createKMPChat()` and all entity implementations hold references to both the KMP object and the parent `ChatImpl`

4. **Stream Handling**: Real-time updates return `AutoCloseable` - callers must retain strong reference to continue receiving updates

### Entity Ownership

All entities hold a strong reference to `Chat`:
```swift
// ChannelImpl.swift
let chat: ChatImpl
let channel: PubNubChat.Channel_  // KMP type
```

## Test Structure

- `Tests/BaseIntegrationTestCase.swift` - Base class with `chat: ChatImpl` and helpers
- `Tests/AsyncAwait/BaseAsyncIntegrationTestCase.swift` - Async test base class
- `Tests/Common/IntegrationTestCaseConfiguration.swift` - Creates test `ChatImpl` instances
- Entity-specific tests: `ChannelIntegrationTests.swift`, `MessageIntegrationTests.swift`, etc.

## Dependencies

Defined in `Package.swift`:
- `PubNubChat` (kmp-chat) - KMP core, exact version pinned
- `PubNubSDK` (swift) - Low-level SDK, exact version pinned
