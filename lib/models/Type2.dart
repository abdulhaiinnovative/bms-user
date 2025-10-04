class Type2 {
  final String heading;
  final List<Type2Data> data;

  Type2({required this.heading, required this.data});

  factory Type2.fromJson(Map<String, dynamic> json) {
    return Type2(
      heading: json['heading'],
      data: (json['data'] as List)
          .map((item) => Type2Data.fromJson(item))
          .toList(),
    );
  }
}

class Type2Data {
  final int id;
  final String name;
  final String? description;
  final int status;
  final String? deletedAt;
  final String createdAt;
  final String updatedAt;

  Type2Data({
    required this.id,
    required this.name,
    this.description,
    required this.status,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Type2Data.fromJson(Map<String, dynamic> json) {
    return Type2Data(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      status: json['status'],
      deletedAt: json['deleted_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

