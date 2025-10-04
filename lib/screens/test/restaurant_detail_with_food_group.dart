class SalonDetailServiceWithGroupModel {
  List<Data> data;

  SalonDetailServiceWithGroupModel({required this.data});

  // Constructor with initialization list
  SalonDetailServiceWithGroupModel.fromJson(Map<String, dynamic> json)
      : data = (json['data'] != null)
      ? List<Data>.from(json['data'].map((v) => Data.fromJson(v)))
      : [];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['data'] = this.data.map((v) => v.toJson()).toList();
    return data;
  }
}


class Data {
  String name;
  String sId;
  List<Services> services;
  String extra;

  Data({
    required this.name,
    required this.sId,
    required this.services,
    required this.extra,
  });

  // Constructor with initialization list
  Data.fromJson(Map<String, dynamic> json)
      : name = json['name'] ?? '',
        sId = json['_id'] ?? '',
        services = (json['services'] != null)
            ? List<Services>.from(json['services'].map((v) => Services.fromJson(v)))
            : [],
        extra = json['extra'] ?? '';

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = this.name;
    data['_id'] = this.sId;
    data['services'] = this.services.map((v) => v.toJson()).toList();
    data['extra'] = this.extra;
    return data;
  }
}


class Services {
  List<ServiceSpeciality> serviceSpeciality;
  List<String> images;
  List<String> keywords;
  int price;
  int discountPercent;
  int discountAmount;
  int minQuantity;
  String sId;
  String name;
  String activeImage;
  String subTitle;
  int calorie;
  String discountType;
  String serviceGroup;
  String salon;

  Services({
    required this.serviceSpeciality,
    required this.images,
    required this.keywords,
    required this.price,
    required this.discountPercent,
    required this.discountAmount,
    required this.minQuantity,
    required this.sId,
    required this.name,
    required this.activeImage,
    required this.subTitle,
    required this.calorie,
    required this.discountType,
    required this.serviceGroup,
    required this.salon,
  });

  // Constructor with initialization list
  Services.fromJson(Map<String, dynamic> json)
      : serviceSpeciality = json['serviceSpeciality'] != null
      ? List<ServiceSpeciality>.from(
      json['serviceSpeciality'].map((v) => ServiceSpeciality.fromJson(v)))
      : [],
        images = json['images']?.cast<String>() ?? [],
        keywords = json['keywords']?.cast<String>() ?? [],
        price = json['price'] ?? 0,
        discountPercent = json['discountPercent'] ?? 0,
        discountAmount = json['discountAmount'] ?? 0,
        minQuantity = json['minQuantity'] ?? 0,
        sId = json['_id'] ?? '',
        name = json['name'] ?? '',
        activeImage = json['activeImage'] ?? '',
        subTitle = json['subTitle'] ?? '',
        calorie = json['calorie'] ?? 0,
        discountType = json['discountType'] ?? '',
        serviceGroup = json['serviceGroup'] ?? '',
        salon = json['salon'] ?? '';

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['serviceSpeciality'] = this.serviceSpeciality.map((v) => v.toJson()).toList();
    data['images'] = this.images;
    data['keywords'] = this.keywords;
    data['price'] = this.price;
    data['discountPercent'] = this.discountPercent;
    data['discountAmount'] = this.discountAmount;
    data['minQuantity'] = this.minQuantity;
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['activeImage'] = this.activeImage;
    data['subTitle'] = this.subTitle;
    data['calorie'] = this.calorie;
    data['discountType'] = this.discountType;
    data['serviceGroup'] = this.serviceGroup;
    //data['salon'] = this.restaurant;
    return data;
  }
}


class ServiceSpeciality {
  String sId;
  String name;

  ServiceSpeciality({required this.sId, required this.name});

  // Constructor with initialization list
  ServiceSpeciality.fromJson(Map<String, dynamic> json)
      : sId = json['_id'] ?? '', // Provide a default value or handle null
        name = json['name'] ?? '';

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = this.sId;
    data['name'] = this.name;
    return data;
  }
}


class Items {
  bool isCheckDefault;
  int quantity;
  String sId;
  int extraPrice;
  String name;

  Items({
    required this.isCheckDefault,
    required this.quantity,
    required this.sId,
    required this.extraPrice,
    required this.name,
  });

  // Constructor with initialization list
  Items.fromJson(Map<String, dynamic> json)
      : isCheckDefault = json['isCheckDefault'] ?? false,
        quantity = json['quantity'] ?? 0,
        sId = json['_id'] ?? '',
        extraPrice = json['extraPrice'] ?? 0,
        name = json['name'] ?? '';

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isCheckDefault'] = this.isCheckDefault;
    data['quantity'] = this.quantity;
    data['_id'] = this.sId;
    data['extraPrice'] = this.extraPrice;
    data['name'] = this.name;
    return data;
  }
}
