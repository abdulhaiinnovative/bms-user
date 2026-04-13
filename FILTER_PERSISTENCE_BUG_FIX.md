# Filter Persistence Bug Fix

## Problem Description

### Issue 1: Gender Filter Not Working Correctly Across Tabs

**Scenario:**

1. User applies gender filter (e.g., "Female") on any tab
2. Switches to Services tab
3. **Bug:** Services of both Male and Female are shown, despite the female filter indicator being displayed
4. **Expected:** Only female services should be displayed

**Root Cause:**

- When tab changes, `_tabListener` triggers `_performSearch()`
- The search is initiated BEFORE the tab change completes
- This causes a race condition where filters are read while the tab index is still changing
- The filter application logic in `_performSearch()` doesn't properly wait for tab change completion

### Issue 2: Similar Issues with Other Filters

**Price Filter:**

- Price filter should only apply to Services (tab 0) and Deals (tab 1)
- When switching from Services/Deals to Salons tab, price filter chip may still show
- Price filter might not properly clear or be ignored on Salons tab

**Sort Filter:**

- Sort options vary by tab type (e.g., price sorting for services/deals, rating for salons)
- Current sort selection might not be appropriate when switching tabs

**Category Filter:**

- Category filter applies to all tabs but results might not refresh properly
- Cached results from one tab might leak into another tab

## Technical Analysis

### Current Flow (Buggy)

```
1. User switches tab
2. TabController.indexIsChanging = true
3. _tabListener() called
4. setState() triggers rebuild
5. _performSearch() called immediately
6. Tab index might still be changing
7. Wrong filter logic executed
8. Results don't match active filters
```

### Issues in Code

**File:** `services_header_new.dart`

```dart
void _tabListener() {
  if (!widget.tabController.indexIsChanging && mounted) {
    setState(() {});

    // BUG: Search might execute before setState completes
    final searchProvider = Provider.of<SearchProviderNew>(context, listen: false);
    if (searchProvider.hasSearched) {
      _performSearch();  // <-- Race condition here
    }
  }
}
```

**File:** `_performSearch()` method

- Doesn't validate that filters are appropriate for current tab
- Doesn't wait for UI state to settle before executing search
- Filter parameters passed to search methods may be stale

## Solution

### Fix 1: Ensure Tab Change Completes Before Searching

- Add a post-frame callback to ensure tab change and setState complete
- Only then trigger search with filters

### Fix 2: Validate Filters Per Tab

- Before searching, validate which filters apply to current tab
- Automatically ignore incompatible filters rather than passing them

### Fix 3: Clear Incompatible Filter Indicators

- When switching tabs, hide filter chips that don't apply to the new tab
- Keep the filter values in state for when user switches back

### Fix 4: Debounce Tab Changes

- Prevent multiple rapid searches when user quickly switches tabs
- Only search after tab change settles

## Implementation Plan

### Changes to `services_header_new.dart`

1. **Update `_tabListener()`:**
   - Use `WidgetsBinding.instance.addPostFrameCallback()` to delay search
   - Ensure UI has settled before triggering search

2. **Update `_performSearch()`:**
   - Add validation to only pass filters applicable to current tab
   - Add null checks for filter values

3. **Update `_getFilterChips()`:**
   - Already correctly shows chips per tab
   - No changes needed (working as intended)

### Expected Behavior After Fix

**Gender Filter:**

- ✅ Apply on Services tab → Shows filtered services
- ✅ Switch to Deals tab → Gender filter chip hidden, deals shown without gender filter
- ✅ Switch to Salons tab → Gender filter chip visible, salons filtered by gender
- ✅ Switch back to Services → Gender filter chip visible, services properly filtered

**Price Filter:**

- ✅ Apply on Services tab → Shows filtered services
- ✅ Switch to Deals tab → Price filter chip visible, deals filtered by price
- ✅ Switch to Salons tab → Price filter chip hidden, salons shown without price filter
- ✅ Switch back to Services → Price filter chip visible, services properly filtered

**Sort Filter:**

- ✅ Apply on any tab → Results sorted appropriately
- ✅ Switch tabs → Sort persists and applies to new tab's results

**Category Filter:**

- ✅ Apply on any tab → Results filtered by category
- ✅ Switch tabs → Category filter persists across all tabs

## Testing Checklist

- [ ] Apply gender filter on Services tab, verify only filtered services show
- [ ] Switch to Deals tab, verify gender filter doesn't affect deals
- [ ] Switch to Salons tab, verify gender filter applies correctly
- [ ] Switch back to Services tab, verify filter still works
- [ ] Apply price filter on Services, switch to Salons, verify price ignored
- [ ] Apply price filter on Deals, switch to Services, verify price applies
- [ ] Apply category filter, switch all tabs, verify filter works on all
- [ ] Apply sort, switch all tabs, verify results sorted appropriately
- [ ] Rapidly switch tabs, verify no crashes or duplicate searches
- [ ] Clear filters on one tab, switch tabs, verify cleared state persists

## Files Modified

1. `lib/features/search/presentation/widgets/services_header_new.dart`
   - `_tabListener()` method
   - `_performSearch()` method
