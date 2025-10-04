class Type1 {
  final String heading;
  final List<Type1Data> data;

  Type1({required this.heading, required this.data});

  factory Type1.fromJson(Map<String, dynamic> json) {
    return Type1(
      heading: json['heading'],
      data: (json['data'] as List)
          .map((item) => Type1Data.fromJson(item))
          .toList(),
    );
  }
}

class Type1Data {
  final String content;
  final String image;
  final int sharableId;
  final String sharableType;
  final String url;

  Type1Data({
    required this.content,
    required this.image,
    required this.sharableId,
    required this.sharableType,
    required this.url,
  });

  factory Type1Data.fromJson(Map<String, dynamic> json) {
    return Type1Data(
      content: json['content'],
      image: json['image'],
      sharableId: json['sharable_id'],
      sharableType: json['sharable_type'],
      url: json['url'],
    );
  }
}
