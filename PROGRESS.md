# Transit — Progress Log

---

## Phase 0 — Project Setup & Architecture Skeleton
**Date:** 2026-09-17

### Built
- Full folder structure (core/ + 6 feature modules, each with data/domain/presentation)
- `pubspec.yaml` with all runtime and dev dependencies
- Design tokens (`tokens.dart`) — spacing, radius, colors, typography, elevation, layout constants
- App theme (`theme.dart`) — ThemeData with Inter font via google_fonts
- `safeEmit` extension on Cubit
- Firebase init wrapper (graceful fail without config files)
- GoRouter config with all routes (placeholder screens)
- GetIt DI injector — all Cubits registered as factories
- 11 Cubit+States skeleton pairs:
  - `AuthCubit` / `AuthStates`
  - `GarageCubit` / `GarageStates`
  - `BusCubit` / `BusStates`
  - `ErrandCarCubit` / `ErrandCarStates`
  - `DriverCubit` / `DriverStates`
  - `GarageAdminCubit` / `GarageAdminStates`
  - `BusAdminCubit` / `BusAdminStates`
  - `ErrandAdminCubit` / `ErrandAdminStates`
  - `DriverAdminCubit` / `DriverAdminStates`
  - `AccessAdminCubit` / `AccessAdminStates`
- `analysis_options.yaml` updated (generated file exclusions, tighter lints)
- `PROGRESS.md` created

### Stubbed / Placeholder
- All route screens are placeholder (construction icon + "Coming soon")
- Firebase configured with DefaultFirebaseOptions (Android & iOS config files added)
- No real logic in any Cubit yet
- `core/widgets/` is empty — shared widgets built in Phase 1

### Key Decisions
- Package name kept as `alex_transportation` (avoids native config churn)
- Display name is "Transit" (in MaterialApp title, branding)
- go_router for routing, dio for HTTP, Inter font via google_fonts
- Freezed union states pattern with `safeEmit` — non-negotiable across all Cubits
- One admin Cubit+States per tab (5 pairs) so tab actions don't block each other

### Open for Next Phase
- Phase 1 completed on branch `phase-1`

---

## Phase 1 — Visual Identity, Splash, Lottie Onboarding, Access Gate & Loading HUD
**Date:** 2026-09-17
**Branch:** `phase-1`

### Built
- **App Icon**: High-resolution AlexBank Transportation corporate icon (`assets/images/app_icon.png`) with emerald green `#1B4332` and gold `#C8973A` mobility emblem.
- **Brand SVG**: AlexBank Transit green logo (`assets/icons/alexbank_green_logo.svg`).
- **3 Lottie Animations**:
  - `assets/lottie/garage_parking.json` (barrier arm, entering car, checkmark & glow)
  - `assets/lottie/bus_shuttle.json` (corporate bus, animated wheels, pulsating GPS pin)
  - `assets/lottie/errand_dispatch.json` (business errand sedan, digital key & ring handover)
- **Global Loading Standard**:
  - `CustomLoadingIndicator`: Repeating `RotationTransition` on AlexBank green logo.
  - `AppLoadingHUD`: `ModalProgressHUD` overlay wrapper with darkened background.
- **Shared Design System Widgets**:
  - `AppButton`: Primary, Secondary, Outline, Text variants with token styling.
  - `AppTextField`: Clean input with prefix/suffix icons, uppercase formatter, and token borders.
  - `AppCard`: Standard token-styled surface card.
  - `StatusPill`: Active, Pending, Danger, Neutral, Gold badge pills.
- **Screens**:
  - `SplashPage`: Animated brand scale/fade reveal, session and onboarding check.
  - `OnboardingPage`: 3-slide PageView with Lottie animations, animated dots, skip/next/get-started controls.
  - `AccessGatePage`: Invite-code verification, `ModalProgressHUD` loading state, demo shortcut chips, and error snackbars.
- **Routing & State**:
  - Connected in `AppRouter` (`/splash`, `/onboarding`, `/access`).
  - `AuthCubit` enhanced with session persistence, role decoding, and Firestore/offline fallback verification.
- **Tests**:
  - Unit and widget test suite (8/8 passing).

### Key Decisions
- Every loading state in the application wraps with `ModalProgressHUD` + `CustomLoadingIndicator` (black 50% opacity backdrop with continuous rotating brand logo).
- Branching workflow: all phase changes committed and pushed to `phase-1`.

### Open for Next Phase
- Phase 2 completed on branch `phase-2`

---

## Phase 2 — Employee Garage Parking Module
**Date:** 2026-09-17
**Branch:** `phase-2`

### Built
- **Data Model**:
  - `GarageSubscriptionModel` ([garage_subscription_model.dart](file:///Users/haithammagdy/Flutter/alex_transportation/lib/features/garage/data/models/garage_subscription_model.dart)): Pure `@JsonSerializable()` data model (without Freezed) with `fromJson`, `toJson`, and `copyWith`.
  - `garage_subscription_model.g.dart`: Generated via `build_runner` + `json_serializable`.
- **Cubit Logic**:
  - `GarageCubit` ([garage_cubit.dart](file:///Users/haithammagdy/Flutter/alex_transportation/lib/features/garage/presentation/bloc/garage_cubit.dart)):
    - Live garage slots tracking: 300 total, 42 available, 10 VIP.
    - `submitSubscription`: Form validation (national ID, 5-digit ISL, AlexBank work email, EGP 1,200 payroll deduction consent), auto slot assignment or waiting list enqueue.
    - `checkInOut`: Button toggle updating bay occupancy and check-in timestamp.
    - `requestCancellation`: Submits cancellation request with ISL and email.
    - `findSubscription`: Status lookup for existing employee records.
- **Widgets & UI**:
  - `GaragePassCard` ([garage_pass_card.dart](file:///Users/haithammagdy/Flutter/alex_transportation/lib/features/garage/presentation/widgets/garage_pass_card.dart)):
    - Digital parking pass card with assigned bay (`P1-014`), level, and ISL.
    - Live status banner and 1-tap Check In / Check Out toggle button (no QR codes, no barrier gate).
  - `GaragePage` ([garage_page.dart](file:///Users/haithammagdy/Flutter/alex_transportation/lib/features/garage/presentation/pages/garage_page.dart)):
    - Live capacity banner with real-time bay count and occupancy progress bar.
    - 4 tab views: **My Pass**, **Subscribe** (with EGP 1,200 payroll notice), **Status Lookup**, and **Cancel Request**.
    - Fully wrapped with `ModalProgressHUD` + `CustomLoadingIndicator` for all async actions.
  - `HomePage` ([home_page.dart](file:///Users/haithammagdy/Flutter/alex_transportation/lib/features/home/presentation/pages/home_page.dart)):
    - AlexBank corporate header with official logo, role pill, and logout confirmation dialog.
    - Top Module Switcher: 🅿️ Garage (Active), 🚌 Buses (Phase 3 preview), 🚗 Errand Cars (Phase 4 preview).
- **Routing**:
  - `AppRouter` updated: `/home` routes to `HomePage()`.
- **Tests**:
  - Unit tests for pure `json_serializable` serialization and deserialization.
  - Unit tests for `GarageCubit` operations.
  - Total test suite: 16/16 tests passing.
  - `flutter analyze`: 0 issues.

### Key Decisions
- Pure `json_serializable` used for all data models (no Freezed for models).
- ModalProgressHUD with rotating brand logo enforced for all async operations.

### Open for Next Phase
- Phase 3 completed on branch `phase-3`

---

## Phase 3 — Employee Bus Transit Module
**Date:** 2026-09-17
**Branch:** `phase-3`

### Built
- **Data Models (Pure `json_serializable`)**:
  - `BusStopModel` ([bus_stop_model.dart](file:///Users/haithammagdy/Flutter/alex_transportation/lib/features/buses/data/models/bus_stop_model.dart)): Sequence of transit stops with English/Arabic names, scheduled time, completed and current status.
  - `BusRouteModel` ([bus_route_model.dart](file:///Users/haithammagdy/Flutter/alex_transportation/lib/features/buses/data/models/bus_route_model.dart)): Shuttle route with shift (Morning/Evening), departure/arrival times, total/available seat counters, driver info, and stop manifests.
  - `BusBoardingPassModel` ([bus_boarding_pass_model.dart](file:///Users/haithammagdy/Flutter/alex_transportation/lib/features/buses/data/models/bus_boarding_pass_model.dart)): Digital boarding pass with seat assignment and pickup stop.
- **Cubit Logic**:
  - `BusCubit` ([bus_cubit.dart](file:///Users/haithammagdy/Flutter/alex_transportation/lib/features/buses/presentation/bloc/bus_cubit.dart)):
    - 5 realistic routes across Cairo & Giza (Maadi HQ Express, New Cairo, Heliopolis & Nasr City, 6th October/Zayed, Evening Return).
    - Shift filter toggling (`All`, `Morning`, `Evening`).
    - Route stop timeline selection.
    - Seat booking flow with capacity check, seat number assignment, and boarding pass generation.
    - Check-in with driver (`boarded` status).
    - Seat cancellation with automated seat restoration on route.
- **Widgets & UI**:
  - `BusBoardingPassCard` ([bus_boarding_pass_card.dart](file:///Users/haithammagdy/Flutter/alex_transportation/lib/features/buses/presentation/widgets/bus_boarding_pass_card.dart)):
    - Digital boarding pass with seat badge (`#14`), pickup stop, departure time, status banner, and 1-tap "Board Bus" / "Cancel Reservation" actions (no QR codes).
  - `BusStopTimeline` ([bus_stop_timeline.dart](file:///Users/haithammagdy/Flutter/alex_transportation/lib/features/buses/presentation/widgets/bus_stop_timeline.dart)):
    - Vertical stepper indicator showing completed stops (green checkmark), current bus position (pulsing badge), and upcoming stops.
    - Interactive pickup stop selector.
  - `BusesPage` ([buses_page.dart](file:///Users/haithammagdy/Flutter/alex_transportation/lib/features/buses/presentation/pages/buses_page.dart)):
    - Active boarding pass hero card.
    - Shift filter pill switcher.
    - Route cards with capacity pill, live status, driver details with direct call action, expandable stop timeline, and one-tap seat booking.
    - Wrapped with `ModalProgressHUD` + `CustomLoadingIndicator` for all async actions.
  - `HomePage` ([home_page.dart](file:///Users/haithammagdy/Flutter/alex_transportation/lib/features/home/presentation/pages/home_page.dart)):
    - Connected `BusesPage` to the **🚌 Buses** tab with badge set to **Active**.
- **Tests**:
  - `bus_models_test.dart`: Pure `json_serializable` serialization/deserialization for all bus models.
  - `bus_cubit_test.dart`: Complete unit tests covering shift filters, seat booking, capacity limits, cancellation, and driver check-in.
  - Test suite: **25/25 tests passing**.
  - `flutter analyze`: **0 issues found**.

### Key Decisions
- Pure `json_serializable` maintained for all data models.
- Interactive vertical stepper timeline used for stop manifests.

### Open for Next Phase
- Phase 4 completed on branch `phase-4`
- Phase 5 completed on branch `phase-5`
- Phase 6 completed on branch `phase-6`

---

## Phase 4 — Employee Errand Cars Module
**Date:** 2026-09-17
**Branch:** `phase-4`

### Built
- **Data Models (Pure `json_serializable`)**:
  - `ErrandCarModel`: Fleet vehicle specifications, license plate, status, odometer reading.
  - `ErrandRequestModel`: Dual-point errand mission request (pickupLocation, destination, purpose, departure & return schedule, supervisor approval).
  - `ErrandDispatchPassModel`: Official executive dispatch pass with start/end mileage, driver assignment, and dual-point journey route.
- **Cubit Logic**:
  - `ErrandCarCubit`: Fleet management, request submission with dual-point routing validation, vehicle assignment, mission start, and mileage completion.
- **Widgets & UI**:
  - `ErrandCarsPage`: Fleet availability bar, active missions tab, request submission form with quick hub chips, and request history.
  - `ErrandDispatchPassCard`: Executive smart pass displaying Pickup $\rightarrow$ Destination, departure/return schedule, and mileage tracker.
  - `ErrandRequestHistoryCard`: History card displaying dual-point route journey.

---

## Phase 5 — Driver Captain Portal (`/driver`)
**Date:** 2026-09-18
**Branch:** `phase-5`

### Built
- **Data Models (Pure `json_serializable`)**:
  - `DriverProfileModel`: Driver identity, commercial license, assigned vehicle and route.
  - `DriverTripModel`: Active trip status, route details, and boarding manifest.
  - `TripManifestItemModel`: Passenger boarding manifest item.
- **Cubit Logic**:
  - `DriverCubit`: Safety inspection checklist, trip departure, sequential stop progression, passenger check-in toggle, trip completion.
- **Widgets & UI**:
  - `DriverPage`: Hero profile banner, 6-point vehicle safety inspection checklist, active trip controls, upcoming stop navigator, and passenger boarding roster.
- **Routing**:
  - `/driver` wired to `DriverPage` in `AppRouter`.

---

## Phase 6 — Enterprise Operations Admin Console (`/admin`)
**Date:** 2026-09-18
**Branch:** `phase-6`

### Built
- **Data Models & State**:
  - `InviteCodeModel`: Pure `json_serializable` model for access tokens with role, department, usage counter, and active status.
  - `AdminCubit` & `AdminStates`: Tab management, invite code generation/revocation, driver roster, and operational metrics.
- **Bus Transit Bidirectional Routing**:
  - 8 bidirectional routes: 4 morning lines terminating at **Smart Village (AlexBank HQ)** and 4 mirrored evening lines originating at **Smart Village (AlexBank HQ)** returning to Cairo/Giza in reverse order.
  - Admin controls in `BusCubit`: `addStationToRoute`, `removeStationFromRoute`, `updateStationTime`, and `generateReverseEveningRoute` (1-tap mirrored evening return synchronization).
- **Dynamic Garage Monthly Fee (User Requirement #7)**:
  - Configured and adjustable by admin in `GarageCubit` and `GarageAdminCubit` (default 1,200 EGP, with $\pm 100$ steppers and direct tariff updates).
  - Pure button check-in / check-out (zero QR code scanning).
- **Dual-Point Errand Routing (User Requirement #10)**:
  - Both Pickup Location and Destination captured and prominently displayed across all cards, forms, and admin manifests.
- **Admin Portal Views (`lib/features/admin/presentation/widgets/`)**:
  - `BusAdminView`: Route manifest timetable, station adding/removal, time editing, and 1-tap mirrored return route sync.
  - `GarageAdminView`: Dynamic monthly fee stepper, facility capacity overview, and active subscriptions manifest.
  - `ErrandAdminView`: Mission request manifest with dual-point route cards (Pickup $\rightarrow$ Destination) and fleet availability matrix.
  - `DriverAdminView`: Transportation captains and chauffeurs roster with ratings, vehicle plates, and route assignments.
  - `AccessAdminView`: Secure invite code generator, active codes table with active/inactive toggle, and quick test role switcher (Employee / Driver / Admin).
  - `AdminPage`: Master console page coordinating all 5 pillars with AlexBank branding and TabBar navigation.
- **Routing & Navigation**:
  - Wired `/admin` in `AppRouter`.
  - Updated `AccessGatePage` to route role `admin` to `/admin`, `driver` to `/driver`, and `employee` to `/home`.
  - Added Admin Console shortcut icon in `HomePage` header.
- **Testing & Verification**:
  - Full test suite: **86/86 tests passing across all features**.
  - `flutter analyze`: **0 issues found**.

---

## Phase 7 — Trilingual Localization (EN, AR, IT), User Registration, Biometric Auth & Network Checker
**Date:** 2026-09-18
**Branch:** `phase-6`

### Built
- **Trilingual Internationalization (`l10n`)**:
  - Standard Flutter localization system via `flutter_localizations`, `intl`, and `l10n.yaml`.
  - Full coverage across 3 languages: English (`en`), Egyptian Arabic (`ar` with full RTL layout support), and Italian (`it`).
  - Over 130 localized strings across all features: Auth, Onboarding, Splash, Home, Garage, Buses, Errand Cars, Driver Portal, and Admin Console.
  - `LocaleCubit` for dynamic runtime language switching and persistence across app launches.
  - Modern `LanguageSelectorButton` capsule pill displaying active country flag, locale code, and dropdown menu (`🇬🇧 EN ▾`, `🇪🇬 عربي ▾`, `🇮🇹 IT ▾`).
- **First-Time User Registration & Unregistered Rejection**:
  - `AuthCubit.registerAccount(...)`: Registers new employee, driver, or admin accounts with Full Name, Bank Staff ISL, Department, and Password.
  - Accounts persisted locally to `SharedPreferences` (`registered_accounts_json`).
  - `AuthCubit.loginWithIsl(...)`: Validates against registered accounts; rejects unregistered ISLs directing them to register first.
  - Interactive toggle on `AccessGatePage` between **Sign In** and **Register Account** modes.
- **Biometric Authentication (Face ID / Fingerprint)**:
  - `BiometricHelper`: Wrapper for `local_auth` 3.x (`isBiometricSupported()`, `authenticate()`, `getAvailableBiometrics()`).
  - `SecurePrefs`: Encrypted storage for biometric credentials and activation decisions via `flutter_secure_storage` 11.x.
  - `EnableBiometricBottomSheet`: Interactive post-login prompt to enable biometric login.
  - Quick biometric sign-in button on `AccessGatePage`.
  - Android & iOS native configurations: `FlutterFragmentActivity`, `USE_BIOMETRIC` permissions, and `NSFaceIDUsageDescription`.
- **Real-Time Network Connectivity Checker**:
  - `NetworkConnectivityService`: Background connectivity stream listener with active socket ping verification (`connectivity_plus` & `internet_connection_checker`).
  - `NoInternetScreen`: AlexBank-branded full-screen overlay with animated offline state and interactive "Try Again" re-ping.
  - Global overlay configured in `main.dart` `MaterialApp.router` `builder`.
- **Automated Testing & Code Quality**:
  - Expanded test suite: **93/93 tests passing** (including unit tests for registration, persistence, and unknown ISL rejection).
  - `flutter analyze`: **0 issues found**.

---

## Phase 8 — Firebase Sync, Push Notifications, UI/UX Polish & Release Merge
**Date:** 2026-09-18
**Branch:** `phase-6` & `main`

### Built
- **Cloud Firestore Real-Time Synchronization Layer**:
  - `FirestoreSyncService`: Singleton managing cloud document sync for user accounts, garage subscriptions, bus bookings, errand requests, and driver trips.
  - Resilient offline fallback: seamlessly handles missing Firebase credentials or network disconnects with encrypted local persistence (`SharedPreferences` & `FlutterSecureStorage`).
  - Wired live sync hooks into `AuthCubit`, `GarageCubit`, `BusCubit`, and `ErrandCarCubit`.
- **FCM Push Notifications & Foreground Banner Overlay**:
  - `PushNotificationService`: Firebase Cloud Messaging client with permission handling, FCM device token management, and foreground message stream.
  - `TransitNotificationBanner`: Floating animated in-app notification banner with auto-dismiss and swipe dismissal.
  - Demo notification dispatcher with interactive triggers (Bus Approaching, Errand Request Approved, Garage Subscription Renewed).
  - Bell action in `HomePage` AppBar with demo notification trigger popup menu.
- **UI/UX Polish & Motion Tokens**:
  - `AppShadow`: Subtle elevation, card, and floating modal shadows in `tokens.dart`.
  - `AppDuration`: Standardized micro-interaction, transition, and animation durations.
  - Haptic feedback and smooth module transitions.
- **Trilingual Notification Localization**:
  - Notification titles, bodies, and connection restored alerts localized across English (`en`), Egyptian Arabic (`ar`), and Italian (`it`).
- **Release Verification & Main Merge**:
  - Verified 0 linter issues via `flutter analyze`.
  - Verified all 93 unit and widget tests pass.
  - Clean merge of `phase-6` into `main` with changes pushed to `origin/main` and `origin/phase-6`.

