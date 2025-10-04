

class SliderData {
  final String? slider_for;
  final String? heading;
  final String? content;
  final int? sharable_id;
  final String? sharable_type;
  final int? status;
  final String? url;
  final List<String>? images;

  SliderData({
    this.slider_for,
    this.heading,
    this.content,
    this.sharable_id,
    this.sharable_type,
    this.status,
    this.url,
    this.images,
  });

  factory SliderData.fromJson(Map<String, dynamic> json) {
    return SliderData(
      slider_for: json['slider_for'] as String?,
      heading: json['heading'] as String?,
      content: json['content'] as String?,
      sharable_id: json['sharable_id'] as int?,
      sharable_type: json['sharable_type'] as String?,
      status: json['status'] as int?,
      url: json['url'] as String?,
      images: (json['images'] as List<dynamic>?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slider_for': slider_for,
      'heading': heading,
      'content': content,
      'sharable_id': sharable_id,
      'sharable_type': sharable_type,
      'status': status,
      'url': url,
      'images': images,
    };
  }
}