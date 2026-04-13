# Scrolling Tabs Implementation Plan

## Overview

Implement a scrolling tabs effect where:

- Services tab loads different categories incrementally (1, 2, 3, etc.)
- Users can scroll through different service categories
- Deals and Staff tabs remain as single-page tabs
- API calls use the separated endpoint structure

## Architecture

### Tab Structure

1. **Services Tab** (Scrollable Categories)

   - Shows services from multiple categories
   - Each scroll loads next category
   - Categories: 1, 2, 3, 4, 5... (incremental)
   - API: `/api/salons/{salonId}/services/{categoryId}`

2. **Deals Tab** (Single Page)

   - Shows all deals
   - API: `/api/salons/{salonId}/deals`

3. **Staff Tab** (Single Page)

   - Shows all staff members
   - API: `/api/salons/{salonId}/staff`

4. **About Tab** (Single Page)
   - Shows salon info and reviews

### Services Category Loading Strategy

#### Initial Load

- Load category 1 by default
- Display category name and services

#### On Scroll

- Detect when user scrolls to bottom of current category
- Increment categoryId (currentCategory + 1)
- Fetch next category services
- Append to services list
- Handle "Category Not Found" error to stop loading

#### State Management

```dart
int currentServiceCategory = 1;
bool isLoadingMoreCategories = false;
bool hasMoreCategories = true;
Map<int, List<Service>> categorizedServices = {}; // categoryId -> services
Map<int, String> categoryNames = {}; // categoryId -> name
```

### API Call Flow

#### 1. Initial Screen Load

```
GET /api/salons/{salonId}
  → Get salon details, images, reviews, location, about

GET /api/salons/{salonId}/services/1
  → Get first category services
  → Store category name and services

GET /api/salons/{salonId}/staff
  → Get all staff members

GET /api/salons/{salonId}/deals
  → Get all deals
```

#### 2. Services Category Scroll

```
User scrolls to bottom of category 1
  → currentServiceCategory = 2

GET /api/salons/{salonId}/services/2
  → Success: Add category 2 services
  → Error "Category Not Found": hasMoreCategories = false

User continues scrolling
  → currentServiceCategory = 3

GET /api/salons/{salonId}/services/3
  → Repeat until no more categories
```

### UI Components

#### Services Section Structure

```
Services Tab Content:
  - Category 1 Header (e.g., "Hair Services")
    - Service 1
    - Service 2
    - Service 3

  - Category 2 Header (e.g., "Spa Services")
    - Service 1
    - Service 2

  - Category 3 Header (e.g., "Nail Services")
    - Service 1
    - Service 2

  - Loading Indicator (when fetching next category)

  - End Message (when no more categories)
```

#### Scroll Detection

- Use `ScrollController` on Services section
- Detect when scroll position reaches 80% of max scroll
- Trigger next category load
- Prevent duplicate loads with `isLoadingMoreCategories` flag

### Error Handling

1. **Salon Not Found**

   - Show error screen
   - Allow retry

2. **Category Not Found**

   - Normal behavior - no more categories
   - Show "All categories loaded" message

3. **Network Error**
   - Show retry button
   - Keep existing data visible

### Implementation Steps

1. **Update State Variables**

   - Add category tracking variables
   - Add scroll controller for services

2. **Update API Calls**

   - Modify `fetchSalonServices` to accept categoryId
   - Add `fetchNextServiceCategory` method

3. **Update Services UI**

   - Group services by category
   - Add category headers
   - Add scroll listener
   - Add loading indicators

4. **Add Pagination Logic**

   - Detect scroll position
   - Load next category
   - Handle errors gracefully

5. **Update Section Builder**
   - Services section renders all categories
   - Add scroll controller
   - Show loading state at bottom

### Key Differences from Current Implementation

**Current:**

- Single call to services API with categoryId = 1
- Static service list

**New:**

- Multiple calls to services API (categoryId = 1, 2, 3, ...)
- Dynamic service list with categories
- Infinite scroll loading
- Category grouping in UI

### Benefits

1. **Better Performance**

   - Load categories on demand
   - Reduce initial load time

2. **Better UX**

   - Users can browse all categories
   - Smooth infinite scroll
   - Clear category separation

3. **Scalability**
   - Works with any number of categories
   - No hardcoding of category IDs

## Code Structure

```dart
// State variables
Map<int, List<Service>> categorizedServices = {};
Map<int, String> categoryNames = {};
int currentServiceCategory = 1;
bool isLoadingMoreCategories = false;
bool hasMoreCategories = true;
ScrollController servicesScrollController = ScrollController();

// Load next category
Future<void> _loadNextServiceCategory(String salonId) async {
  if (isLoadingMoreCategories || !hasMoreCategories) return;

  setState(() => isLoadingMoreCategories = true);

  try {
    final response = await SalonDetailAPI.fetchSalonServices(
      salonId,
      categoryId: currentServiceCategory,
    );

    // Store category data
    categorizedServices[currentServiceCategory] = response.services;
    categoryNames[currentServiceCategory] = response.categoryName;

    // Increment for next load
    currentServiceCategory++;

  } catch (e) {
    if (e.toString().contains('Category Not Found')) {
      hasMoreCategories = false;
    }
  } finally {
    setState(() => isLoadingMoreCategories = false);
  }
}

// Scroll listener
void _setupServicesScrollListener() {
  servicesScrollController.addListener(() {
    if (servicesScrollController.position.pixels >=
        servicesScrollController.position.maxScrollExtent * 0.8) {
      _loadNextServiceCategory(salonId);
    }
  });
}
```

## Expected API Response Format

### Services with Category

```json
{
  "success": true,
  "message": "Success!",
  "data": {
    "category_id": 1,
    "category_name": "Hair Services",
    "services": {
      "data": [...]
    }
  }
}
```

This structure allows us to:

- Know which category we're viewing
- Display category name as header
- Group services logically
- Load next category seamlessly
