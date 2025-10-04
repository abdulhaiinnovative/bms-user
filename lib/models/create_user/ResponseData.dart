import 'User.dart';

class ResponseData {
  final User? user;
  final List<dynamic>? loyaltyTransactions;
  final String? accessToken;

  ResponseData({
    this.user,
    this.loyaltyTransactions,
    this.accessToken,
  });

  factory ResponseData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ResponseData(
        user: null,
        loyaltyTransactions: null,
        accessToken: null,
      );
    }
    return ResponseData(
      user: json['user'] is Map<String, dynamic>?
          ? User.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      loyaltyTransactions: json['loyaltyTransactions'] is List?
          ? List<dynamic>.from(json['loyaltyTransactions'] as List)
          : null,
      accessToken: json['accessToken'] as String?,
    );
  }

  Map<String, dynamic>? toJson() {
    return {
      'user': user?.toJson(),
      'loyaltyTransactions': loyaltyTransactions,
      'accessToken': accessToken,
    };
  }
}

