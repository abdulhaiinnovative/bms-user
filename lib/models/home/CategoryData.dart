

class CategoryData {
  final int? id;
  final String? name;
  final String? description;
  final int? status;
  final String? deleted_at;
  final String? created_at;
  final String? updated_at;

  CategoryData({
    this.id,
    this.name,
    this.description,
    this.status,
    this.deleted_at,
    this.created_at,
    this.updated_at,
  });

  factory CategoryData.fromJson(Map<String, dynamic> json) {
    return CategoryData(
      id: json['id'] as int?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      status: json['status'] as int?,
      deleted_at: json['deleted_at'] as String?,
      created_at: json['created_at'] as String?,
      updated_at: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status,
      'deleted_at': deleted_at,
      'created_at': created_at,
      'updated_at': updated_at,
    };
  }
}