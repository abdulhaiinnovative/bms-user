# Debugging Booking Detail Staff Information

## Issue

Staff information is not displaying in the booking detail screen.

## Diagnostic Steps

### 1. Fetch Real API Response

Run the diagnostic script to see the actual API response:

```bash
# From the project root directory
cd /home/isbah/ZyphramProjects/bms_user/bms_flutter

# Run the script (replace 123 with an actual booking ID from your app)
dart run scripts/fetch_booking_detail.dart 123

# If you need authentication, provide the token as second argument
dart run scripts/fetch_booking_detail.dart 123 "your_auth_token_here"
```

### 2. Get a Real Booking ID

To get a real booking ID from your app:

1. Open the app in debug mode
2. Go to "My Bookings" screen
3. Tap on any booking
4. Check the console logs for "BookingDetailsScreen.initState | bookingId=XXX"
5. Use that booking ID in the script above

### 3. Get Your Auth Token

You can get your auth token by:

**Option A: From the app logs**

1. Run the app in debug mode
2. Login to the app
3. Check console for API calls - the token should be in the request headers

**Option B: Add temporary logging**
Add this to `lib/services/protected_http_client.dart`:

```dart
import 'dart:developer' as developer;

// In the get/post methods, add:
developer.log('Auth Token: ${prefs.getString('token')}', name: 'auth');
```

### 4. Analyze the Response

The script will show you:

- ✓ Full JSON response structure
- ✓ Whether services have `staff` or `selected_professional` field
- ✓ The exact structure of the professional data
- ✓ Recommendations for model updates

### 5. Common Issues & Solutions

#### Issue: Field name mismatch

**Symptom:** API returns `staff` but model looks for `selected_professional`

**Solution:** Model already updated to check both fields:

```dart
selectedProfessional: json['staff'] != null
    ? ServiceProfessional.fromJson(json['staff'])
    : (json['selected_professional'] != null
        ? ServiceProfessional.fromJson(json['selected_professional'])
        : null),
```

#### Issue: Nested structure is different

**Symptom:** Staff data exists but isn't parsed correctly

**Solution:** Update the ServiceProfessional.fromJson to match actual structure:

```dart
factory ServiceProfessional.fromJson(Map<String, dynamic> json) {
  // Add logging to see what's being parsed
  print('Parsing professional: ${json.toString()}');

  return ServiceProfessional(
    id: json['id'] ?? 0,
    name: json['name'],
    // ... other fields
  );
}
```

#### Issue: API requires specific headers

**Symptom:** 401 or 403 errors

**Solution:** Make sure you're using the correct auth token

### 6. Update Models Based on Response

After running the script, update the models in:

- `lib/features/bookings/data/models/booking_detail_response.dart`
- `lib/models/MyBookingResponse.dart`

Match the field names and structure exactly as shown in the API response.

### 7. Test in App

After updating models:

1. Hot restart the app (not just hot reload)
2. Navigate to booking details
3. Check console for the debug log: "Service: XXX | Has staff: true/false"
4. The screen should now show either:
   - Professional card with blue background (if staff exists)
   - Red warning "No staff assigned" (if staff is null)

### 8. Remove Debug Code

Once staff is displaying correctly, you can:

1. Remove the "No staff assigned" fallback
2. Remove debug logging
3. Make the staff section conditional again with `if (service.selectedProfessional != null)`

## Quick Commands Reference

```bash
# Fetch booking detail for booking ID 123
dart run scripts/fetch_booking_detail.dart 123

# With auth token
dart run scripts/fetch_booking_detail.dart 123 "Bearer eyJ..."

# Make script executable (Linux/Mac)
chmod +x scripts/fetch_booking_detail.dart

# Then run directly
./scripts/fetch_booking_detail.dart 123
```
