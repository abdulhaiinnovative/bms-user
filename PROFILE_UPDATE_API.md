# Profile Update API Documentation

## Overview
This API endpoint allows authenticated users to update their profile information. The endpoint dynamically validates required fields based on the user's current profile completeness.

---

## API Endpoint

**URL:** `/api/user/profile-update`  
**Method:** `PUT`  
**Authentication:** Required (Bearer Token)  
**Middleware:** `auth:api`, `checkTokenExpiry`, `throttle:customer_browse`

---

## Request Headers

```json
{
  "Authorization": "Bearer {access_token}",
  "Content-Type": "multipart/form-data",
  "Accept": "application/json"
}
```

---

## Request Payload

### Required Fields

The following fields are **required** if they are currently empty, null, or set to '-' in the user's profile:

| Field | Type | Description |
|-------|------|-------------|
| `first_name` | string | User's first name |
| `last_name` | string | User's last name |
| `phone` | string | User's phone number |
| `email` | string | User's email address |

### Optional Fields

| Field | Type | Description |
|-------|------|-------------|
| `dob` | string/date | Date of birth (format: YYYY-MM-DD) |
| `gender` | string | User's gender |
| `country` | string | Country name |
| `state` | string | State/province name |
| `city` | string | City name |
| `address` | string | Full address |
| `image` | file | Profile image (jpeg, png, jpg, gif) - max 10MB |

---

## Example Request

### cURL Example

```bash
curl -X PUT \
  https://your-domain.com/api/user/profile-update \
  -H 'Authorization: Bearer your_access_token_here' \
  -H 'Content-Type: multipart/form-data' \
  -F 'first_name=John' \
  -F 'last_name=Doe' \
  -F 'phone=+1234567890' \
  -F 'email=john.doe@example.com' \
  -F 'dob=1990-01-15' \
  -F 'gender=male' \
  -F 'country=United States' \
  -F 'state=California' \
  -F 'city=Los Angeles' \
  -F 'address=123 Main Street' \
  -F 'image=@/path/to/profile-image.jpg'
```

### JSON Payload (without image)

```json
{
  "first_name": "John",
  "last_name": "Doe",
  "phone": "+1234567890",
  "email": "john.doe@example.com",
  "dob": "1990-01-15",
  "gender": "male",
  "country": "United States",
  "state": "California",
  "city": "Los Angeles",
  "address": "123 Main Street"
}
```

### Multipart Form Data (with image)

```
first_name: John
last_name: Doe
phone: +1234567890
email: john.doe@example.com
dob: 1990-01-15
gender: male
country: United States
state: California
city: Los Angeles
address: 123 Main Street
image: [binary file data]
```

---

## Response Format

### Success Response (200 OK)

```json
{
  "status": true,
  "message": "Profile updated successfully!",
  "data": {
    "id": 1,
    "first_name": "John",
    "last_name": "Doe",
    "email": "john.doe@example.com",
    "phone": "+1234567890",
    "dob": "1990-01-15",
    "gender": "male",
    "country": "United States",
    "state": "California",
    "city": "Los Angeles",
    "address": "123 Main Street",
    "image": "https://your-domain.com/storage/profile/image_name.jpg",
    "complete_status": 100,
    "created_at": "2026-01-10T12:00:00.000000Z",
    "updated_at": "2026-01-14T15:30:00.000000Z"
  }
}
```

### Validation Error Response (422 Unprocessable Entity)

```json
{
  "status": false,
  "message": "The first_name field is required.",
  "data": []
}
```

### Authentication Error Response (401 Unauthorized)

```json
{
  "status": false,
  "message": "Unauthenticated.",
  "data": []
}
```

### User Not Found Response (404 Not Found)

```json
{
  "status": false,
  "message": "Resource not found.",
  "data": []
}
```

### Server Error Response (500 Internal Server Error)

```json
{
  "status": false,
  "message": "Internal server error: {error_message}",
  "data": []
}
```

---

## Business Logic

### Dynamic Validation
The API implements **dynamic validation** based on the user's current profile state:

1. **If a field is empty, null, or contains '-'**, it becomes **required**
2. **If a field already has valid data**, it becomes **optional**

This ensures that users complete their profile progressively without forcing them to provide all information at once.

### Profile Completion Status
- After a successful update, the `complete_status` is set to **100%**
- This indicates the user has provided all essential profile information

### Image Upload
- Supported formats: JPEG, PNG, JPG, GIF
- Maximum file size: 10 MB (10048 KB)
- Images are stored in the `/storage/profile/` directory
- If no new image is provided, the existing image is retained

---

## Usage Examples

### Example 1: First-time Profile Completion

**Scenario:** User registered via social login and needs to complete profile

**Request:**
```json
{
  "first_name": "Jane",
  "last_name": "Smith",
  "phone": "+9876543210",
  "email": "jane.smith@example.com"
}
```

**Response:**
```json
{
  "status": true,
  "message": "Profile updated successfully!",
  "data": {
    "id": 2,
    "first_name": "Jane",
    "last_name": "Smith",
    "email": "jane.smith@example.com",
    "phone": "+9876543210",
    "complete_status": 100,
    ...
  }
}
```

### Example 2: Updating Additional Information

**Scenario:** User wants to add address and profile picture

**Request (Multipart):**
```
dob: 1995-06-20
gender: female
country: Canada
state: Ontario
city: Toronto
address: 456 Queen Street
image: [profile_photo.jpg]
```

**Response:**
```json
{
  "status": true,
  "message": "Profile updated successfully!",
  "data": {
    "id": 2,
    "first_name": "Jane",
    "last_name": "Smith",
    "dob": "1995-06-20",
    "gender": "female",
    "country": "Canada",
    "state": "Ontario",
    "city": "Toronto",
    "address": "456 Queen Street",
    "image": "https://your-domain.com/storage/profile/1642089123_profile_photo.jpg",
    "complete_status": 100,
    ...
  }
}
```

---

## Error Handling

### Common Validation Errors

| Error Message | Cause | Solution |
|--------------|-------|----------|
| "The first_name field is required." | Missing required field | Provide the first_name in request |
| "The email field is required." | Missing required field | Provide the email in request |
| "The image must be an image." | Invalid file type | Upload valid image file |
| "The image may not be greater than 10048 kilobytes." | File too large | Compress or use smaller image |

---

## Notes

- All required fields are dynamically determined based on the user's current profile state
- The endpoint uses the authenticated user's token to identify which profile to update
- Image uploads are handled via `uploadImage()` helper function
- The endpoint is protected by rate limiting (`throttle:customer_browse`)
- Token expiry is checked via `checkTokenExpiry` middleware

---

## Testing Checklist

- [ ] Test with all required fields provided
- [ ] Test with missing required fields (should return validation error)
- [ ] Test with optional fields only
- [ ] Test with image upload
- [ ] Test with invalid image format
- [ ] Test with oversized image
- [ ] Test without authentication token
- [ ] Test with expired token
- [ ] Test profile completion status updates to 100

---

## Related Endpoints

- **GET** `/api/user/get-user-profile` - Retrieve current user profile
- **POST** `/api/user/delete-account` - Delete user account
- **POST** `/api/auth/login` - User authentication

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-01-14 | Initial documentation |

---

## Support

For API support or questions, please contact the development team or refer to the main API documentation.
