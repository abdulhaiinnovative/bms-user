class Professional {
  final int? id;
  final int? salon_id;
  final String? first_name;
  final String? last_name;
  final String? name;
  final String? email;
  final String? phone;
  final String? image;
  final String? experience;
  final int? booking_accept;
  final int? monday;
  final int? tuesday;
  final int? wednesday;
  final int? thursday;
  final int? friday;
  final int? saturday;
  final int? sunday;
  final String? start_date;
  final String? end_date;
  final int? status;
  final String? note;

  Professional({
    this.id,
    this.salon_id,
    this.first_name,
    this.last_name,
    this.name,
    this.email,
    this.phone,
    this.image,
    this.experience,
    this.booking_accept,
    this.monday,
    this.tuesday,
    this.wednesday,
    this.thursday,
    this.friday,
    this.saturday,
    this.sunday,
    this.start_date,
    this.end_date,
    this.status,
    this.note,
  });

  factory Professional.fromJson(Map<String, dynamic> json) {
    return Professional(
      id: json['id'] as int?,
      salon_id: json['salon_id'] as int?,
      first_name: json['first_name'] as String?,
      last_name: json['last_name'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      image: json['image'] as String?,
      experience: json['experience'] as String?,
      booking_accept: json['booking_accept'] as int?,
      monday: json['monday'] as int?,
      tuesday: json['tuesday'] as int?,
      wednesday: json['wednesday'] as int?,
      thursday: json['thursday'] as int?,
      friday: json['friday'] as int?,
      saturday: json['saturday'] as int?,
      sunday: json['sunday'] as int?,
      start_date: json['start_date'] as String?,
      end_date: json['end_date'] as String?,
      status: json['status'] as int?,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'salon_id': salon_id,
      'first_name': first_name,
      'last_name': last_name,
      'name': name,
      'email': email,
      'phone': phone,
      'image': image,
      'experience': experience,
      'booking_accept': booking_accept,
      'monday': monday,
      'tuesday': tuesday,
      'wednesday': wednesday,
      'thursday': thursday,
      'friday': friday,
      'saturday': saturday,
      'sunday': sunday,
      'start_date': start_date,
      'end_date': end_date,
      'status': status,
      'note': note,
    };
  }
}