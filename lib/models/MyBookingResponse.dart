
class MyBookingResponse {
  final bool? status;
  final String? message;
  final ResponseData? response;

  MyBookingResponse({this.status, this.message, this.response});

  factory MyBookingResponse.fromJson(Map<String, dynamic> json) {
    return MyBookingResponse(
      status: json['status'] as bool?,
      message: json['message']?.toString(),
      response: json['response'] != null
          ? ResponseData.fromJson(json['response'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ResponseData {
  final BookingData? data;

  ResponseData({this.data});

  factory ResponseData.fromJson(Map<String, dynamic> json) {
    if (json['data'] == null) {
      return ResponseData(data: null);
    }

    // Check if data is a List (empty bookings case) or Map (paginated data)
    if (json['data'] is List) {
      // Wrap the list in the expected BookingData structure
      final list = json['data'] as List<dynamic>;
      final wrappedData = {
        'current_page': 1,
        'data': list,
        'first_page_url': null,
        'from': list.isEmpty ? null : 1,
        'last_page': 1,
        'last_page_url': null,
        'links': [],
        'next_page_url': null,
        'path': null,
        'per_page': list.length,
        'prev_page_url': null,
        'to': list.isEmpty ? null : list.length,
        'total': list.length,
      };
      return ResponseData(
        data: BookingData.fromJson(wrappedData),
      );
    }

    // Normal case: data is a Map with pagination
    return ResponseData(
      data: BookingData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class BookingData {
  final int? currentPage;
  final List<Booking>? data;
  final String? firstPageUrl;
  final int? from;
  final int? lastPage;
  final String? lastPageUrl;
  final List<Link>? links;
  final String? nextPageUrl;
  final String? path;
  final int? perPage;
  final String? prevPageUrl;
  final int? to;
  final int? total;

  BookingData({
    this.currentPage,
    this.data,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.links,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  factory BookingData.fromJson(Map<String, dynamic> json) {
    return BookingData(
      currentPage:
          json['current_page'] is int ? json['current_page'] as int? : null,
      data: json['data'] != null
          ? (json['data'] as List<dynamic>)
              .map((e) => Booking.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      firstPageUrl: json['first_page_url']?.toString(),
      from: json['from'] is int ? json['from'] as int? : null,
      lastPage: json['last_page'] is int ? json['last_page'] as int? : null,
      lastPageUrl: json['last_page_url']?.toString(),
      links: json['links'] != null
          ? (json['links'] as List<dynamic>)
              .map((e) => Link.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      nextPageUrl: json['next_page_url']?.toString(),
      path: json['path']?.toString(),
      perPage: json['per_page'] is int ? json['per_page'] as int? : null,
      prevPageUrl: json['prev_page_url']?.toString(),
      to: json['to'] is int ? json['to'] as int? : null,
      total: json['total'] is int ? json['total'] as int? : null,
    );
  }
}

class Booking {
  final int? id;
  final String? title;
  final int? salonId;
  final int? userId;
  final int? teamId;
  final String? date;
  final String? time;
  final String? paymentMethod;
  final int? payment;
  final int? commission;
  final String? paymentStatus;
  final String? bookingType;
  final String? status;
  final int? usedLoyaltyPoints;
  final Salon? salon;
  final List<BookingService>? services;
  final List<dynamic>? deal;

  Booking({
    this.id,
    this.title,
    this.salonId,
    this.userId,
    this.teamId,
    this.date,
    this.time,
    this.paymentMethod,
    this.payment,
    this.commission,
    this.paymentStatus,
    this.bookingType,
    this.status,
    this.usedLoyaltyPoints,
    this.salon,
    this.services,
    this.deal,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] is int ? json['id'] as int? : null,
      salonId: json['salon_id'] is int ? json['salon_id'] as int? : null,
      userId: json['user_id'] is int ? json['user_id'] as int? : null,
      teamId: json['team_id'] is int ? json['team_id'] as int? : null,
      date: json['date']?.toString(),
      time: json['time']?.toString(),
      title: json['title']?.toString(),
      paymentMethod: json['payment_method']?.toString(),
      payment: json['payment'] is int ? json['payment'] as int? : null,
      commission: json['commission'] is int ? json['commission'] as int? : null,
      paymentStatus: json['payment_status']?.toString(),
      bookingType: json['booking_type']?.toString(),
      status: json['status']?.toString(),
      usedLoyaltyPoints: json['used_loyalty_points'] is int
          ? json['used_loyalty_points'] as int?
          : null,
      salon: json['salon'] != null
          ? Salon.fromJson(json['salon'] as Map<String, dynamic>)
          : null,
      services: json['services'] != null
          ? (json['services'] as List<dynamic>)
              .map((e) => BookingService.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      deal: json['deal'] != null ? json['deal'] as List<dynamic> : null,
    );
  }
}

class Review {
  final int? id;
  final int? salonId;
  final int? userId;
  final int? bookingId;
  final String? comment;
  final int? rating;
  final int? status;
  final int? isHome;

  Review({
    this.id,
    this.salonId,
    this.userId,
    this.bookingId,
    this.comment,
    this.rating,
    this.status,
    this.isHome,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] is int ? json['id'] as int? : null,
      salonId: json['salon_id'] is int ? json['salon_id'] as int? : null,
      userId: json['user_id'] is int ? json['user_id'] as int? : null,
      bookingId: json['booking_id'] is int ? json['booking_id'] as int? : null,
      comment: json['comment']?.toString(),
      rating: json['rating'] is int ? json['rating'] as int? : null,
      status: json['status'] is int ? json['status'] as int? : null,
      isHome: json['is_home'] is int ? json['is_home'] as int? : null,
    );
  }
}

class Salon {
  final int? id;
  final String? name;
  final String? logo;
  final String? image;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? salonPolicy;
  final String? about;
  final int? averageRating;
  final int? reviewCount;
  final List<ActiveDay>? activeDays;
  final List<String>? images;

  Salon({
    this.id,
    this.name,
    this.logo,
    this.image,
    this.address,
    this.latitude,
    this.longitude,
    this.salonPolicy,
    this.about,
    this.averageRating,
    this.reviewCount,
    this.activeDays,
    this.images,
  });

  factory Salon.fromJson(Map<String, dynamic> json) {
    return Salon(
      id: json['id'] is int ? json['id'] as int? : null,
      name: json['name']?.toString(),
      logo: json['logo']?.toString(),
      image: json['image']?.toString(),
      address: json['address']?.toString(),
      latitude: double.tryParse(json['latitude']?.toString() ?? ''),
      longitude: double.tryParse(json['longitude']?.toString() ?? ''),
      salonPolicy: json['salon_policy']?.toString(),
      about: json['about']?.toString(),
      averageRating:
          json['average_rating'] is int ? json['average_rating'] as int? : null,
      reviewCount:
          json['review_count'] is int ? json['review_count'] as int? : null,
      activeDays: json['active_days'] != null
          ? (json['active_days'] as List<dynamic>)
              .map((e) => ActiveDay.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      images: json['images'] != null
          ? (json['images'] as List<dynamic>).map((e) => e.toString()).toList()
          : null,
    );
  }
}

class ActiveDay {
  final String? day;
  final String? openingTime;
  final String? closingTime;
  final int? status;

  ActiveDay({
    this.day,
    this.openingTime,
    this.closingTime,
    this.status,
  });

  factory ActiveDay.fromJson(Map<String, dynamic> json) {
    return ActiveDay(
      day: json['day']?.toString(),
      openingTime: json['opening_time']?.toString(),
      closingTime: json['closing_time']?.toString(),
      status: json['status'] is int ? json['status'] as int? : null,
    );
  }
}

class Link {
  final String? url;
  final String? label;
  final bool? active;

  Link({this.url, this.label, this.active});

  factory Link.fromJson(Map<String, dynamic> json) {
    return Link(
      url: json['url']?.toString(),
      label: json['label']?.toString(),
      active: json['active'] is bool ? json['active'] as bool? : null,
    );
  }
}

class BookingService {
  final int? id;
  final String? name;
  final BookingProfessional? selectedProfessional;

  BookingService({
    this.id,
    this.name,
    this.selectedProfessional,
  });

  factory BookingService.fromJson(Map<String, dynamic> json) {
    return BookingService(
      id: json['id'] is int ? json['id'] as int? : null,
      name: json['name']?.toString(),
      selectedProfessional: json['staff'] != null
          ? BookingProfessional.fromJson(
              json['staff'] as Map<String, dynamic>)
          : (json['selected_professional'] != null
              ? BookingProfessional.fromJson(
                  json['selected_professional'] as Map<String, dynamic>)
              : null),
    );
  }
}

class BookingProfessional {
  final int? id;
  final String? firstName;
  final String? lastName;
  final String? name;
  final String? image;
  final String? phone;

  BookingProfessional({
    this.id,
    this.firstName,
    this.lastName,
    this.name,
    this.image,
    this.phone,
  });

  factory BookingProfessional.fromJson(Map<String, dynamic> json) {
    return BookingProfessional(
      id: json['id'] is int ? json['id'] as int? : null,
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      name: json['name']?.toString(),
      image: json['image']?.toString(),
      phone: json['phone']?.toString(),
    );
  }

  String get displayName {
    final fullName = '$firstName $lastName'.trim();
    if (fullName.isNotEmpty) return fullName;
    if (name != null && name!.isNotEmpty) return name!;
    return 'Professional';
  }
}
