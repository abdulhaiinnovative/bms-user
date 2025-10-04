import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class FilterCategoriesNew extends StatefulWidget {
  const FilterCategoriesNew({Key? key}) : super(key: key);

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
      final response = await http.get(Uri.parse('https://bms.innovativewidget.com/api/get-categories'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          setState(() {
            categories = List<Map<String, dynamic>>.from(data['response']['data']);
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
      setState(() {
        error = 'Error fetching categories: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Select Category',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (error != null)
            Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
          else if (categories.isEmpty)
              const Center(child: Text('No categories available'))
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return ListTile(
                      title: Text(category['name']),
                      onTap: () {
                        Navigator.pop(context, {'id': category['id'], 'name': category['name']});
                      },
                    );
                  },
                ),
              ),
        ],
      ),
    );
  }
}