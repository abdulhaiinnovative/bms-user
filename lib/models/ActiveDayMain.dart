

class ActiveDayMain {
  final String day;
  final String openingTime;
  final String closingTime;

  ActiveDayMain({
    required this.day,
    required this.openingTime,
    required this.closingTime,
  });

  factory ActiveDayMain.fromJson(Map<String, dynamic> json) {
    return ActiveDayMain(
      day: json['day'],
      openingTime: json['opening_time'],
      closingTime: json['closing_time'],
    );
  }
}