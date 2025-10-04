
class BookingModel {
  final int salonId;
  final List<int> serviceId;
  final List<int> professionId;
  final String time;
  final bool paymentStatus;
  final int totalPrice;
  final int? loyaltyPointsUsed;
  final int? dealId;
  final Map<String, int> qty;
  final String bookingType;

  BookingModel({
    required this.salonId,
    required this.serviceId,
    required this.professionId,
    required this.time,
    required this.paymentStatus,
    required this.totalPrice,
    this.loyaltyPointsUsed,
    this.dealId,
    required this.qty,
    required this.bookingType,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      salonId: json['salon_id'] as int,
      serviceId: List<int>.from(json['service_id']),
      professionId: List<int>.from(json['profession_id']),
      time: json['time'] as String,
      paymentStatus: json['payment_status'] as bool,
      totalPrice: json['total_price'] as int,
      loyaltyPointsUsed: json['loyalty_points_used'] as int?,
      dealId: json['deal_id'] as int?,
      qty: Map<String, int>.from(json['qty'].map((k, v) => MapEntry(k, v as int))),
      bookingType: json['booking_type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'salon_id': salonId,
      'service_id': serviceId,
      'profession_id': professionId,
      'time': time,
      'payment_status': paymentStatus,
      'total_price': totalPrice,
      'loyalty_points_used': loyaltyPointsUsed,
      'deal_id': dealId,
      'qty': qty,
      'booking_type': bookingType,
    };
  }
}