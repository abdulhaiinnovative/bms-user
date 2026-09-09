class SliderModel {
  final String imageUrl;
  final String? link;

  SliderModel({required this.imageUrl, this.link});

  factory SliderModel.fromJson(Map<String, dynamic> json) {
    return SliderModel(
      imageUrl: json['image_url'],
      link: json['link'],
    );
  }
}

class BannerSlider {
  final String heading;
  final List<SliderModel> images;

  BannerSlider({required this.heading, required this.images});

  factory BannerSlider.fromJson(Map<String, dynamic> json) {
    return BannerSlider(
      heading: json['heading'],
      images: (json['images'] as List)
          .map((e) => SliderModel.fromJson(e))
          .toList(),
    );
  }
}
class SliderImage {
  final String imageUrl;
  final String? link;

  SliderImage({
    required this.imageUrl,
    this.link,
  });

  factory SliderImage.fromJson(Map<String, dynamic> json) {
    return SliderImage(
      imageUrl: Uri.encodeFull(json['image_url'] ?? ''),
      link: json['link'],
    );
  }
}