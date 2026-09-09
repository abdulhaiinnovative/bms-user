# Salon Detail APIs Documentation

This document describes the salon detail APIs that have been split into separate endpoints for better performance and flexibility.

## Overview

The salon detail has been broken down into 4 separate APIs:
1. **Salon Details** - High-level salon information
2. **Salon Services** - Categorized services with pagination
3. **Salon Staff** - Staff/team members with pagination
4. **Salon Deals** - Deals with pagination

---

## 1. Get Salon Details

Returns high-level salon information including images, active days, reviews, and location.

### Endpoint
```
GET /api/salons/{id}
```

### Parametersper_page
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | integer | Yes | Salon ID |

### Response
```json
{
    "success": true,
    "message": "Success!",
    "data": {
        "id": 1,
        "name": "Salon Name",
        "images": [
            "https://example.com/uploads/salon/image1.jpg",
            "https://example.com/uploads/salon/image2.jpg"
        ],
        "created_at": "12-12-2025",
        "gender": "unisex",
        "logo": "https://example.com/uploads/salon-logo/logo.jpg",
        "star": 4.5,
        "review_count": 25,
        "is_favourite": false,
        "about": "About the salon...",
        "policy": "Salon policy...",
        "facebook": "https://facebook.com/salon",
        "instagram": "https://instagram.com/salon",
        "twitter": "https://twitter.com/salon",
        "linkedin": "https://linkedin.com/salon",
        "city": "Lahore",
        "area": "Gulberg",
        "type": "Salon",
        "kind": "Premium",
        "active_days": [
            {
                "id": 1,
                "salon_id": 1,
                "day": "Monday",
                "open_time": "09:00:00",
                "close_time": "21:00:00",
                "status": 1
            }
        ],
        "location": {
            "address": "123 Main Street, Gulberg, Lahore",
            "lat": "31.5204",
            "long": "74.3587"
        },
        "reviews": [
            {
                "id": 1,
                "user_id": 1,
                "salon_id": 1,
                "rating": 5,
                "comment": "Great service!",
                "user": {
                    "id": 1,
                    "name": "John Doe",
                    "image": "https://example.com/uploads/user/avatar.jpg"
                }
            }
        ]
    }
}
```

---

## 2. Get Salon Services (Categorized)

Returns services for a specific category with pagination.

### Endpoint
```
GET /api/salons/{id}/services/{categoryId?}
```

### Parameters
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| id | integer | Yes | - | Salon ID |
| categoryId | integer | No | 1 | Category ID to filter services |
| per_page | integer | No | 10 | Number of items per page |

### Example Requests
```
GET /api/salons/1/services          # Returns services from category 1 (default)
GET /api/salons/1/services/5        # Returns services from category 5
GET /api/salons/1/services/3?per_page=20  # Returns 20 services from category 3
```

### Response
```json
{
    "success": true,
    "message": "Success!",
    "data": {
        "category_id": 1,
        "category_name": "Hair Services",
        "services": {
            "current_page": 1,
            "data": [
                {
                    "id": 1,
                    "salon_id": 1,
                    "name": "Men's Haircut",
                    "short_description": "Men's Haircut",
                    "duration": "30 minutes",
                    "description": "Basic men's haircut",
                    "price": 135,
                    "percentage_discount": 10,
                    "discount_amount": 15,
                    "discount_type": "percentage",
                    "price_discount": null,
                    "old_price": 150,
                    "category_id": 1,
                    "subcategory_id": 1,
                    "is_feature": 0,
                    "status": 1,
                    "extra_time": 0,
                    "gender": "male",
                    "salon": null,
                    "professionals": [
                         {
                            "id": 1,
                            "salon_id": 1,
                            "first_name": "Zaeem",
                            "last_name": "Altaf",
                            "name": "Zaeem Altaf",
                            "email": "zaeemaltaf144@gmail.com",
                            "phone": "+923363859828",
                            "image": "http://127.0.0.1:8000/uploads/team//1740125742.jpg",
                            "experience": "vendor",
                            "booking_accept": 5,
                            "monday": 0,
                            "tuesday": 0,
                            "wednesday": 1,
                            "thursday": 0,
                            "friday": 0,
                            "saturday": 1,
                            "sunday": 0,
                            "start_date": "2025-02-21",
                            "end_date": "2025-06-28",
                            "status": 1,
                            "note": null
                        },
                    ]
                }
            ],
            "first_page_url": "http://example.com/api/salons/1/services/1?page=1",
            "from": 1,
            "last_page": 3,
            "last_page_url": "http://example.com/api/salons/1/services/1?page=3",
            "links": [...],
            "next_page_url": "http://example.com/api/salons/1/services/1?page=2",
            "path": "http://example.com/api/salons/1/services/1",
            "per_page": 10,
            "prev_page_url": null,
            "to": 10,
            "total": 25
        }
    }
}
```

---

## 3. Get Salon Staff

Returns staff/team members for a salon with pagination.

### Endpoint
```
GET /api/salons/{id}/staff
```

### Parameters
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| id | integer | Yes | - | Salon ID |
| per_page | integer | No | 10 | Number of items per page |

### Example Requests
```
GET /api/salons/1/staff             # Returns 10 staff members (default)
GET /api/salons/1/staff?per_page=5  # Returns 5 staff members per page
```

### Response
```json
{
    "success": true,
    "message": "Success!",
    "data": {
        "current_page": 1,
        "data": [
            {
                "id": 1,
                "salon_id": 1,
                "first_name": "Zaeem",
                "last_name": "Altaf",
                "name": "Zaeem Altaf",
                "email": "zaeemaltaf144@gmail.com",
                "phone": "+923363859828",
                "image": "http://127.0.0.1:8000/uploads/team//1740125742.jpg",
                "experience": "vendor",
                "booking_accept": 5,
                "monday": 0,
                "tuesday": 0,
                "wednesday": 1,
                "thursday": 0,
                "friday": 0,
                "saturday": 1,
                "sunday": 0,
                "start_date": "2025-02-21",
                "end_date": "2025-06-28",
                "status": 1,
                "note": null
            },
        ],
        "first_page_url": "http://example.com/api/salons/1/staff?page=1",
        "from": 1,
        "last_page": 2,
        "last_page_url": "http://example.com/api/salons/1/staff?page=2",
        "links": [...],
        "next_page_url": "http://example.com/api/salons/1/staff?page=2",
        "path": "http://example.com/api/salons/1/staff",
        "per_page": 10,
        "prev_page_url": null,
        "to": 10,
        "total": 15
    }
}
```

---

## 4. Get Salon Deals

Returns deals for a salon with pagination.

### Endpoint
```
GET /api/salons/{id}/deals
```

### Parameters
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| id | integer | Yes | - | Salon ID |
| per_page | integer | No | 10 | Number of items per page |

### Example Requests
```
GET /api/salons/1/deals             # Returns 10 deals (default)
GET /api/salons/1/deals?per_page=5  # Returns 5 deals per page
```

### Response
```json
{
    "success": true,
    "message": "Success!",
    "data": {
        "current_page": 1,
        "data": [
            {
                "id": 1,
                "salon_id": 1,
                "name": "test",
                "image": "http://127.0.0.1:8000/uploads/deal//1756722481.png",
                "price": 1200,
                "discount_type": "percentage",
                "discount_value": 0,
                "total_price": 1200,
                "start_date": "2025-11-29",
                "end_date": "2026-01-31",
                "status": 1,
                "services": [
                    {
                        "id": 1,
                        "salon_id": 1,
                        "name": "Men's Haircut",
                        "short_description": "Men's Haircut",
                        "duration": "30 minutes",
                        "description": "Basic men's haircut",
                        "price": 135,
                        "percentage_discount": 10,
                        "discount_amount": 15,
                        "discount_type": "percentage",
                        "price_discount": null,
                        "old_price": 150,
                        "category_id": 1,
                        "subcategory_id": 1,
                        "is_feature": 0,
                        "status": 1,
                        "extra_time": 0,
                        "gender": "male",
                        "salon": null,
                    },
                    {
                        "id": 1,
                        "salon_id": 1,
                        "name": "Men's Haircut",
                        "short_description": "Men's Haircut",
                        "duration": "30 minutes",
                        "description": "Basic men's haircut",
                        "price": 135,
                        "percentage_discount": 10,
                        "discount_amount": 15,
                        "discount_type": "percentage",
                        "price_discount": null,
                        "old_price": 150,
                        "category_id": 1,
                        "subcategory_id": 1,
                        "is_feature": 0,
                        "status": 1,
                        "extra_time": 0,
                        "gender": "male",
                        "salon": null,
                    }
                ]
            }
        ],
        "first_page_url": "http://example.com/api/salons/1/deals?page=1",
        "from": 1,
        "last_page": 1,
        "last_page_url": "http://example.com/api/salons/1/deals?page=1",
        "links": [...],
        "next_page_url": null,
        "path": "http://example.com/api/salons/1/deals",
        "per_page": 10,
        "prev_page_url": null,
        "to": 3,
        "total": 3
    }
}
```

---

## Error Responses

### Salon Not Found
```json
{
    "success": false,
    "message": "Salon Not Found",
    "data": []
}
```

### Category Not Found (Services API)
```json
{
    "success": false,
    "message": "Category Not Found",
    "data": []
}
```

### Internal Server Error
```json
{
    "success": false,
    "message": "Internal Server Error",
    "data": ["Error message details"]
}
```

---

## Pagination Structure

All paginated responses include:

| Field | Description |
|-------|-------------|
| current_page | Current page number |
| data | Array of items for current page |
| first_page_url | URL for first page |
| from | Starting item number |
| last_page | Total number of pages |
| last_page_url | URL for last page |
| links | Array of pagination links |
| next_page_url | URL for next page (null if last page) |
| path | Base URL path |
| per_page | Items per page |
| prev_page_url | URL for previous page (null if first page) |
| to | Ending item number |
| total | Total number of items |

---

## Usage Example (Flutter/Dart)

```dart
// Get salon details
final salonDetails = await api.get('/salons/1');

// Get services for category 1 (default)
final services = await api.get('/salons/1/services');

// Get services for category 5 with pagination
final services = await api.get('/salons/1/services/5?per_page=10&page=2');

// Get staff
final staff = await api.get('/salons/1/staff?per_page=10');

// Get deals
final deals = await api.get('/salons/1/deals?per_page=10');
```

---

## Summary of Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/salons/{id}` | GET | Salon high-level details |
| `/api/salons/{id}/services/{categoryId?}` | GET | Categorized services (paginated) |
| `/api/salons/{id}/staff` | GET | Staff members (paginated) |
| `/api/salons/{id}/deals` | GET | Deals (paginated) |
