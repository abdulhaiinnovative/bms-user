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
    data['address'] = this.address.toJson();
    data['geo'] = this.geo.toJson();
    data['image'] = this.image;
    data['agreementDoc'] = this.agreementDoc;
    data['keywords'] = this.keywords;
    data['famousFor'] = this.famousFor;
    data['availableServiceCategory'] = this.availableServiceCategory;
    data['dietPlans'] = this.dietPlans;
    data['userPickup'] = this.userPickup;
    data['hasOwnDelivery'] = this.hasOwnDelivery;
    data['hasDeliveryCondition'] = this.hasDeliveryCondition;
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['region'] = this.region;
    data['regionID'] = this.regionID;
    data['email'] = this.email;
    data['phoneNumber'] = this.phoneNumber;
    data['website'] = this.website;
    data['description'] = this.description;
    data['category'] = this.category;
    data['deliveryCharge'] = this.deliveryCharge;
    data['minimumSpentForFreeDelivery'] = this.minimumSpentForFreeDelivery;
    data['minimumSpentToCheckout'] = this.minimumSpentToCheckout;
    data['favorite'] = this.favorite;
    data['sponsored'] = this.sponsored;
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
    data['state'] = this.state;
    data['city'] = this.city;
    data['street'] = this.street;
    data['zipCode'] = this.zipCode;
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
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    return data;
  }
}
