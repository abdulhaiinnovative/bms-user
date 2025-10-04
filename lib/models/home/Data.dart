


import 'Type1.dart';
import 'Type2.dart';
import 'Type3.dart';
import 'Type4.dart';
import 'Type5.dart';


class Data {
  final List<Type1>? type_1;
  final List<Type2>? type_2;
  final List<Type3>? type_3;
  final List<Type4>? type_4;
  final List<Type5>? type_5;

  Data({this.type_1, this.type_2, this.type_3, this.type_4, this.type_5});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      type_1: (json['type_1'] as List<dynamic>?)?.map((e) => Type1.fromJson(e as Map<String, dynamic>)).toList(),
      type_2: (json['type_2'] as List<dynamic>?)?.map((e) => Type2.fromJson(e as Map<String, dynamic>)).toList(),
      type_3: (json['type_3'] as List<dynamic>?)?.map((e) => Type3.fromJson(e as Map<String, dynamic>)).toList(),
      type_4: (json['type_4'] as List<dynamic>?)?.map((e) => Type4.fromJson(e as Map<String, dynamic>)).toList(),
      type_5: (json['type_5'] as List<dynamic>?)?.map((e) => Type5.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type_1': type_1?.map((e) => e.toJson()).toList(),
      'type_2': type_2?.map((e) => e.toJson()).toList(),
      'type_3': type_3?.map((e) => e.toJson()).toList(),
      'type_4': type_4?.map((e) => e.toJson()).toList(),
      'type_5': type_5?.map((e) => e.toJson()).toList(),
    };
  }
}