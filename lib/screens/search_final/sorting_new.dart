import 'package:flutter/material.dart';

class SortingNew extends StatelessWidget {
  final int tabIndex;
  final String? currentSortBy;
  final String? currentSortOrder;

  const SortingNew({
    Key? key,
    required this.tabIndex,
    this.currentSortBy,
    this.currentSortOrder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define sorting options for each tab (Services, Deals, Salons)
    final List<Map<String, dynamic>> sortingOptions = tabIndex == 0
        ? [
            {
              'label': 'Name (A to Z)',
              'sortBy': 'name',
              'sortOrder': 'asc',
              'icon': Icons.sort_by_alpha
            },
            {
              'label': 'Name (Z to A)',
              'sortBy': 'name',
              'sortOrder': 'desc',
              'icon': Icons.sort_by_alpha
            },
            {
              'label': 'Price (High to Low)',
              'sortBy': 'price',
              'sortOrder': 'desc',
              'icon': Icons.trending_down
            },
            {
              'label': 'Price (Low to High)',
              'sortBy': 'price',
              'sortOrder': 'asc',
              'icon': Icons.trending_up
            },
          ]
        : tabIndex == 1
            ? [
                {
                  'label': 'Name (A to Z)',
                  'sortBy': 'name',
                  'sortOrder': 'asc',
                  'icon': Icons.sort_by_alpha
                },
                {
                  'label': 'Name (Z to A)',
                  'sortBy': 'name',
                  'sortOrder': 'desc',
                  'icon': Icons.sort_by_alpha
                },
                {
                  'label': 'Price (High to Low)',
                  'sortBy': 'total_price',
                  'sortOrder': 'desc',
                  'icon': Icons.trending_down
                },
                {
                  'label': 'Price (Low to High)',
                  'sortBy': 'total_price',
                  'sortOrder': 'asc',
                  'icon': Icons.trending_up
                },
              ]
            : [
                {
                  'label': 'Name (A to Z)',
                  'sortBy': 'name',
                  'sortOrder': 'asc',
                  'icon': Icons.sort_by_alpha
                },
                {
                  'label': 'Name (Z to A)',
                  'sortBy': 'name',
                  'sortOrder': 'desc',
                  'icon': Icons.sort_by_alpha
                },
              ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sort By',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ...sortingOptions.map((option) {
            final isSelected = option['sortBy'] == currentSortBy &&
                option['sortOrder'] == currentSortOrder;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFF4C5E).withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      isSelected ? const Color(0xFFFF4C5E) : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: ListTile(
                leading: Icon(
                  option['icon'],
                  color:
                      isSelected ? const Color(0xFFFF4C5E) : Colors.grey[600],
                ),
                title: Text(
                  option['label'],
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color:
                        isSelected ? const Color(0xFFFF4C5E) : Colors.black87,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: Color(0xFFFF4C5E))
                    : null,
                onTap: () {
                  Navigator.pop(context, {
                    'sortBy': option['sortBy'],
                    'sortOrder': option['sortOrder'],
                  });
                },
              ),
            );
          }).toList(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
