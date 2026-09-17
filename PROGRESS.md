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
- Firebase init will fail without config files — app runs fine regardless
- No real logic in any Cubit yet
- `core/widgets/` is empty — shared widgets built in Phase 1

### Key Decisions
- Package name kept as `alex_transportation` (avoids native config churn)
- Display name is "Transit" (in MaterialApp title, branding)
- go_router for routing, dio for HTTP, Inter font via google_fonts
- Freezed union states pattern with `safeEmit` — non-negotiable across all Cubits
- One admin Cubit+States per tab (5 pairs) so tab actions don't block each other

### Open for Next Phase
- Need `google-services.json` + `GoogleService-Info.plist` for Firebase
- Phase 1: design system shared widgets, splash screen, onboarding, invite-code gate
