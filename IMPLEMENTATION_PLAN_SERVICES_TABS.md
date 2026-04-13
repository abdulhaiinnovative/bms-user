# Implementation Plan — Services Tabs (Use `categories` from `/api/salons/{id}`)

## Goal

Replace the current bulk-category discovery with a predictable, API-driven flow:

- Use `categories` returned by `GET /api/salons/{id}` to build tab headers (use `id` and `name`).
- On tab change, fetch `GET /api/salons/{salonId}/services/{categoryId}` for that category only.
- Add per-category caching and pull-to-refresh.

## Analysis (what I found)

- Main screen: `lib/screens/test/salon_details_scrolling_tabs_effect_b.dart`
  - Currently fetches categories by brute-force loop calling `fetchSalonServices(salonId, categoryId)` for categoryId 1..20 in `_fetchServicesStaffDeals`.
  - Builds `_serviceCategoryTabController` from `categorizedServices.length` after that loop.
  - `_buildServiceCategoryTabs()` builds tabs from `categorizedServices.keys` and `categoryNames` maps.
- API client: `lib/api_services/salon_detail_api.dart`
  - Provides `fetchSalonDetailData(salonId)` which currently logs and parses salon details.
  - Provides `fetchSalonServices(salonId, categoryId)` which returns a `ServiceCategoryResponse`.
- Model: `lib/models/SalonDetailApiResponse.dart`
  - `SalonData` currently does NOT parse a `categories` array from salon detail JSON.

Conclusion: The app already supports fetching services per category but the screen discovers categories by trying IDs 1..20. To meet your request we must parse `categories` from salon details and change the screen to build tabs from that list and fetch per tab on demand.

## Files to change (minimal)

- `lib/models/SalonDetailApiResponse.dart`
  - Add a `Category` model and include `List<Category>? categories` in `SalonData` parsed from `json['categories']`.
- `lib/screens/test/salon_details_scrolling_tabs_effect_b.dart`
  - Remove the brute-force category loop in `_fetchServicesStaffDeals`.
  - Initialize `_serviceCategoryTabController` based on `salonDetailsss?.categories?.length ?? 0`.
  - Add a listener to `_serviceCategoryTabController` to trigger fetch on tab change.
  - Implement `Future<void> _fetchServicesForCategory(int categoryId)` that calls `SalonDetailAPI.fetchSalonServices(...)`, updates `categorizedServices` cache and `categoryNames` map and shows loading / error states scoped to the category.
  - On first load, fetch services for the default tab (index 0) only.
  - Update `_buildServiceCategoryTabs()` to build tabs from `salonDetailsss!.categories` order and show cached counts or loading indicators.

Optional (recommended)

- Add a small helper in `SalonDetailAPI` to fetch services with pagination parameters (already exists: `fetchSalonServices`).
- Consider moving caching to a small in-memory store (map keyed by `categoryId`) inside the screen's state or a ViewModel.

## Detailed change summary (pseudo-diff / snippets)

- Add Category model (in `SalonDetailApiResponse.dart`):

  - class Category { final int id; final String name; final String? description; final int? status; }
  - Parse `categories: json['categories'] != null ? (json['categories'] as List).map((c)=>Category.fromJson(c)).toList() : null`

- Replace loop in `_fetchServicesStaffDeals` with:

  1. Read `final cats = salonDetailsss?.categories ?? []`.
  2. Initialize `_serviceCategoryTabController = TabController(length: cats.length, vsync: this);`.
  3. Add `_serviceCategoryTabController!.addListener(() { if (_serviceCategoryTabController!.indexIsChanging == false) _onCategoryTabChanged(_serviceCategoryTabController!.index); });`
  4. Implement `_onCategoryTabChanged(index)` -> obtains `categoryId = cats[index].id` and calls `_fetchServicesForCategory(categoryId)` if not cached.
  5. On initial load call `_fetchServicesForCategory(cats.first.id)`.

- Implement `_fetchServicesForCategory(int categoryId)`:

  - set per-category loading flag (e.g., `Map<int,bool> isCategoryLoading`)
  - call `await SalonDetailAPI().fetchSalonServices(salonId, categoryId: categoryId)`
  - on success: `categorizedServices[categoryId] = response.services; categoryNames[categoryId] = response.categoryName;` and clear loading flag
  - on error: set per-category error state and clear loading

- Update `_buildServiceCategoryTabs()` to use `salonDetailsss!.categories` for tab labels; for the badge count show `categorizedServices[cat.id]?.length ?? (isCategoryLoading[cat.id] ? '...' : 0)`.

## UI/UX notes

- Tabs should be scrollable when categories overflow.
- Default selected tab: first category in the `categories` array.
- Caching: in-memory for the session. Add `RefreshIndicator` inside each `TabBarView` child to force re-fetch.
- Loading & error states must be per-tab to avoid blocking the entire screen.

## Acceptance Criteria (what I'll deliver)

- Tabs are generated from `categories` from `GET /api/salons/{id}` (uses `id` and `name`).
- Switching tabs triggers a single `GET /api/salons/{salonId}/services/{categoryId}` call for that category.
- Responses are cached per category; revisiting a tab shows cached results unless user pulls-to-refresh.
- Loading and error states are shown inline for the active category.
- No brute-force category discovery loop remains.

## Risks & Rollback

- If the `categories` field is missing from the API response for some salons, fallback to the current behavior or show an empty-state message and optionally revert to trying the default category `1`.
- Rollback: keep the current code branch (no destructive changes) until you approve; I will implement feature in a single focused commit.

## Next steps (what I will do after your approval)

1. Implement the model change in `lib/models/SalonDetailApiResponse.dart`.
2. Implement tab-change fetching, caching, and per-tab loading in `lib/screens/test/salon_details_scrolling_tabs_effect_b.dart`.
3. Run quick manual verification (hot reload / emulator) instructions and provide testing steps.
4. Commit changes and present diffs for review.

---

Please review this plan and confirm if you want me to proceed with the implementation changes described above. If you approve, I will apply the edits and run a quick verification locally.
