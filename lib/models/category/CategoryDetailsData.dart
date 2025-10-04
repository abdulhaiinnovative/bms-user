import 'Category.dart';
import 'Services.dart';

class CategoryDetailsData {
  final Category? category;
  final Services? services;

  CategoryDetailsData({this.category, this.services});

  factory CategoryDetailsData.fromJson(Map<String, dynamic> json) {
    return CategoryDetailsData(
      category: json['category'] != null
          ? Category.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      services: json['services'] != null
          ? Services.fromJson(json['services'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category?.toJson(),
      'services': services?.toJson(),
    };
  }
}