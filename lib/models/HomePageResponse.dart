import 'home/Professional.dart';

class HomePageResponse {
  final int statusCode;
  final HomeData response;

  HomePageResponse({required this.statusCode, required this.response});

  factory HomePageResponse.fromJson(Map<String, dynamic> json) {
    return HomePageResponse(
      statusCode: json['statusCode'],
      response: HomeData.fromJson(json['response']),
    );
  }
}

class HomeData {
  final HomeContentData data;

  HomeData({required this.data});

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      data: HomeContentData.fromJson(json['data']),
    );
  }
}

class HomeContentData {
  final List<Type1> type1;
  final List<CategorySection> type2;
  final List<TopSalonSection> type3;
  final List<DealSection> type4;
  final List<ServiceSection> type5;


  HomeContentData({
    required this.type1,
    required this.type2,
    required this.type3,
    required this.type4,
     required this.type5
  });


  factory HomeContentData.fromJson(Map<String, dynamic> json) {
    return HomeContentData(
      type1: (json['type_1'] as List<dynamic>)
          .map((item) => Type1.fromJson(item))
          .toList(),

      type2: (json['type_2'] as List)
          .map((item) => CategorySection.fromJson(item))
          .toList(),
      type3: (json['type_3'] as List)
          .map((item) => TopSalonSection.fromJson(item))
          .toList(),
      type4: (json['type_4'] as List)
          .map((item) => DealSection.fromJson(item))
          .toList(),  // Parsing DealSection
      type5: (json['type_5'] as List)  // Parsing type_5
          .map((item) => ServiceSection.fromJson(item))
          .toList(),


    );
  }
}

class DealSection5 {
  final String heading;
  final List<Deal> data;

  DealSection5({required this.heading, required this.data});

  factory DealSection5.fromJson(Map<String, dynamic> json) {
    return DealSection5(
      heading: json['heading'],
      data: (json['data'] as List)
          .map((item) => Deal.fromJson(item))
          .toList(),
    );
  }
}

class DealSection {
  final String heading;
  final List<Deal> data;

  DealSection({required this.heading, required this.data});

  factory DealSection.fromJson(Map<String, dynamic> json) {
    return DealSection(
      heading: json['heading'],
      data: (json['data'] as List)
          .map((item) => Deal.fromJson(item))
          .toList(),
    );
  }
}


class Deal {
  final int? id;
  final int? salonId;
  final String? name;
  final String? image;
  final int? price;
  final String? discountType;
  final int? discountValue;
  final int? totalPrice;
  final String? startDate;
  final String? endDate;
  final int? status;
  final String? deletedAt;
  final String? createdAt;
  final String? updatedAt;
  final Salon? salon;
  final List<Service>? services;

  Deal({
    this.id,
    this.salonId,
    this.name,
    this.image,
    this.price,
    this.discountType,
    this.discountValue,
    this.totalPrice,
    this.startDate,
    this.endDate,
    this.status,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.salon,
    this.services,
  });

  factory Deal.fromJson(Map<String, dynamic> json) {
    return Deal(


      id: json['id'],
      salonId: json['salon_id'],
      name: json['name'],
      image: json['image'],
      price: json['price'],
      discountType: json['discount_type'],
      discountValue: json['discount_value'],
      totalPrice: json['total_price'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      status: json['status'],
      deletedAt: json['deleted_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      salon: json['salon'] != null ? Salon.fromJson(json['salon']) : null,
      services: (json['services'] as List?)?.map((e) => Service.fromJson(e)).toList(),
    );
  }
}

class ServiceSection {
  final String heading;
  final List<Service> data;

  ServiceSection({required this.heading, required this.data});

  factory ServiceSection.fromJson(Map<String, dynamic> json) {
    return ServiceSection(
      heading: json['heading'],
      data: (json['data'] as List)
          .map((item) => Service.fromJson(item))
          .toList(),
    );
  }
}



class Service {
  final int? id;
  final int? salonId;
  final String? name;
  final String? shortDescription;
  final String? duration;
  final String? description;
  final int? price; //
  final int? percentageDiscount;    //
  final int? discountAmount;   //
  final String? discountType;   //string
  final int? priceDiscount;   //
  final int? oldPrice;  // initial price
  final int? categoryId;
  final int? subcategoryId;
  final int? isFeature;
  final int? status;
  final int? extraTime;
  final String? gender;
  final String? deletedAt;
  final String? createdAt;
  final String? updatedAt;
  final Salon? salon;
  List<Professional>? professionals;


  Service({
    this.id,
    this.salonId,
    this.name,
    this.shortDescription,
    this.duration,
    this.description,
    this.price,
    this.percentageDiscount,
    this.discountAmount,
    this.discountType,
    this.priceDiscount,
    this.oldPrice,
    this.categoryId,
    this.subcategoryId,
    this.isFeature,
    this.status,
    this.extraTime,
    this.gender,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.salon,
    this.professionals,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      salonId: json['salon_id'],
      name: json['name'],
      shortDescription: json['short_description'],
      duration: json['duration'],
      description: json['description'],
      price: json['price'],
      percentageDiscount: json['percentage_discount'],
      discountAmount: json['discount_amount'],
      discountType: json['discount_type'],
      priceDiscount: json['price_discount'],
      oldPrice: json['old_price'],
      categoryId: json['category_id'],
      subcategoryId: json['subcategory_id'],
      isFeature: json['is_feature'],
      status: json['status'],
      extraTime: json['extra_time'],
      gender: json['gender'],
      deletedAt: json['deleted_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      salon: json['salon'] != null ? Salon.fromJson(json['salon']) : null,
      professionals: json['professionals'] != null
          ? (json['professionals'] as List<dynamic>)
          .map((e) => Professional.fromJson(e as Map<String, dynamic>))
          .toList()
          : null,
    );
  }
}





class CategorySection {
  final String heading;
  final List<Category> data;

  CategorySection({required this.heading, required this.data});

  factory CategorySection.fromJson(Map<String, dynamic> json) {
    return CategorySection(
      heading: json['heading'],
      data: (json['data'] as List)
          .map((item) => Category.fromJson(item))
          .toList(),
    );
  }
}

class Type2 {
  final String heading;
  final List<Category> data;

  Type2({required this.heading, required this.data});

  factory Type2.fromJson(Map<String, dynamic> json) {
    return Type2(
      heading: json['heading'],
      data: (json['data'] as List)
          .map((item) => Category.fromJson(item))
          .toList(),
    );
  }
}

class Category {
  final int? id;
  final String? name;
  final String? description;
  final int? status;
  final String? deletedAt;
  final String? createdAt;
  final String? updatedAt;

  Category({
    this.id,
    this.name,
    this.description,
    this.status,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
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





class SliderData {
  final String content;
  final String image;
  final int sharableId;
  final String sharableType;
  final String url;

  SliderData({
    required this.content,
    required this.image,
    required this.sharableId,
    required this.sharableType,
    required this.url,
  });

  factory SliderData.fromJson(Map<String, dynamic> json) {
    return SliderData(
      content: json['content'],
      image: json['image'],
      sharableId: json['sharable_id'],
      sharableType: json['sharable_type'],
      url: json['url'],
    );
  }


}


class TopSalonSection {
  final String heading;
  final List<Salon> data;

  TopSalonSection({required this.heading, required this.data});

  factory TopSalonSection.fromJson(Map<String, dynamic> json) {
    return TopSalonSection(
      heading: json['heading'],
      data: (json['data'] as List)
          .map((item) => Salon.fromJson(item))
          .toList(),
    );
  }
}


class Salon {
  final int? id;
  final int? vendorId;
  final String? name;
  final String? image;
  final String? logo;
  final String? country;
  final String? state;
  final String? city;
  final String? area;
  final String? address;
  final String? latitude;
  final String? longitude;
  final String? minBookingTime;
  final String? maxBookingTime;
  final String? minCancellationTime;
  final String? type;
  final String? facebook;
  final String? instagram;
  final String? linkedin;
  final String? twitter;
  final String? salonFor;
  final String? mapLocation;
  final String? salonPolicy;
  final String? additionalInformation;
  final String? about;
  final int? status;
  final int? suspended;
  final String? deletedAt;
  final String? createdAt;
  final String? updatedAt;
  final int? averageRating;
  final int? reviewCount;
  final bool? isFavourite;

  Salon({
    this.id,
    this.vendorId,
    this.name,
    this.image,
    this.logo,
    this.country,
    this.state,
    this.city,
    this.area,
    this.address,
    this.latitude,
    this.longitude,
    this.minBookingTime,
    this.maxBookingTime,
    this.minCancellationTime,
    this.type,
    this.facebook,
    this.instagram,
    this.linkedin,
    this.twitter,
    this.salonFor,
    this.mapLocation,
    this.salonPolicy,
    this.additionalInformation,
    this.about,
    this.status,
    this.suspended,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.averageRating,
    this.reviewCount,
    this.isFavourite,
  });

  factory Salon.fromJson(Map<String, dynamic> json) {
    return Salon(
      id: json['id'],
      vendorId: json['vendor_id'],
      name: json['name'],
      image: json['image'],
      logo: json['logo'],
      country: json['country'],
      state: json['state'],
      city: json['city'],
      area: json['area'],
      address: json['address'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      minBookingTime: json['min_booking_time'],
      maxBookingTime: json['max_booking_time'],
      minCancellationTime: json['min_cancellation_time'],
      type: json['type'],
      facebook: json['facebook'],
      instagram: json['instagram'],
      linkedin: json['linkedin'],
      twitter: json['twitter'],
      salonFor: json['salon_for'],
      mapLocation: json['map_location'],
      salonPolicy: json['salon_policy'],
      additionalInformation: json['additional_information'],
      about: json['about'],
      status: json['status'],
      suspended: json['suspended'],
      deletedAt: json['deleted_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      averageRating: json['average_rating'],
      reviewCount: json['review_count'],
      isFavourite: json['is_favourite'],
    );
  }
}

class SalonImage {
  final int id;
  final int salonId;
  final String image;
  final String? createdAt;
  final String? updatedAt;

  SalonImage({
    required this.id,
    required this.salonId,
    required this.image,
    this.createdAt,
    this.updatedAt,
  });

  factory SalonImage.fromJson(Map<String, dynamic> json) => SalonImage(
    id: json['id'],
    salonId: json['salon_id'],
    image: json['image'],
    createdAt: json['created_at'],
    updatedAt: json['updated_at'],
  );
}

class Type5 {
  final String heading;
  final List<ServiceData> services;

  Type5({required this.heading, required this.services});

  factory Type5.fromJson(Map<String, dynamic> json) => Type5(
    heading: json['heading'],
    services: (json['data'] as List<dynamic>? ?? [])
        .map((x) => ServiceData.fromJson(x))
        .toList(),
  );
}

// Model for the heading section in type_5
class HeadingSection {
  final String? heading;
  final List<ServiceData> data;

  HeadingSection({this.heading, this.data = const []});

  factory HeadingSection.fromJson(Map<String, dynamic> json) => HeadingSection(
    heading: json['heading'],
    data: (json['data'] as List<dynamic>? ?? [])
        .map((e) => ServiceData.fromJson(e))
        .toList(),
  );
}

// Model for the service data
class ServiceData {
  final int id;
  final int salonId;
  final String name;
  final String shortDescription;
  final String duration;
  final String description;
  final String price;
  final String? oldPrice;
  final int categoryId;
  final int subcategoryId;
  final bool isFeature;
  final bool status;
  final String gender;
  final Salon salon;

  ServiceData({
    required this.id,
    required this.salonId,
    required this.name,
    required this.shortDescription,
    required this.duration,
    required this.description,
    required this.price,
    this.oldPrice,
    required this.categoryId,
    required this.subcategoryId,
    required this.isFeature,
    required this.status,
    required this.gender,
    required this.salon,
  });

  factory ServiceData.fromJson(Map<String, dynamic> json) {
    return ServiceData(
      id: json['id'] ?? 0,
      salonId: json['salon_id'] ?? 0,
      name: json['name']?.toString() ?? '',
      shortDescription: json['short_description']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      oldPrice: json['old_price']?.toString(),
      categoryId: json['category_id'] ?? 0,
      subcategoryId: json['subcategory_id'] ?? 0,
      isFeature: json['is_feature'] == 1,
      status: json['status'] == 1,
      gender: json['gender']?.toString() ?? '',
      salon: Salon.fromJson(json['salon'] ?? {}),
    );
  }
}


class Type1 {
  final String heading;
  final List<SliderItem> data;

  Type1({
    required this.heading,
    required this.data,
  });

  factory Type1.fromJson(Map<String, dynamic> json) {
    return Type1(
      heading: json['heading']?.toString() ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => SliderItem.fromJson(e))
          .toList(),
    );
  }
}


class SliderItem {
  final String content;
  final String? image;
  final int sharableId;
  final String sharableType;
  final String url;

  SliderItem({
    required this.content,
    this.image,
    required this.sharableId,
    required this.sharableType,
    required this.url,
  });

  factory SliderItem.fromJson(Map<String, dynamic> json) {
    return SliderItem(
      content: json['content']?.toString() ?? '',
      image: json['image']?.toString(),
      sharableId: json['sharable_id'] ?? 0,
      sharableType: json['sharable_type']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
    );
  }
}