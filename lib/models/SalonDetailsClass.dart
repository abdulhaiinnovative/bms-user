
// Class for each section (like reviews)
class Section {
  final String name;
  final String type;
  final List<dynamic> data;

  Section({required this.name, required this.type, required this.data});

  factory Section.fromJson(Map<String, dynamic> json) {
    List<dynamic> parsedData;
    if (json['type'] == '2') {
      // Parse offers
      parsedData = (json['data'] as List).map((item) => SalonService.fromJson(item)).toList();
    } else if (json['type'] == '3') {

      parsedData = (json['data'] as List).map((item) => Reviews.fromJson(item)).toList();

    } else if (json['type'] == '4') {

      parsedData = (json['data'] as List).map((item) => Staff.fromJson(item)).toList();

    } else if (json['type'] == '5') {

      parsedData = (json['data'] as List).map((item) => About.fromJson(item)).toList();
    } else {
      // Parse reviews
      parsedData = (json['data'] as List).map((item) => Review.fromJson(item)).toList();
    }
    return Section(
      name: json['name'],
      type: json['type'],
      data: parsedData,
    );
  }
}


class OpeningTiming {
  final String day;
  final String startTime;
  final String endTime;

  OpeningTiming({
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  factory OpeningTiming.fromJson(Map<String, dynamic> json) {
    return OpeningTiming(
      day: json['day'],
      startTime: json['start_time'],
      endTime: json['end_time'],
    );
  }
}

class About {
  final String desc;
  final List<OpeningTiming> openingTimings;
  final String address;
  final String latLong;

  About({
    required this.desc,
    required this.openingTimings,
    required this.address,
    required this.latLong,
  });

  factory About.fromJson(Map<String, dynamic> json) {
    return About(
      desc: json['desc'],
      openingTimings: (json['opening_timings'] as List)
          .map((timing) => OpeningTiming.fromJson(timing))
          .toList(),
      address: json['address'],
      latLong: json['lat_long'],
    );
  }
}

class SalonService {
  final String id;
  final String title;
  final String description;
  final int price;
  final int salePercent;
  final int discountedPrice;

  SalonService({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.salePercent,
    required this.discountedPrice,
  });

  factory SalonService.fromJson(Map<String, dynamic> json) {
    return SalonService(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: json['price'],
      salePercent: json['sale_percent'],
      discountedPrice: json['discounted_price'],
    );
  }
}

// Class for reviews
class Reviews {
  final String user;
  final String review;
  final int star;
  final String image;
  final String createdAt;





  Reviews({required this.user, required this.review, required this.star,
    required this.image, required this.createdAt
  });

  factory Reviews.fromJson(Map<String, dynamic> json) {
    return Reviews(
      user: json['user'],
      review: json['review'],
      star: json['star'],

      image: json['image'],
      createdAt: json['createdAt'],

    );
  }
}

class Review {
  final String user;
  final String review;
  final int star;





  Review({required this.user, required this.review, required this.star,

  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      user: json['user'],
      review: json['review'],
      star: json['star'],

    );
  }
}




// Class for location
class Location {
  final String address;
  final double lat;
  final double long;

  Location({required this.address, required this.lat, required this.long});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      address: json['address'],
      lat: json['lat'].toDouble(),
      long: json['long'].toDouble(),
    );
  }
}

// Class for staff
class Staff {
  final String name;
  final String id;
  final String imageUrl;
  final String speciality;


  Staff({required this.name, required this.id, required this.imageUrl, required this.speciality});

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      name: json['name'],
      id: json['id'],
      imageUrl: json['image_url'],
      speciality: json['speciality'],
    );
  }
}

// Class for services
class Service {
  final String title;
  final String description;
  final double price;
  final double salePercent;
  final double discountedPrice;

  Service({
    required this.title,
    required this.description,
    required this.price,
    required this.salePercent,
    required this.discountedPrice,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      title: json['title'],
      description: json['description'],
      price: json['price'].toDouble(),
      salePercent: json['sale_percent'].toDouble(),
      discountedPrice: json['discounted_price'].toDouble(),
    );
  }
}

// Class for deals
class Deal {
  final String title;
  final String description;
  final double price;
  final double salePercent;
  final double discountedPrice;

  Deal({
    required this.title,
    required this.description,
    required this.price,
    required this.salePercent,
    required this.discountedPrice,
  });

  factory Deal.fromJson(Map<String, dynamic> json) {
    return Deal(
      title: json['title'],
      description: json['description'],
      price: json['price'].toDouble(),
      salePercent: json['sale_percent'].toDouble(),
      discountedPrice: json['discounted_price'].toDouble(),
    );
  }
}

// Class for the main SalonDetails
class SalonDetailsClass {
  final String name;
  final String id;
  final List<String> images;
  final String createdAt;
  final String gender;
  final String logo;
  final String star;
  final List<String> tags;
  final List<Section> sections;


  SalonDetailsClass({
    required this.name,
    required this.id,
    required this.images,
    required this.createdAt,
    required this.gender,
    required this.logo,
    required this.star,
    required this.tags,
    required this.sections,

  });

  factory SalonDetailsClass.fromJson(Map<String, dynamic> json) {
    return SalonDetailsClass(
      name: json['name'],
      id: json['id'],
      images: List<String>.from(json['images']),
      createdAt: json['created_at'],
      gender: json['gender'],
      logo: json['logo'],
      star: json['star'],
      tags: List<String>.from(json['tags']),
      sections: List<Section>.from(json['sections'].map((x) => Section.fromJson(x))),

    );
  }
}
