# Search API Documentation

## Overview

The Search API provides a unified endpoint to search across **salons**, **services**, and **deals** with advanced filtering, sorting, and pagination capabilities.

## Endpoint

```
POST /api/search
```

## Headers

| Header | Value | Required |
|--------|-------|----------|
| Content-Type | application/json | Yes |
| Accept | application/json | Yes |

---

## Request Parameters

### Search Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `keyword` | string | No | Search term to match against names, descriptions, types |
| `location` | string | No | Filter by city, country, area, state, or address |
| `area` | string | No | Filter by specific area/city/address |
| `type` | string | No | Salon type (e.g., "spa", "salon", "barbershop") |

### Filter Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `filter_type` | array | No | Types to search: `["salon", "service", "deal"]`. If empty, searches all |
| `categories` | array | No | Array of category IDs to filter by |
| `min_price` | number | No | Minimum price filter |
| `max_price` | number | No | Maximum price filter |
| `time_slot` | string | No | Available time slots: `morning`, `afternoon`, `evening`, `night` |
| `gender` | array | No | Gender filter: `["male", "female", "unisex"]` |

### Sorting & Pagination

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `sort_by` | string | No | `relevance` | Sort options: `relevance`, `rating`, `price_low`, `price_high`, `newest` |
| `per_page` | number | No | `12` | Results per page |

---

## Time Slot Ranges

| Slot | Time Range |
|------|------------|
| `morning` | 06:00 - 12:00 |
| `afternoon` | 12:00 - 17:00 |
| `evening` | 17:00 - 21:00 |
| `night` | 21:00 - 23:59 |

---

## Request Examples

### 1. Basic Keyword Search (All Types)

Search for "haircut" across all salons, services, and deals:

```json
{
    "keyword": "haircut"
}
```

### 2. Search Only Services

Search for services with keyword "massage":

```json
{
    "keyword": "massage",
    "filter_type": ["service"]
}
```

### 3. Search Only Salons

Search for salons by name or type:

```json
{
    "keyword": "spa",
    "filter_type": ["salon"]
}
```

### 4. Search Only Deals

Search for deals:

```json
{
    "keyword": "discount",
    "filter_type": ["deal"]
}
```

### 5. Search with Location Filter

Search for salons in a specific city:

```json
{
    "keyword": "salon",
    "location": "Dubai",
    "filter_type": ["salon"]
}
```

### 6. Search with Price Range

Search for services within a price range:

```json
{
    "keyword": "facial",
    "filter_type": ["service"],
    "min_price": 50,
    "max_price": 200
}
```

### 7. Search with Category Filter

Search for services in specific categories:

```json
{
    "keyword": "treatment",
    "filter_type": ["service"],
    "categories": [1, 2, 3]
}
```

### 8. Search with Gender Filter

Search for salons that serve specific genders:

```json
{
    "keyword": "salon",
    "filter_type": ["salon"],
    "gender": ["female", "unisex"]
}
```

### 9. Search with Time Slot Filter

Search for salons open during specific time slots:

```json
{
    "keyword": "spa",
    "filter_type": ["salon"],
    "time_slot": "evening"
}
```

### 10. Search with Sorting

Search and sort by rating:

```json
{
    "keyword": "massage",
    "filter_type": ["service"],
    "sort_by": "rating"
}
```

### 11. Full Advanced Search

Comprehensive search with all filters:

```json
{
    "keyword": "relaxation",
    "location": "Dubai",
    "area": "Marina",
    "type": "spa",
    "filter_type": ["salon", "service", "deal"],
    "categories": [1, 5, 8],
    "min_price": 100,
    "max_price": 500,
    "time_slot": "afternoon",
    "gender": ["female", "unisex"],
    "sort_by": "rating",
    "per_page": 20
}
```

### 12. Search Services and Deals Only

Search services and deals, excluding salons:

```json
{
    "keyword": "nail",
    "filter_type": ["service", "deal"],
    "min_price": 20,
    "max_price": 100
}
```

### 13. Browse All with Filters (No Keyword)

Get all services in a category sorted by price:

```json
{
    "filter_type": ["service"],
    "categories": [5],
    "sort_by": "price_low",
    "per_page": 24
}
```

---

## Response Structure

### Success Response (200)

```json
{
    "statusCode": 200,
    "response": {
        "data": {
            "total_results": 45,
            "filters_applied": {
                "keyword": "massage",
                "location": "Dubai",
                "area": null,
                "type": null,
                "filter_type": ["salon", "service", "deal"],
                "categories": [],
                "min_price": null,
                "max_price": null,
                "time_slot": null,
                "gender": [],
                "sort_by": "relevance"
            },
            "salons": {
                "current_page": 1,
                "data": [
                    {
                        "id": 1,
                        "name": "Relaxation Spa",
                        "logo": "https://...",
                        "images": ["https://..."],
                        "average_rating": 4.5,
                        "address": "123 Main St, Dubai",
                        "city": "Dubai",
                        "salon_for": "unisex",
                        "type": "spa",
                        "is_favourite": false
                    }
                ],
                "total": 15,
                "per_page": 12,
                "last_page": 2
            },
            "salons_count": 15,
            "services": {
                "current_page": 1,
                "data": [
                    {
                        "id": 10,
                        "name": "Deep Tissue Massage",
                        "price": 150,
                        "duration": 60,
                        "image": "https://...",
                        "salon": {
                            "id": 1,
                            "name": "Relaxation Spa",
                            "logo": "https://..."
                        }
                    }
                ],
                "total": 20,
                "per_page": 12,
                "last_page": 2
            },
            "services_count": 20,
            "deals": {
                "current_page": 1,
                "data": [
                    {
                        "id": 5,
                        "name": "Spa Day Package",
                        "price": 299,
                        "image": "https://...",
                        "salon": {
                            "id": 1,
                            "name": "Relaxation Spa"
                        },
                        "services": [...]
                    }
                ],
                "total": 10,
                "per_page": 12,
                "last_page": 1
            },
            "deals_count": 10
        }
    },
    "message": "Search results retrieved successfully!",
    "status": true,
    "errors": []
}
```

### Multiple Types Response (No Pagination)

When searching multiple types (`filter_type` has 2+ values), results are returned as arrays instead of paginated objects:

```json
{
    "statusCode": 200,
    "response": {
        "data": {
            "total_results": 36,
            "filters_applied": {...},
            "salons": [
                {"id": 1, "name": "Salon A", ...},
                {"id": 2, "name": "Salon B", ...}
            ],
            "salons_count": 12,
            "services": [
                {"id": 10, "name": "Service A", ...},
                {"id": 11, "name": "Service B", ...}
            ],
            "services_count": 12,
            "deals": [
                {"id": 5, "name": "Deal A", ...}
            ],
            "deals_count": 12
        }
    },
    "message": "Search results retrieved successfully!",
    "status": true,
    "errors": []
}
```

### Validation Error Response (422)

```json
{
    "statusCode": 422,
    "response": {
        "data": []
    },
    "message": "At least one search parameter is required.",
    "status": false,
    "errors": []
}
```

### Error Response (500)

```json
{
    "statusCode": 500,
    "response": {
        "data": []
    },
    "message": "Internal Error!",
    "status": false,
    "errors": ["Error message details"]
}
```

---

## Search Behavior

### 1. Keyword Matching

The search normalizes keywords by:
- Converting to lowercase
- Removing special characters
- Removing trailing 's' (plurals)
- Removing spaces for fuzzy matching

This means searching for "Massages" will match "massage", "Massage", "MASSAGE", etc.

### 2. Multi-Field Search

**Salons** are searched in:
- Name
- Type
- About
- Kind
- Service names (within the salon)

**Services** are searched in:
- Name
- Short description
- Description
- Salon name, type, kind

**Deals** are searched in:
- Deal name
- Service names within the deal
- Salon name, type, kind

### 3. Fallback Logic

If searching for services/deals returns no results but matching salons exist:
- The API will return services/deals from those matching salons
- This ensures users always get relevant results

### 4. Relevance Ordering

Results are ordered by relevance:
1. Exact name matches first
2. Description matches second
3. Salon-based matches last

---

## Flutter Integration Example

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class SearchService {
  final String baseUrl = 'https://your-api.com/api';

  Future<SearchResponse> search({
    String? keyword,
    String? location,
    String? area,
    String? type,
    List<String>? filterType,
    List<int>? categories,
    double? minPrice,
    double? maxPrice,
    String? timeSlot,
    List<String>? gender,
    String sortBy = 'relevance',
    int perPage = 12,
  }) async {
    final Map<String, dynamic> body = {};

    if (keyword != null) body['keyword'] = keyword;
    if (location != null) body['location'] = location;
    if (area != null) body['area'] = area;
    if (type != null) body['type'] = type;
    if (filterType != null) body['filter_type'] = filterType;
    if (categories != null) body['categories'] = categories;
    if (minPrice != null) body['min_price'] = minPrice;
    if (maxPrice != null) body['max_price'] = maxPrice;
    if (timeSlot != null) body['time_slot'] = timeSlot;
    if (gender != null) body['gender'] = gender;
    body['sort_by'] = sortBy;
    body['per_page'] = perPage;

    final response = await http.post(
      Uri.parse('$baseUrl/search'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return SearchResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Search failed: ${response.body}');
    }
  }
}

// Usage examples:

// Basic keyword search
await searchService.search(keyword: 'massage');

// Services only with price filter
await searchService.search(
  keyword: 'facial',
  filterType: ['service'],
  minPrice: 50,
  maxPrice: 200,
);

// Salons with location and gender filter
await searchService.search(
  keyword: 'spa',
  filterType: ['salon'],
  location: 'Dubai',
  gender: ['female', 'unisex'],
);

// Full advanced search
await searchService.search(
  keyword: 'relaxation',
  location: 'Dubai',
  filterType: ['salon', 'service', 'deal'],
  categories: [1, 5],
  minPrice: 100,
  maxPrice: 500,
  timeSlot: 'afternoon',
  sortBy: 'rating',
  perPage: 20,
);
```

---

## Notes

1. **At least one search parameter is required** - The API will return a validation error if no parameters are provided.

2. **Pagination behavior**:
   - When searching a single type (e.g., only services), results are paginated
   - When searching multiple types, results are limited to `per_page` items per type (no pagination)

3. **Sort options**:
   - `relevance` - Default, based on search term matching
   - `rating` - Highest rated first
   - `price_low` - Lowest price first
   - `price_high` - Highest price first
   - `newest` - Most recently created first

4. **Gender values**: `male`, `female`, `unisex` (matches salon's `salon_for` field)

5. **Category IDs**: Get available categories from the `/api/get-categories` endpoint.
