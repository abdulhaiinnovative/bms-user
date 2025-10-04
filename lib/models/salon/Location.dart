class Location {
  final String? address;
  final String? lat;
  final String? long;

  Location({this.address, this.lat, this.long});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      address: json['address'] as String?,
      lat: json['lat'] as String?,
      long: json['long'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'lat': lat,
      'long': long,
    };
  }
}