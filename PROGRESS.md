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
- Phase 2: Employee Garage Parking Module (bay status, plate registration, QR check-in/out, cancellation request).

