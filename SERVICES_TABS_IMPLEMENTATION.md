# Services Tabs Implementation

## Purpose

Use the `categories` array returned by `GET /api/salons/{id}` to build tab headers (id + name). On tab change, fetch services for the selected category from `GET /api/salons/{salonId}/services/{categoryId}`.

## Data available

Sample categories object (from `GET /api/salons/{id}`):

```json
"categories": [
  { "id": 1, "name": "Haircut", "description": null, "status": 1 },
  { "id": 2, "name": "Barbering", "description": null, "status": 1 },
  { "id": 4, "name": "Facials & Skincare", "description": null, "status": 1 },
  { "id": 5, "name": "Hair Removal", "description": null, "status": 1 },
  { "id": 10, "name": "Makeup", "description": null, "status": 1 }
]
```

## High-level approach

- Build `TabBar` headers using each category's `name` and attach the `id` as the category key.
- When the user switches tabs, call `GET /api/salons/{salonId}/services/{categoryId}` (e.g. `/api/salons/1/services/5`).
- Implement lightweight caching per category to avoid redundant requests when revisiting tabs.
- Allow pull-to-refresh per tab to re-fetch current category.
- Show loading and error states per tab.

## UI Behavior

- Tabs displayed horizontally with the category `name` as the label.
- Selected tab loads and shows that category's services list.
- If categories are empty, show a friendly empty state and hide TabBar.
- If a category is disabled (`status != 1`) skip it or render it disabled (UX choice).

## Data flow

1. App calls `GET /api/salons/{id}` to get salon details (includes `categories`).
2. Build tabs from `categories`. Default selected tab: first category or category with `is_default` (if provided).
3. On tab change, call `GET /api/salons/{salonId}/services/{categoryId}?per_page=10&page=1` and render results.
4. Cache the successful response keyed by `categoryId` and `salonId`.

## API request example

```
GET /api/salons/1/services/5?per_page=10&page=1
```

## Flutter pseudo-code (concise)

- Use a provider/ViewModel or `StatefulWidget` with `TabController`.
- Maintain: `List<Category> categories`, `Map<int, ServicesPage> cache`, `int salonId`.

Minimal illustrative snippet (not copy-paste ready):

```
// Build tabs from categories
final tabs = categories.map((c) => Tab(text: c.name)).toList();

TabBar(
  controller: tabController,
  tabs: tabs,
  onTap: (index) => viewModel.onCategorySelected(categories[index].id),
)

// In ViewModel
void onCategorySelected(int categoryId) async {
  if (cache.containsKey(categoryId)) {
    // use cached data
    emit(cache[categoryId]);
    return;
  }
  emit(LoadingState());
  final res = await api.get('/salons/$salonId/services/$categoryId?per_page=10&page=1');
  if (res.success) {
    cache[categoryId] = res.data; // cache
    emit(DataState(res.data));
  } else {
    emit(ErrorState(res.message));
  }
}

// Pull-to-refresh always re-fetches and updates cache
```

## Caching & UX notes

- Cache lifetime: session-based (in-memory). Optionally invalidate after X minutes.
- Show `refresh` control to force re-fetch per category.
- Avoid auto-fetching all categories at load — fetch only the initially selected category and subsequent ones on tab switch.

## Error handling

- If fetch fails, show an inline error with a retry button for that tab.
- If categories endpoint fails, show salon-level error and a retry for salon details.

## Accessibility

- Ensure tabs are accessible (semantic labels) and scrollable if categories exceed horizontal space.

## Acceptance criteria

- Tabs render using `id` and `name` from `categories` returned by `/api/salons/{id}`.
- On tab change, a request is made to `/api/salons/{salonId}/services/{categoryId}`.
- Responses are cached by `categoryId`; revisiting a tab uses cache unless user refreshes.
- Loading, empty, and error states are handled per tab.

---

Please review this document and approve or request changes. Once approved I can:

- Add a ready-to-drop Flutter implementation file/snippet (complete widget + state management),
- Or implement the changes in your codebase upon approval.
