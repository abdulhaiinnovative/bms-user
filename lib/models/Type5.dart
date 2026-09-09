class Type5 {
  final String heading;
  final List<Type5Data> data;

  Type5({required this.heading, required this.data});

  factory Type5.fromJson(Map<String, dynamic> json) {
    return Type5(
      heading: json['heading'],
      data: (json['data'] as List? ?? [])
          .map((item) => Type5Data.fromJson(item))
          .toList(),
    );
  }
}

class Type5Data {
  final int id;
  final int salonId;
  final String name;
  final String shortDescription;
  final String duration;
  final String description;
  final String price;
  final int categoryId;
  final int subcategoryId;
  final bool isFeature;
  final int status;
  final int extraTime;
  final String gender;
  final String createdAt;
  final String updatedAt;

  Type5Data({
    required this.id,
    required this.salonId,
    required this.name,
    required this.shortDescription,
    required this.duration,
    required this.description,
    required this.price,
    required this.categoryId,
    required this.subcategoryId,
    required this.isFeature,
    required this.status,
    required this.extraTime,
    required this.gender,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Type5Data.fromJson(Map<String, dynamic> json) {
    return Type5Data(
      id: json['id'],
      salonId: json['salon_id'],
      name: json['name'],
      shortDescription: json['short_description'],
      duration: json['duration'],
      description: json['description'],
      price: json['price'],
      categoryId: json['category_id'],
      subcategoryId: json['subcategory_id'],
      isFeature: json['is_feature'],
      status: json['status'],
      extraTime: json['extra_time'],
      gender: json['gender'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
