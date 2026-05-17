# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

BlueSnap iOS SDK (`BluesnapSDK`) — a payment SDK enabling credit card, Apple Pay, and PayPal payments in iOS apps. Tokenizes payment data and sends it directly to BlueSnap servers (PCI compliance handled by BlueSnap). Current version: **2.1.3**.

**This is the private internal development repo** (intrinisec org). The public repo is at `bluesnap/bluesnap-ios`. Never commit API credentials, internal development keys, or secrets. The `credentials.plist` files are populated at CI time via environment variables.

SDK consumers expect a polished developer experience. Apple frequently updates iOS/Xcode — keep minimum deployment targets, Swift versions, and framework compatibility in mind.

## Build & Development

**Workspace:** `BluesnapIOS.xcworkspace` (not the `.xcodeproj`)

**Package managers supported:**
- **SPM** (primary) — `Package.swift`, iOS 12.0+, Swift 5.7.1+
- **CocoaPods** — `BluesnapSDK.podspec`, iOS 12.0+, Swift 5.0+

**SPM build from command line:**
```bash
swift build
```

**Binary dependencies** (checked into `Frameworks/XCFrameworks/`):
- `CardinalMobile.xcframework` — 3D Secure (Cardinal Commerce)
- `KountDataCollector.xcframework` — Fraud detection (Kount)
- `KountWrapper` — Required companion target for SPM consumers, even if not using Kount

## Running Tests

Tests require the `BluesnapIOS.xcworkspace`. Credentials for integration/UI tests are injected via `PlistBuddy` into `credentials.plist` files (see `bitrise.yml` for the exact commands).

**Unit tests** (no credentials needed):
```bash
xcodebuild test -workspace BluesnapIOS.xcworkspace -scheme BluesnapSDK -testPlan BluesnapSDK -destination 'platform=iOS Simulator,name=iPhone 14'
```

**Integration tests** (require `BS_API_USER` and `BS_API_PASSWORD`):
```bash
xcodebuild test -workspace BluesnapIOS.xcworkspace -scheme BluesnapSDK -testPlan BluesnapSDKIntegration -destination 'platform=iOS Simulator,name=iPhone 14'
```

**UI tests** (require credentials + simulator):
```bash
xcodebuild test -workspace BluesnapIOS.xcworkspace -scheme BluesnapSDKExample -testPlan SanityUITests -destination 'platform=iOS Simulator,name=iPhone 14'
```

Additional UI test plans: `NewShopperUITests`, `ReturningShopperUITests`.

**Run a single test:**
```bash
xcodebuild test -workspace BluesnapIOS.xcworkspace -scheme BluesnapSDK -testPlan BluesnapSDK -destination 'platform=iOS Simulator,name=iPhone 14' -only-testing:'BluesnapSDKTests/BSValidatorTests/testValidateCCN'
```

## CI/CD

**GitHub Actions** (`.github/workflows/`)

**`ci.yml`** — runs on every push and PR:
- `unit-tests` — scheme `BluesnapSDK`, test plan `BluesnapSDK` (every push/PR)
- `integration-tests` — scheme `BluesnapSDK`, test plan `BluesnapSDKIntegration` (every push/PR)
- `ui-tests` — scheme `BluesnapSDKExample`, test plan `SanityUITests` (PRs to `main` only)

All jobs run in parallel on `macos-15` with latest stable Xcode. Concurrency group cancels superseded runs.

**`ci-beta.yml`** — manual `workflow_dispatch` for testing against Xcode betas. Runs unit + integration tests only.

**Secrets** (`BS_API_USER`, `BS_API_PASSWORD`) are GitHub repository secrets, added via `gh secret set`. Injected at runtime via PlistBuddy into gitignored `credentials.plist` files. Never committed to code.

## Architecture

### SDK Entry Point
- `BlueSnapSDK` — Static initialization, token setup, SDK configuration
- `BSApiManager` — Public API layer: token management, merchant data, shopper operations
- `BSApiCaller` — Internal HTTP request handling to BlueSnap servers

### Payment Flows (three options for consumers)
1. **Standard Checkout (SDK UI)** — Pre-built view controllers (`BSStartViewController` → `BSPaymentViewController` → `BSShippingViewController`). Supports CC, Apple Pay, PayPal.
2. **Custom Checkout** — Consumer uses `BSCcInputLine` component in their own UI, SDK handles tokenization.
3. **Own UI** — Consumer builds everything, uses `BSApiManager` for API calls directly.

### 3D Secure
- `BSCardinalManager` — Wraps Cardinal Mobile SDK for 3DS authentication
- Flow: `BS3DSAuthRequest` → Cardinal SDK challenge → `BS3DSProcessResultRequest` → `ThreeDSManagerResponse`
- Results: `SUCCEEDED`, `BYPASSED`, `UNAVAILABLE`, `FAILED`, `ERROR`, `CANCELED`

### Apple Pay
- `BSApplePayConfiguration` → `BSApplepayPayment` → `PaymentOperation` (async)
- The SDK collects the PKPayment token and sends it encrypted to BlueSnap; app developers don't handle the raw token.

### Key Models
- `BSTokenizeRequest` / `BSTokenizeNewCCDetails` / `BSTokenizeExistingCCDetails` — Tokenization
- `BSSdkRequest` / `BSSdkRequestShopperRequirements` — SDK configuration
- `BSBaseSdkResult` / `BSCcSdkResult` / `BSExistingCcSdkResult` — Payment results
- `BSBillingAddressDetails` / `BSShippingAddressDetails` — Address data

### Patterns
- All SDK classes prefixed with `BS`
- Manager pattern with static methods (`BSApiManager`, `BSCardinalManager`, `BSCountryManager`)
- Completion-block async (no async/await or Combine)
- Manual JSON parsing (not Codable)
- MVC with UIViewController subclasses for checkout screens
- Localized to 20+ languages via `.strings` files in `Sources/BluesnapSDK/Resources/`

## Release Process

Use `release_git_tag.sh <version>`:
1. Creates `release-<version>` branch
2. Updates `BLUESNAP_API_VERSION_HEADER_VAL` in `BSApiCaller.swift`
3. Commits, pushes branch and tag

Also update version in `BluesnapSDK.podspec` and `Package.swift` as needed.

## Sensitive Files — Do Not Commit With Real Values

- `Sources/BluesnapSDK/Resources/credentials.plist` — API credential template
- `Tests/BluesnapSDKIntegrationTests/Resources/credentials.plist` — Test credential template
- Any `.env` or credential files

## Landscape Mode

SDK UI does not support landscape. Consumer apps must lock to portrait orientation (documented in README).
