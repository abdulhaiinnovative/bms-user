# Bottom Navigation Tabs - Complete Migration Plan

## Date: November 19, 2025

---

## 📋 Overview

**Objective:** Move all 5 bottom navigation tab screens and their related files from `lib/screens/` to proper feature folders under `lib/features/`.

**Current Status:** Only HomeScreen and InitScreen have been migrated. 4 tabs remaining.

---

## 🎯 Tabs to Migrate

### Tab 1: Home ✅

- **Screen:** HomeScreen
- **Status:** ✅ ALREADY MIGRATED
- **Location:** `lib/features/home/presentation/screens/home_screen.dart`

### Tab 2: Search 🔄

- **Screen:** SearchServiceScreenNew
- **Current Location:** `lib/screens/search_final/`
- **Target Location:** `lib/features/search/presentation/screens/`
- **Related Files:** 9 files (entire search_final folder)
  - search_service_screen_new.dart (main screen)
  - search_provider_new.dart (provider)
  - search_salon_api.dart (API)
  - deal_card_new.dart (widget)
  - salon_card_new.dart (widget)
  - services_card_new.dart (widget)
  - services_header_new.dart (widget)
  - filter_categories_new.dart (API)
  - price_range_new.dart (widget)
  - sorting_new.dart (widget)

### Tab 3: Favourites 🔄

- **Screen:** FavouritesScreen
- **Current Location:** `lib/screens/favourites/`
- **Target Location:** `lib/features/favourites/presentation/screens/`
- **Related Files:** 1 file
  - favourites_screen.dart

### Tab 4: Bookings 🔄

- **Screen:** MyBookings
- **Current Location:** `lib/screens/history_bookings/`
- **Target Location:** `lib/features/bookings/presentation/screens/`
- **Related Files:** 2 files
  - my_bookings.dart (main screen)
  - booking_details_screen.dart (detail screen)

### Tab 5: Profile ✅

- **Screen:** ProfileScreen
- **Status:** ✅ ALREADY MIGRATED
- **Location:** `lib/features/profile/presentation/screens/profile_screen.dart`

---

## 📁 New Feature Folder Structure

```
lib/features/
├── search/
│   ├── data/
│   │   └── api/
│   │       ├── search_salon_api.dart
│   │       └── filter_categories_new.dart
│   ├── presentation/
│   │   ├── providers/
│   │   │   └── search_provider_new.dart
│   │   ├── screens/
│   │   │   └── search_service_screen_new.dart
│   │   └── widgets/
│   │       ├── deal_card_new.dart
│   │       ├── salon_card_new.dart
│   │       ├── services_card_new.dart
│   │       ├── services_header_new.dart
│   │       ├── price_range_new.dart
│   │       └── sorting_new.dart
│
├── favourites/
│   └── presentation/
│       └── screens/
│           └── favourites_screen.dart
│
└── bookings/
    └── presentation/
        └── screens/
            ├── my_bookings.dart
            └── booking_details_screen.dart
```

---

## 🔄 Migration Steps

### Phase 1: Create Feature Folder Structure

1. Create `lib/features/search/` with subfolders
2. Create `lib/features/favourites/` with subfolders
3. Create `lib/features/bookings/` with subfolders

### Phase 2: Migrate Search Feature (10 files)

1. Move search_service_screen_new.dart → `features/search/presentation/screens/`
2. Move search_provider_new.dart → `features/search/presentation/providers/`
3. Move search_salon_api.dart → `features/search/data/api/`
4. Move filter_categories_new.dart → `features/search/data/api/`
5. Move widgets (6 files) → `features/search/presentation/widgets/`
   - deal_card_new.dart
   - salon_card_new.dart
   - services_card_new.dart
   - services_header_new.dart
   - price_range_new.dart
   - sorting_new.dart
6. Update all imports in moved files
7. Find and update all imports referencing these files

### Phase 3: Migrate Favourites Feature (1 file)

1. Move favourites_screen.dart → `features/favourites/presentation/screens/`
2. Update imports in the file
3. Find and update all imports referencing this file

### Phase 4: Migrate Bookings Feature (2 files)

1. Move my_bookings.dart → `features/bookings/presentation/screens/`
2. Move booking_details_screen.dart → `features/bookings/presentation/screens/`
3. Update imports in moved files
4. Find and update all imports referencing these files

### Phase 5: Update InitScreen

1. Update import paths in init_screen.dart to use new feature locations

### Phase 6: Delete Old Folders

1. Delete `lib/screens/search_final/`
2. Delete `lib/screens/favourites/`
3. Delete `lib/screens/history_bookings/`

### Phase 7: Final Verification

1. Run `flutter analyze` on all migrated files
2. Verify zero compilation errors
3. Test app navigation to all tabs

---

## 📊 Impact Analysis

### Files to Create: ~15 new files (in new locations)

### Files to Delete: ~13 old files

### Files to Update: ~20+ files (import updates)

### Estimated Time: 2-3 hours

---

## ⚠️ Risk Assessment

**Low Risk:**

- Favourites (1 file, simple)
- Bookings (2 files, self-contained)

**Medium Risk:**

- Search (10 files with interdependencies)

**Mitigation:**

- Update imports systematically
- Test after each feature migration
- Keep documentation updated

---

## ✅ Success Criteria

Migration complete when:

1. [ ] All tab screens in proper feature folders
2. [ ] All related files moved with screens
3. [ ] All imports updated correctly
4. [ ] Old screen folders deleted
5. [ ] Zero compilation errors
6. [ ] All bottom navigation tabs work correctly

---

## 🚀 Ready to Execute

**Estimated Duration:** 2-3 hours  
**Complexity:** Medium  
**Dependencies:** None (init_screen already updated)

Awaiting approval to proceed with migration...
