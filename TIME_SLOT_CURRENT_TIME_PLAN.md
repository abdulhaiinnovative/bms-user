# Time Slot Generation - Current Time Implementation Plan

## Overview
Enhance the time slot generation to respect the current time when users select today's date.

## Current Behavior
- Time slots are generated from salon opening time to closing time
- Always starts from opening time regardless of current time
- No consideration for whether the selected date is today

## Required Behavior

### Scenario 1: Selected date is TODAY
**Case 1A: Current time is BEFORE salon opening**
- **Example**: Current time = 11:00 AM, Salon opens at 12:00 PM
- **Action**: Generate slots normally from 12:00 PM
- **Reason**: Salon hasn't opened yet, all slots from opening are available

**Case 1B: Current time is AFTER salon opening**
- **Example**: Current time = 3:00 PM, Salon opens at 12:00 PM, closes at 9:00 PM
- **Action**: Generate slots starting from next 15-minute interval after current time
- **Next slot calculation**: 3:00 PM → 3:15 PM (start slots from 3:15 PM)
- **Another example**: 3:07 PM → 3:15 PM, 3:22 PM → 3:30 PM

**Case 1C: Current time is AFTER salon closing**
- **Example**: Current time = 10:00 PM, Salon closes at 9:00 PM
- **Action**: Show no slots available (salon is closed)
- **UI**: Display "No time slots available for this date"

### Scenario 2: Selected date is FUTURE
- **Action**: Generate slots normally from opening to closing time
- **No changes needed**: Current implementation works fine

## Implementation Steps

### Step 1: Check if selected date is today
```dart
bool isToday = _isDateToday(date);
```

### Step 2: Get current time if today
```dart
if (isToday) {
  DateTime now = DateTime.now();
  // Extract current hour and minute
}
```

### Step 3: Calculate next available 15-minute slot
```dart
// Round up to next 15-minute interval
// Examples:
// 3:00 PM → 3:15 PM
// 3:07 PM → 3:15 PM  
// 3:15 PM → 3:30 PM
// 3:22 PM → 3:30 PM
```

### Step 4: Compare with salon opening time
```dart
// Use the LATER of:
// 1. Salon opening time
// 2. Next available slot after current time
```

### Step 5: Validate against closing time
```dart
// If adjusted start time >= closing time
// Return empty list (no slots available)
```

## Code Changes Required

### Location: `_generateTimeSlots` method (around line 750)

**New helper method needed:**
```dart
bool _isDateToday(DateTime date) {
  final now = DateTime.now();
  return date.year == now.year && 
         date.month == now.month && 
         date.day == now.day;
}

DateTime _getNextAvailableSlot(DateTime currentTime) {
  // Round up to next 15-minute interval
  int minutes = currentTime.minute;
  int roundedMinutes = ((minutes / 15).ceil()) * 15;
  
  if (roundedMinutes == 60) {
    return DateTime(
      currentTime.year,
      currentTime.month, 
      currentTime.day,
      currentTime.hour + 1,
      0,
    );
  }
  
  return DateTime(
    currentTime.year,
    currentTime.month,
    currentTime.day, 
    currentTime.hour,
    roundedMinutes,
  );
}
```

**Modified `_generateTimeSlots` logic:**
```dart
List<String> _generateTimeSlots(DateTime date) {
  // ... existing code to get opening/closing times ...
  
  // NEW: Check if selected date is today
  bool isToday = _isDateToday(date);
  
  if (isToday) {
    DateTime now = DateTime.now();
    DateTime nextSlot = _getNextAvailableSlot(now);
    
    // If next available slot is after opening time, use it
    DateTime proposedStart = DateTime(
      date.year, date.month, date.day, 
      startHour, startMinute
    );
    
    if (nextSlot.isAfter(proposedStart)) {
      startHour = nextSlot.hour;
      startMinute = nextSlot.minute;
    }
  }
  
  // ... continue with existing slot generation ...
}
```

## Logging Enhancement

Add logging to show the current time adjustment:

```dart
if (isToday) {
  log("🕐 Selected date is TODAY - adjusting for current time", 
      name: "Time Slots");
  log("  Current Time: ${DateFormat('h:mm a').format(now)}", 
      name: "Time Slots");
  log("  Next Available Slot: ${DateFormat('h:mm a').format(nextSlot)}", 
      name: "Time Slots");
  log("  Adjusted Start Time: $startHour:${startMinute.toString().padLeft(2, '0')}", 
      name: "Time Slots");
}
```

## Edge Cases to Handle

1. **Current time is very close to closing**
   - Example: 8:50 PM, closes at 9:00 PM
   - Should show slots: 8:50 PM → 9:00 PM only

2. **Current time equals a 15-minute mark**
   - Example: 3:15 PM exactly
   - Should start from 3:30 PM (next slot)

3. **After closing time**
   - Should return empty list
   - UI shows "No time slots available"

4. **Midnight closing time (00:00:00)**
   - Already handled in existing code
   - Converts to 23:45 PM as last slot

## Testing Scenarios

1. ✅ Select today, current time 11 AM, salon opens 12 PM → Slots from 12:00 PM
2. ✅ Select today, current time 3 PM, salon 12 PM - 9 PM → Slots from 3:15 PM
3. ✅ Select today, current time 3:07 PM → Slots from 3:15 PM
4. ✅ Select today, current time 8:50 PM, closes 9 PM → Only 8:50-9:00 PM slots
5. ✅ Select today, current time 10 PM, closes 9 PM → No slots
6. ✅ Select tomorrow → Normal slots from opening time
7. ✅ Select today, current time exactly 3:15 PM → Slots from 3:30 PM

## Expected User Experience

**Before:**
- User selects today at 3 PM
- Sees all slots from 12 PM (opening) including past times
- Can select a past time slot (confusing/invalid)

**After:**
- User selects today at 3 PM  
- Sees only future slots from 3:15 PM onwards
- Cannot select past time slots
- Clear indication that only future bookings are available

## Implementation Priority
🔴 **HIGH** - This is a critical user experience issue that could lead to invalid bookings

## Estimated Changes
- 1 new helper method: `_isDateToday()`
- 1 new helper method: `_getNextAvailableSlot()`
- Modify existing `_generateTimeSlots()` method (add ~15-20 lines)
- Add logging for current time adjustments
- Total: ~40-50 lines of new/modified code
