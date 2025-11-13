class SalonDetailModel {
  Address address;
  Geo geo;
  List<String> image;
  List<String> agreementDoc;
  List<String> keywords;
  List<String> famousFor;
  List<String> availableServiceCategory;
  List<String> dietPlans;
  bool userPickup;
  bool hasOwnDelivery;
  bool hasDeliveryCondition;
  String sId;
  String name;
  String region;
  String regionID;
  String email;
  String phoneNumber;
  String website;
  String description;
  String category;
  int deliveryCharge;
  int minimumSpentForFreeDelivery;
  int minimumSpentToCheckout;
  bool favorite;
  bool sponsored;

  SalonDetailModel({
    required this.address,
    required this.geo,
    required this.image,
    required this.agreementDoc,
    required this.keywords,
    required this.famousFor,
    required this.availableServiceCategory,
    required this.dietPlans,
    required this.userPickup,
    required this.hasOwnDelivery,
    required this.hasDeliveryCondition,
    required this.sId,
    required this.name,
    required this.region,
    required this.regionID,
    required this.email,
    required this.phoneNumber,
    required this.website,
    required this.description,
    required this.category,
    required this.deliveryCharge,
    required this.minimumSpentForFreeDelivery,
    required this.minimumSpentToCheckout,
    this.favorite = false,
    this.sponsored = true,
  });

  // Constructor with initialization list
  SalonDetailModel.fromJson(Map<String, dynamic> json)
      : address = Address.fromJson(json['address'] ?? {}),
        geo = Geo.fromJson(json['geo'] ?? {}),
        image = List<String>.from(json['image'] ?? []),
        agreementDoc = List<String>.from(json['agreementDoc'] ?? []),
        keywords = List<String>.from(json['keywords'] ?? []),
        famousFor = List<String>.from(json['famousFor'] ?? []),
        availableServiceCategory = List<String>.from(json['availableServiceCategory'] ?? []),
        dietPlans = List<String>.from(json['dietPlans'] ?? []),
        userPickup = json['userPickup'] ?? false,
        hasOwnDelivery = json['hasOwnDelivery'] ?? false,
        hasDeliveryCondition = json['hasDeliveryCondition'] ?? false,
        sId = json['_id'] ?? '',
        name = json['name'] ?? '',
        region = json['region'] ?? '',
        regionID = json['regionID'] ?? '',
        email = json['email'] ?? '',
        phoneNumber = json['phoneNumber'] ?? '',
        website = json['website'] ?? '',
        description = json['description'] ?? '',
        category = json['category'] ?? '',
        deliveryCharge = json['deliveryCharge'] ?? 0,
        minimumSpentForFreeDelivery = json['minimumSpentForFreeDelivery'] ?? 0,
        minimumSpentToCheckout = json['minimumSpentToCheckout'] ?? 0,
        favorite = json['favorite'] ?? false,
        sponsored = json['sponsored'] ?? true;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['address'] = address.toJson();
    data['geo'] = geo.toJson();
    data['image'] = image;
    data['agreementDoc'] = agreementDoc;
    data['keywords'] = keywords;
    data['famousFor'] = famousFor;
    data['availableServiceCategory'] = availableServiceCategory;
    data['dietPlans'] = dietPlans;
    data['userPickup'] = userPickup;
    data['hasOwnDelivery'] = hasOwnDelivery;
    data['hasDeliveryCondition'] = hasDeliveryCondition;
    data['_id'] = sId;
    data['name'] = name;
    data['region'] = region;
    data['regionID'] = regionID;
    data['email'] = email;
    data['phoneNumber'] = phoneNumber;
    data['website'] = website;
    data['description'] = description;
    data['category'] = category;
    data['deliveryCharge'] = deliveryCharge;
    data['minimumSpentForFreeDelivery'] = minimumSpentForFreeDelivery;
    data['minimumSpentToCheckout'] = minimumSpentToCheckout;
    data['favorite'] = favorite;
    data['sponsored'] = sponsored;
    return data;
  }
}

class Address {
  String state;
  String city;
  String street;
  int zipCode;

  Address({
    required this.state,
    required this.city,
    required this.street,
    required this.zipCode,
  });

  // Constructor with initialization list
  Address.fromJson(Map<String, dynamic> json)
      : state = json['state'] ?? '',
        city = json['city'] ?? '',
        street = json['street'] ?? '',
        zipCode = json['zipCode'] ?? 0;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['state'] = state;
    data['city'] = city;
    data['street'] = street;
    data['zipCode'] = zipCode;
    return data;
  }

  String get formatted => '$street, $city, $state';
}

class Geo {
  double latitude;
  double longitude;

  Geo({
    required this.latitude,
    required this.longitude,
  });

  // Constructor with initialization list
  Geo.fromJson(Map<String, dynamic> json)
      : latitude = (json['latitude'] ?? 0.0).toDouble(),
        longitude = (json['longitude'] ?? 0.0).toDouble();

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}
