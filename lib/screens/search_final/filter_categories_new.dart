import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:app/constants.dart';

class FilterCategoriesNew extends StatefulWidget {
  final int? selectedCategoryId;

  const FilterCategoriesNew({Key? key, this.selectedCategoryId})
      : super(key: key);

  @override
  _FilterCategoriesNewState createState() => _FilterCategoriesNewState();
}

class _FilterCategoriesNewState extends State<FilterCategoriesNew> {
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      log('FilterCategoriesNew: Fetching categories');

      final response = await http.get(
        Uri.parse('$BASE_URL/get-categories'),
        headers: {'Content-Type': 'application/json'},
      );

      // Check if widget is still mounted before calling setState
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          setState(() {
            categories =
                List<Map<String, dynamic>>.from(data['response']['data']);
            isLoading = false;
          });
          log('✅ FilterCategoriesNew: Loaded ${categories.length} categories');
        } else {
          setState(() {
            error = data['message'] ?? 'Failed to load categories';
            isLoading = false;
          });
          log('❌ FilterCategoriesNew: ${data['message']}');
        }
      } else {
        setState(() {
          error = 'Failed to fetch categories: ${response.statusCode}';
          isLoading = false;
        });
        log('❌ FilterCategoriesNew: Status code ${response.statusCode}');
      }
    } catch (e) {
      // Check if widget is still mounted before calling setState
      if (!mounted) return;

      log('❌ FilterCategoriesNew: Unexpected error - $e');
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
                  final isSelected =
                      category['id'] == widget.selectedCategoryId;

                  return Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFF4C5E).withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFFF4C5E)
                            : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        category['name'],
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected
                              ? const Color(0xFFFF4C5E)
                              : Colors.black87,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle,
                              color: Color(0xFFFF4C5E))
                          : null,
                      onTap: () {
                        Navigator.pop(context,
                            {'id': category['id'], 'name': category['name']});
                      },
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
