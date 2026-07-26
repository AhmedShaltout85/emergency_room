# Plan: Build `system_admin_screen.dart` as a Top-Tabbed Dashboard

## Overview
Transform `system_admin_screen.dart` (currently empty) into the main dashboard for مركز الطوارئ, hosting 4 tabs with Arabic labels, using `Material TabBar` and `LayoutBuilder` for responsiveness. Strip redundant `AppBar`s from the child screens and reuse the existing `DashboardChartsList` for the labs tab.

**Tab labels (Arabic):**

| Tab | Arabic Name | Icon | Screen |
|---|---|---|---|
| 0 | الخريطة | `Icons.map` | `MapScreen` |
| 1 | لوحة SCADA | `Icons.analytics` | `ScadaDashboardScreen` |
| 2 | تقارير المعامل | `Icons.science` | `LabsReportsDashboardScreen` → `DashboardChartsList` |
| 3 | تقارير الشكاوى | `Icons.report` | `ComplaintsReportsScreen` |

---

## Phase 1 — Preparation & Discovery
- Verified all 4 target files exist; confirmed `system_admin_screen.dart` and `labs_reports_dashboard_screen.dart` are empty
- Confirmed `DashboardChartsList` (`lib/labs/view/dashboard_charts_list.dart`) is fully built and depends on `StaticVariables.labCode` & `StaticVariables.labName`
- Verified `go_router.dart` currently routes `/system-admin` to `system_admin_screen_old.dart` (will need update)
- Reviewed app theme: primary `Colors.indigo`, font `Cairo` — will be matched in the new shell
- Confirmed `MapScreen` constructor requires `latitude, longitude, address, technicianName` — will need default placeholders

## Phase 2 — Refactor Child Screens (remove individual `AppBar`s)
- **map_screen.dart**
  - Remove `appBar:` and `bottomNavigationBar:` from the `Scaffold`
  - Keep all `Stack` body content (info card, FABs, loading overlay) intact
- **scada_dashboard_screen.dart**
  - Remove the `appBar:` property
  - Keep the body (FutureBuilder + charts) unchanged
- **complaints_reports_screen.dart**
  - Remove the `appBar:` property
  - Keep the data table body intact
- **labs_reports_dashboard_screen.dart** (empty file)
  - Convert to a thin `StatelessWidget` returning `DashboardChartsList()`

## Phase 3 — Build a Reusable Responsive Helper
- Create `lib/utils/responsive_helper.dart` with a `ResponsiveHelper` class:
  - `isMobile(context)` — width < 600
  - `isTablet(context)` — 600 ≤ width < 1024
  - `isDesktop(context)` — width ≥ 1024
  - `horizontalPadding(context)`, `tabBarFontSize(context)`, `tabBarHeight(context)`
- The new shell uses `LayoutBuilder` to select the appropriate `TabBar` variant (scrollable on mobile, fixed on desktop)

## Phase 4 — Build `system_admin_screen.dart` (the shell)
Implement as a `StatefulWidget` with `TickerProviderStateMixin`:

```
Scaffold
├── appBar: AppBar (global header with title 'مركز الطوارئ - إدارة النظام')
│   └── bottom: PreferredSize
│       └── LayoutBuilder → TabBar (pills with icon + Arabic label)
└── body: TabBarView
    ├── tab 0 → MapScreen(latitude, longitude, address, technicianName)
    ├── tab 1 → ScadaDashboardScreen()
    ├── tab 2 → LabsReportsDashboardScreen()
    └── tab 3 → ComplaintsReportsScreen()
```

- `AppBar`: `Colors.indigo` background, white title using `Cairo`, elevation 4
- Tabs: icon + Arabic label, selected = white pill with indigo text; unselected = transparent with white text
- Tabs indicator: transparent container pills
- `TabBarView` preserves state across tab switches via `AutomaticKeepAliveClientMixin`
- On `>1024px` width, tabs spread evenly

## Phase 5 — Wire Up Routing
- Update `lib/utils/go_router.dart`:
  - Change import from `system_admin_screen_old.dart` to `screens/center_emergency/system_admin_screen.dart`
  - Update `/system-admin` route builder to use the new `SystemAdminScreen` class

## Phase 6 — Quality & Polish
- Add `AutomaticKeepAliveClientMixin` to each tab child so map animations / scada charts / data tables don't reset
- Preserve all timers and HTTP calls in `MapScreen`
- Verify `ResponsiveHelper` works on web
- Wrap children in a light `indigo.shade50` background for visual continuity

## Phase 7 — Verification
- Run `flutter pub get` (no new packages required)
- Run `flutter analyze` — expect 0 errors
- Manual checks: mobile (375px), tablet (768px), desktop (1280px+)
- Tab switch test: `MapScreen` timers don't duplicate, `ScadaDashboardScreen` doesn't refetch
- Optional: `flutter run -d chrome` to confirm web compatibility
