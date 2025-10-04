import 'User.dart';

class ReviewData {
  final int? id;
  final int? salon_id;
  final int? user_id;
  final int? booking_id;
  final String? comment;
  final int? rating;
  final int? status;
  final int? is_home;
  final User? user;

  ReviewData({
    this.id,
    this.salon_id,
    this.user_id,
    this.booking_id,
    this.comment,
    this.rating,
    this.status,
    this.is_home,
    this.user,
  });

  factory ReviewData.fromJson(Map<String, dynamic> json) {
    return ReviewData(
      id: json['id'] as int?,
      salon_id: json['salon_id'] as int?,
      user_id: json['user_id'] as int?,
      booking_id: json['booking_id'] as int?,
      comment: json['comment'] as String?,
      rating: json['rating'] as int?,
      status: json['status'] as int?,
      is_home: json['is_home'] as int?,
      user: json['user'] != null ? User.fromJson(json['user'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'salon_id': salon_id,
      'user_id': user_id,
      'booking_id': booking_id,
      'comment': comment,
      'rating': rating,
      'status': status,
      'is_home': is_home,
      'user': user?.toJson(),
    };
  }
}
