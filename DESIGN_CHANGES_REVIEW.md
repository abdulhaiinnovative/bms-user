# Design Changes Review: Salon Details Screen

## Overview

This document outlines the design changes that will be applied to `salon_details_scrolling_tabs_effect_b.dart` based on the provided reference design.

## Color Scheme Changes

### From Reference Design → Your App

- **Primary Green** `Color(0xFF2D4636)` → **App Purple** `kPrimaryColor`
- **Primary Dark Green** (gradient) → **App Purple Dark** `kPrimaryDarkColor`
- **Background Beige** `Color(0xFFF5F2F0)` → **Keep or use** `whiteColor`/`lightBackgroundColor`

---

## 1. SliverAppBar Header Design

### Current Implementation

- Basic header with salon images in PageView
- Simple glassmorphism back button
- Info section at bottom with rating badges

### New Design (from reference)

```dart
✅ Changes to Apply:
- expandedHeight: 450 (consistent)
- Pinned: true
- Large salon name typography with ultra-bold style:
  * fontSize: 48
  * fontWeight: w900
  * height: 0.9
  * letterSpacing: -2
  * Multi-line name support (e.g., "SALON\nNAME")

- Gradient overlay on image:
  * Top: black.withOpacity(0.3)
  * Middle: transparent
  * Bottom: black.withOpacity(0.7)

- Rating badge with glassmorphism effect:
  * Background: white24
  * Border: white30
  * Contains star icon + rating number
  * Tagline text below (e.g., "Luxury Beauty & Wellness")

- App bar actions remain same (favorite, share icons)
- Icon colors: white when expanded, black/purple when collapsed
```

**Preserve from Current:**

- Multiple images with PageView and SmoothPageIndicator
- Cart icon in top-right
- Favorite toggle functionality
- Salon-specific data binding

---

## 2. About/Salon Info Section

### Current Implementation

- Multiple information cards (location, hours, contact)
- Section-based layout from API

### New Design (from reference)

```dart
✅ Changes to Apply:
- Simplified single-block design
- Title (headline style):
  * "Dedicated to Creativity, Culture & Growth."
  * fontSize: 22
  * fontWeight: w600
  * color: Dark gray (0xFF2D3436) or use textPrimaryColor

- Description paragraph:
  * fontSize: 16
  * height: 1.6 (line spacing)
  * color: black.withOpacity(0.7)
  * Multi-line support

- Clean padding: EdgeInsets.all(24.0)
```

**Preserve from Current:**

- API data binding for salon.about
- Dynamic content based on API response
- Fallback text if about is empty

---

## 3. Sticky Tabs Design

### Current Implementation

- Tab bar with dynamic sections (services, deals, staff, about)
- Auto-scroll functionality

### New Design (from reference)

```dart
✅ Changes to Apply:
- Fixed tabs: ['Services', 'Staff', 'About', 'Reviews']
- SliverPersistentHeader with proper geometry:
  * minExtent: 50.0
  * maxExtent: 50.0
  * Wrapped in SizedBox(height: maxExtent) to fix layout

- TabBar styling:
  * isScrollable: true
  * indicatorColor: kPrimaryColor (was green)
  * labelColor: kPrimaryColor (was green)
  * unselectedLabelColor: Colors.black45
  * labelStyle: fontWeight.bold, fontSize: 16
  * backgroundColor: Keep app background color

- Pinned behavior for sticky effect
```

**Preserve from Current:**

- Dynamic tab visibility based on content availability
- Tab controller integration
- Auto-scroll to section on tab tap

---

## 4. Services Section

### Current Implementation (PRESERVE THIS)

- Category-based tabs
- Service cards with gradient buttons
- Add to cart functionality
- Loading states per category
- Retry on error

### What to Keep

```dart
✅ NO CHANGES to Services UI
- Keep all service card designs
- Keep category TabBarView
- Keep add to cart buttons with gradient
- Keep price display format
- Keep loading/error states
- Keep service item layout
```

**Note:** Only update the section header style to match new design

---

## 5. Team/Staff Section

### Current Implementation

- Staff list with images and info
- Basic card layout

### New Design (from reference)

```dart
✅ Changes to Apply:
- GridView with 2 columns
- Grid configuration:
  * crossAxisCount: 2
  * mainAxisSpacing: 16
  * crossAxisSpacing: 16
  * childAspectRatio: 0.8

- Staff card design:
  * Rounded corners: BorderRadius.circular(20)
  * Full image background with DecorationImage
  * Gradient overlay (top transparent → bottom black80%)
  * Text at bottom with padding
  * Name: white, bold
  * Role: white70, fontSize 12

- Section header style (consistent across all sections):
  * fontSize: 28
  * fontWeight: w800
  * letterSpacing: -0.5
  * padding: EdgeInsets.symmetric(vertical: 20)
```

**Preserve from Current:**

- API data binding for staff list
- Dynamic staff count
- Staff images from API
- Navigation/interaction if any

---

## 6. Contact/CTA Section

### Current Implementation

- May have booking buttons or contact info

### New Design (from reference)

```dart
✅ Changes to Apply:
- Container with dark background (use kPrimaryColor or deep variant)
- Rounded corners: BorderRadius.circular(24)
- Padding: EdgeInsets.all(24)

- Title:
  * "Ask us anything."
  * color: white
  * fontSize: 24
  * fontWeight: bold

- Description:
  * "Ready to experience our services? Let's start planning your next look."
  * color: white70

- CTA Button:
  * "GET IN TOUCH"
  * backgroundColor: white
  * foregroundColor: kPrimaryColor
  * RoundedRectangleBorder(30)
  * padding: horizontal 24, vertical 12
  * minimumSize: Size(0, 48)
  * tapTargetSize: shrinkWrap
```

**Preserve from Current:**

- Actual booking flow integration
- Cart bottom bar
- Navigation logic

---

## 7. Section Headers

### New Consistent Style

```dart
Widget _buildSectionHeader(String title) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
    ),
  );
}
```

Apply to: "Our Services", "Meet the Team", "About", etc.

---

## 8. Bottom Navigation Bar

### Current Implementation

- Cart bottom bar with total and checkout

### New Design (from reference)

```dart
✅ Changes to Apply:
- Container with white background
- BoxShadow: black.withOpacity(0.05), blur 10, offset(0, -5)
- Padding: horizontal 20, vertical 15

- Left side (service count & total):
  * "X Services Selected" - fontSize 12, black54
  * Price - fontSize 20, bold

- Right side button:
  * "BOOK NOW"
  * backgroundColor: kPrimaryColor (was green)
  * foregroundColor: white
  * padding: horizontal 32, vertical 16
  * RoundedRectangleBorder(12)
  * minimumSize: Size(0, 48)
  * tapTargetSize: shrinkWrap
```

**Preserve from Current:**

- Dynamic cart count and total from CartProvider
- Actual booking flow navigation
- Cart modal integration

---

## Implementation Notes

### Critical Points

1. **Preserve all API integrations** - don't break data fetching
2. **Keep services UI exactly as is** - only update section header
3. **Maintain cart functionality** - critical user flow
4. **Color palette consistency** - replace all green with purple variants
5. **Fix SliverGeometry** - ensure SizedBox wraps delegate child

### Testing Checklist After Implementation

- [ ] App bar collapses correctly on scroll
- [ ] Tabs stick to top when scrolling
- [ ] Services load and display properly
- [ ] Add to cart works
- [ ] Staff grid displays correctly
- [ ] About section shows API data
- [ ] Bottom bar updates with cart changes
- [ ] No layout overflow errors
- [ ] All purple colors are consistent

---

## Files to Modify

- ✅ `/lib/screens/test/salon_details_scrolling_tabs_effect_b.dart` (main file)

## Expected Impact

- **Visual:** Modern, premium salon detail screen with cleaner typography
- **UX:** Maintained - all existing flows preserved
- **Performance:** No impact - same widget structure
- **Code:** ~300 lines modified, 0 breaking changes

---

## Approval Required

Please review the above changes and confirm:

1. ✅ Color scheme (green → purple) is acceptable
2. ✅ Header design with large typography is approved
3. ✅ Staff grid layout (2 columns) is acceptable
4. ✅ Simplified about section design is approved
5. ✅ Services UI preservation is confirmed
6. ✅ Bottom bar design is approved

**Reply with "APPROVED" to proceed with implementation, or request specific modifications.**
