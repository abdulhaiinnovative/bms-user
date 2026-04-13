# Service Detail Dialog Guide

## Overview
This guide explains how to display service details in a dialog popup through a button click in Flutter.

## Implementation Methods

### Method 1: Simple Dialog with Service Details

```dart
void showServiceDetailDialog(BuildContext context, Service service) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(service.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (service.image != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    service.image!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                'Description',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(service.description ?? 'No description available'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Price', style: TextStyle(color: Colors.grey)),
                      Text(
                        '\$${service.price}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: kPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Duration', style: TextStyle(color: Colors.grey)),
                      Text(
                        '${service.duration} min',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Handle booking or selection action
            },
            child: const Text('Select Service'),
          ),
        ],
      );
    },
  );
}
```

### Method 2: Custom Dialog with Better Styling

```dart
void showServiceDetailDialog(BuildContext context, Service service) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with close button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        service.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (service.image != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            service.image!,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      const SizedBox(height: 20),
                      // Price and Duration Cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              icon: Icons.attach_money,
                              label: 'Price',
                              value: '\$${service.price}',
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoCard(
                              icon: Icons.access_time,
                              label: 'Duration',
                              value: '${service.duration} min',
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Description',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: kTextColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        service.description ?? 'No description available',
                        style: TextStyle(
                          fontSize: 14,
                          color: kSecondaryColor,
                          height: 1.5,
                        ),
                      ),
                      if (service.category != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Category',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: kTextColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Chip(
                          label: Text(service.category!),
                          backgroundColor: kPrimaryColor.withOpacity(0.1),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // Bottom Action Button
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Handle selection
                    },
                    child: const Text(
                      'Select This Service',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// Helper widget for info cards
Widget _buildInfoCard({
  required IconData icon,
  required String label,
  required String value,
  required Color color,
}) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    ),
  );
}
```

### Method 3: Bottom Sheet Instead of Dialog

```dart
void showServiceDetailBottomSheet(BuildContext context, Service service) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            // Service details content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Same content as dialog
                    // ... service details here
                  ],
                ),
              ),
            ),
            // Bottom button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Handle selection
                  },
                  child: const Text('Select Service'),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
```

## Usage in Your App

### In a Service List/Card Widget

```dart
// In your service card/tile
GestureDetector(
  onTap: () => showServiceDetailDialog(context, service),
  child: ServiceCard(service: service),
)

// Or with an info button
IconButton(
  icon: Icon(Icons.info_outline),
  onPressed: () => showServiceDetailDialog(context, service),
)

// Or with a dedicated button
OutlinedButton.icon(
  icon: Icon(Icons.visibility),
  label: Text('View Details'),
  onPressed: () => showServiceDetailDialog(context, service),
)
```

### Example Service Card with Detail Button

```dart
class ServiceCard extends StatelessWidget {
  final Service service;

  const ServiceCard({Key? key, required this.service}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Service image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                service.image ?? '',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            // Service info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${service.price} • ${service.duration} min',
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // Detail button
            IconButton(
              icon: Icon(Icons.info_outline, color: kPrimaryColor),
              onPressed: () => showServiceDetailDialog(context, service),
              tooltip: 'View Details',
            ),
          ],
        ),
      ),
    );
  }
}
```

## Best Practices

1. **Loading Images**: Add error handling and loading placeholders for service images
2. **Responsiveness**: Use `MediaQuery` to ensure dialog fits on different screen sizes
3. **Accessibility**: Add semantic labels and ensure text is readable
4. **Animation**: Consider adding custom animations for dialog entrance/exit
5. **State Management**: Pass callbacks to handle service selection from dialog

## Additional Features

### Add Image Gallery
If service has multiple images:
```dart
PageView.builder(
  height: 200,
  itemCount: service.images.length,
  itemBuilder: (context, index) {
    return Image.network(service.images[index]);
  },
)
```

### Add Reviews/Ratings
```dart
Row(
  children: [
    Icon(Icons.star, color: Colors.amber),
    Text('${service.rating} (${service.reviewCount} reviews)'),
  ],
)
```

### Add Favorite Button
```dart
IconButton(
  icon: Icon(
    service.isFavorite ? Icons.favorite : Icons.favorite_border,
    color: Colors.red,
  ),
  onPressed: () {
    // Toggle favorite
  },
)
```
