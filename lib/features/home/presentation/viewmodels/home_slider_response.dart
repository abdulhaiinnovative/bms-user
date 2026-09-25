class HomeSliderResponse {
  final List<SliderBlock> data;

  HomeSliderResponse({required this.data});

  factory HomeSliderResponse.fromJson(Map<String, dynamic> json) {
    return HomeSliderResponse(
      data: (json['response']?['data'] as List? ?? [])
          .map((e) => SliderBlock.fromJson(e))
          .toList(),
    );
  }
}

class SliderBlock {
  final int id;
  final String heading;
  final String content;
  final List<SliderImageItem> images;

  SliderBlock({
    required this.id,
    required this.heading,
    required this.content,
    required this.images,
  });

  factory SliderBlock.fromJson(Map<String, dynamic> json) {
    return SliderBlock(
      id: json['id'] ?? 0,
      heading: json['heading'] ?? '',
      content: json['content'] ?? '',
      images: (json['images'] as List? ?? [])
          .map((e) => SliderImageItem.fromJson(e))
          .toList(),
    );
  }
}

class SliderImageItem {
  final int id;
  final String imageUrl;
  final String? link;

  SliderImageItem({
    required this.id,
    required this.imageUrl,
    this.link,
  });

  factory SliderImageItem.fromJson(Map<String, dynamic> json) {
    final rawUrl = json['image_url'] ?? '';

    return SliderImageItem(
      id: json['id'] ?? 0,
      imageUrl: rawUrl.toString().trim(),
      link: json['link'],
    );
  }
}
