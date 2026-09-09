import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:app/constants.dart';

class FilterCategoriesNew extends StatefulWidget {
  final List<int>? selectedCategoryIds;

  const FilterCategoriesNew({Key? key, this.selectedCategoryIds})
      : super(key: key);

  @override
  _FilterCategoriesNewState createState() => _FilterCategoriesNewState();
}

class _FilterCategoriesNewState extends State<FilterCategoriesNew> {
  List<Map<String, dynamic>> categories = [];
  List<int> currentSelectedIds = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    if (widget.selectedCategoryIds != null) {
      currentSelectedIds = List.from(widget.selectedCategoryIds!);
    }
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/get-categories'),
        headers: {'Content-Type': 'application/json'},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          setState(() {
            categories =
                List<Map<String, dynamic>>.from(data['response']['data']);
            isLoading = false;
          });
        } else {
          setState(() {
            error = data['message'] ?? 'Failed to load categories';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          error = 'Failed to fetch categories: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = 'Error fetching categories: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  'Select Category',
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
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            )
          else if (error != null)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Text(error!, style: const TextStyle(color: Colors.red)),
            )
          else if (categories.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Text('No categories available'),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = currentSelectedIds.contains(category['id']);

                  return Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.purple.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Colors.purple
                            : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: CheckboxListTile(
                      title: Text(
                        category['name'],
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected
                              ? Colors.purple
                              : Colors.black87,
                        ),
                      ),
                      value: isSelected,
                      activeColor: Colors.purple,
                      checkboxShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: (bool? checked) {
                        setState(() {
                          if (checked == true) {
                            currentSelectedIds.add(category['id']);
                          } else {
                            currentSelectedIds.remove(category['id']);
                          }
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  List<String> selectedNames = [];
                  for (var cat in categories) {
                    if (currentSelectedIds.contains(cat['id'])) {
                      selectedNames.add(cat['name']);
                    }
                  }
                  Navigator.pop(context, {
                    'ids': currentSelectedIds.isEmpty ? null : currentSelectedIds,
                    'names': selectedNames.isEmpty ? null : selectedNames,
                  });
                },
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
