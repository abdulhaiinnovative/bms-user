import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../presentation/viewmodels/category/category_view_model.dart';

class CategoryDetailsFetchAPIData extends StatefulWidget {
  static const String routeName = '/category_details_fetch_api_data';

  const CategoryDetailsFetchAPIData({super.key});

  @override
  _CategoryDetailsFetchAPIDataState createState() => _CategoryDetailsFetchAPIDataState();
}

class _CategoryDetailsFetchAPIDataState extends State<CategoryDetailsFetchAPIData> {
  int? _categoryId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _categoryId = ModalRoute.of(context)?.settings.arguments as int? ?? 1;
    
    // Load category data using ViewModel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryViewModel>().loadCategoryDetails(_categoryId!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Category Details'),
            backgroundColor: Colors.blueAccent,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => viewModel.refresh(),
            tooltip: 'Refresh Data',
            backgroundColor: Colors.blueAccent,
            child: const Icon(Icons.refresh),
          ),
          body: _buildBody(viewModel),
        );
      },
    );
  }

  Widget _buildBody(CategoryViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.isError) {
      developer.log('Error: ${viewModel.errorMessage}');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(viewModel.errorMessage ?? 'Failed to load data'),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => viewModel.refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (viewModel.categoryData == null) {
      developer.log('Category data is null');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No response data available'),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => viewModel.refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (viewModel.categoryDetails == null) {
      developer.log('Category details is null');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('No category data available for ID: $_categoryId'),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => viewModel.refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: _buildCategoryContent(viewModel),
    );
  }

  Widget _buildCategoryContent(CategoryViewModel viewModel) {
    final categoryData = viewModel.categoryDetails!;
    developer.log('Category name: ${categoryData.category?.name}');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Header
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  viewModel.categoryName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Description: ${categoryData.category?.description ?? 'No description available'}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Services
        Text(
          'Services (${viewModel.servicesCount})',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(height: 10),
        if (viewModel.hasServices)
          ...viewModel.services!.map((service) {
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Salon: ${service.salon?.name ?? 'N/A'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Price: ${service.price ?? 'N/A'} ${service.discount_type != null ? '(${service.price_discount ?? service.discount_amount ?? 'No discount'})' : ''}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Duration: ${service.duration ?? 'N/A'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Gender: ${service.gender?.capitalize() ?? 'N/A'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    if (service.professionals?.isNotEmpty ?? false) ...[
                      const Text(
                        'Professionals:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      ...service.professionals!.map((professional) {
                        return ListTile(
                          leading: professional.image != null
                              ? CircleAvatar(
                            backgroundImage: NetworkImage(professional.image!),
                            onBackgroundImageError: (error, stackTrace) {
                              developer.log('Failed to load professional image: ${professional.image}, error: $error');
                            },
                          )
                              : const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(professional.name ?? 'N/A'),
                          subtitle: Text('Experience: ${professional.experience ?? 'N/A'}'),
                        );
                      }),
                    ] else
                      const Text(
                        'No professionals available',
                        style: TextStyle(color: Colors.grey),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        if (!viewModel.hasServices)
          const Text(
            'No services available',
            style: TextStyle(color: Colors.grey),
          ),
      ],
    );
  }
}

// Extension to capitalize string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}