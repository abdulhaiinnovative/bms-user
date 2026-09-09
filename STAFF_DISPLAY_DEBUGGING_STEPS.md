# 🔍 Staff Display Debugging - Complete Guide

## Overview

This guide will help you identify why staff information isn't displaying in the booking detail screen. We've added comprehensive debug logging to automatically show you the auth token, booking ID, and staff data structure.

---

## 📱 Step 1: Run the App and Open a Booking

1. **Start your Flutter app**:

   ```bash
   flutter run
   ```

2. **Navigate to a booking detail screen**:
   - Go to "My Bookings" tab
   - Tap on any booking to open the detail screen

3. **Watch the console output** - You'll see debug info like this:

   ```
   ╔═══════════════════════════════════════════════════════════════╗
   ║ 🔍 DEBUG INFO FOR DIAGNOSTIC SCRIPT                           ║
   ╠═══════════════════════════════════════════════════════════════╣
   ║ Booking ID: 123
   ║ Auth Token: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   ╠═══════════════════════════════════════════════════════════════╣
   ║ Run this command to fetch API data:                          ║
   ║ dart run scripts/fetch_booking_detail.dart 123 eyJhbGc...    ║
   ╚═══════════════════════════════════════════════════════════════╝

   ╔═══════════════════════════════════════════════════════════════╗
   ║ 📋 SERVICES & STAFF DATA RECEIVED                             ║
   ╠═══════════════════════════════════════════════════════════════╣
   ║ Service 1: Haircut
   ║   Has staff: true
   ║   Staff name: John Doe
   ║   Staff ID: 45
   ║
   ║ Service 2: Hair Coloring
   ║   Has staff: false
   ║   ⚠️  WARNING: Staff is NULL for this service!
   ║
   ╚═══════════════════════════════════════════════════════════════╝
   ```

---

## 🔬 Step 2: Analyze the Console Output

### Case A: Staff Data Shows in Console ✅

**Example Output:**

```
║ Service 1: Haircut
║   Has staff: true
║   Staff name: John Doe
```

**What this means:**

- ✅ API is returning staff data correctly
- ✅ Model is parsing it correctly
- ❌ UI might not be displaying it (check screen code)

**Next Steps:**

- Check if staff card is visible in the app UI
- If not visible, there's a UI rendering issue
- Look for conditional rendering that might be hiding it

---

### Case B: Staff is NULL ⚠️

**Example Output:**

```
║ Service 1: Haircut
║   Has staff: false
║   ⚠️  WARNING: Staff is NULL for this service!
```

**What this means:**

- ❌ Staff data is not being parsed from API response
- Need to check actual API response structure

**Next Steps:**

- Run the diagnostic script (Step 3)
- Verify the exact field name in API response
- Update model if needed

---

## 🛠️ Step 3: Run Diagnostic Script (If Staff is NULL)

1. **Copy the command from console output** (it's automatically generated for you)

2. **Run it in terminal**:

   ```bash
   dart run scripts/fetch_booking_detail.dart <BOOKING_ID> <AUTH_TOKEN>
   ```

   Example:

   ```bash
   dart run scripts/fetch_booking_detail.dart 123 eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   ```

3. **Review the script output** - Look for the services array:
   ```json
   {
     "services": [
       {
         "id": 1,
         "name": "Haircut",
         "staff": {                    ← Check if this field exists
           "id": 45,
           "name": "John Doe",
           "image": "...",
           "phone": "1234567890"
         }
       }
     ]
   }
   ```

---

## 📊 Step 4: Identify the Issue

### Common Scenarios:

#### Scenario 1: Field name is different

**API returns:** `"selected_professional"` instead of `"staff"`
**Solution:** Model already handles both - check nesting level

#### Scenario 2: Field is nested differently

**API returns:**

```json
{
  "professional": {
    "data": {
      "id": 45,
      "name": "John"
    }
  }
}
```

**Solution:** Update model parsing in `booking_detail_response.dart`

#### Scenario 3: Field name uses different case

**API returns:** `"Staff"` (capital S) or `"STAFF"` (all caps)
**Solution:** Update model to check all variations

#### Scenario 4: Data exists but is empty array/null

**API returns:** `"staff": null` or `"staff": []`
**Solution:** This is expected - booking has no staff assigned

---

## 🔧 Step 5: Fix the Model (If Needed)

If the diagnostic script shows a different structure, update the model:

**File:** `lib/features/bookings/data/models/booking_detail_response.dart`

**Current parsing:**

```dart
selectedProfessional: json['staff'] != null
    ? ServiceProfessional.fromJson(json['staff'])
    : (json['selected_professional'] != null
        ? ServiceProfessional.fromJson(json['selected_professional'])
        : null),
```

**If field is nested differently, update to match API:**

```dart
// Example: If API returns professional.data
selectedProfessional: json['professional']?['data'] != null
    ? ServiceProfessional.fromJson(json['professional']['data'])
    : null,
```

---

## 🧪 Step 6: Test the Fix

1. **Hot restart the app**:

   ```bash
   # Press 'R' in terminal or
   flutter run
   ```

2. **Open a booking detail again**

3. **Check console output** - Should now show:

   ```
   ║ Service 1: Haircut
   ║   Has staff: true  ← Should be true now
   ║   Staff name: John Doe
   ```

4. **Verify UI displays staff card** with green background

---

## 🎯 Expected Final Result

### In Console:

```
╔═══════════════════════════════════════════════════════════════╗
║ 📋 SERVICES & STAFF DATA RECEIVED                             ║
╠═══════════════════════════════════════════════════════════════╣
║ Service 1: Haircut
║   Has staff: true
║   Staff name: John Doe
║   Staff ID: 45
║
║ Service 2: Hair Coloring
║   Has staff: true
║   Staff name: Jane Smith
║   Staff ID: 67
║
╚═══════════════════════════════════════════════════════════════╝
```

### In App UI:

- Each service shows a **green/blue staff card**
- Staff name is displayed
- Staff image (if available)
- No red warning cards

---

## 📝 Remove Debug Logging (When Fixed)

Once everything works, remove debug logging:

**File:** `lib/features/bookings/presentation/screens/booking_details_screen.dart`

Remove these sections:

1. The auth token/booking ID debug print (lines ~51-60)
2. The services/staff data debug print (lines ~73-96)

**Keep only:**

```dart
if (kDebugMode) {
  developer.log(
      'BookingDetailsScreen._fetchBookingDetail success | bookingId=${widget.bookingId}',
      name: 'booking.screen');
}
```

---

## 🆘 Troubleshooting

### Issue: No debug output in console

**Solution:** Make sure you're running in debug mode (`flutter run`, not `flutter run --release`)

### Issue: Auth token not found

**Solution:** Make sure user is logged in. Log out and log in again if needed.

### Issue: Script shows 401 Unauthorized

**Solution:** Token might be expired. Log out and log in to get fresh token.

### Issue: All services show "Has staff: false"

**Possible causes:**

1. Bookings don't have staff assigned yet (check in backend/admin panel)
2. API field name is different (run diagnostic script to verify)
3. Model parsing is incorrect (update based on diagnostic script output)

---

## 📞 Quick Reference

### Files to Check:

- **Model:** `lib/features/bookings/data/models/booking_detail_response.dart`
- **Screen:** `lib/features/bookings/presentation/screens/booking_details_screen.dart`
- **Diagnostic Script:** `scripts/fetch_booking_detail.dart`

### Key Commands:

```bash
# Run app
flutter run

# Run diagnostic script
dart run scripts/fetch_booking_detail.dart <booking_id> <auth_token>

# Hot restart
# Press 'R' in terminal
```

---

## ✅ Checklist

- [ ] Run app and open booking detail
- [ ] Copy auth token and booking ID from console
- [ ] Check if staff data shows in console
- [ ] If staff is NULL, run diagnostic script
- [ ] Review API response structure
- [ ] Update model if needed
- [ ] Hot restart and verify
- [ ] Confirm staff cards show in UI
- [ ] Remove debug logging when done

---

**Last Updated:** January 21, 2026
**Status:** Debug logging active - ready for testing
