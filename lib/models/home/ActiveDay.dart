class ActiveDay {
  final int? id;
  final int? salon_id;
  final String? day;
  final String? opening_time;
  final String? closing_time;
  final int? status;

  ActiveDay({
    this.id,
    this.salon_id,
    this.day,
    this.opening_time,
    this.closing_time,
    this.status,
  });

  factory ActiveDay.fromJson(Map<String, dynamic> json) {
    return ActiveDay(
      id: json['id'] as int?,
      salon_id: json['salon_id'] as int?,
      day: json['day'] as String?,
      opening_time: json['opening_time'] as String?,
      closing_time: json['closing_time'] as String?,
      status: json['status'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'salon_id': salon_id,
      'day': day,
      'opening_time': opening_time,
      'closing_time': closing_time,
      'status': status,
    };
  }
}