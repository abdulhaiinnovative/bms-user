import '../home/DealData.dart';
import '../home/Professional.dart';
import '../home/ServiceData.dart';
import 'AboutData.dart';
import 'ReviewData.dart';
class Section {
  final String? name;
  final String? type;
  final List<dynamic>? data;

  Section({this.name, this.type, this.data});

  factory Section.fromJson(Map<String, dynamic> json) {
    List<dynamic>? data;
    switch (json['type'] as String?) {
      case '2':
        data = (json['data'] as List<dynamic>?)?.map((e) => ServiceData.fromJson(e as Map<String, dynamic>)).toList();
        break;
      case '3':
        data = (json['data'] as List<dynamic>?)?.map((e) => ReviewData.fromJson(e as Map<String, dynamic>)).toList();
        break;
      case '4':
        data = (json['data'] as List<dynamic>?)?.map((e) => Professional.fromJson(e as Map<String, dynamic>)).toList();
        break;
      case '5':
        data = (json['data'] as List<dynamic>?)?.map((e) => AboutData.fromJson(e as Map<String, dynamic>)).toList();
        break;
      case '6':
        data = (json['data'] as List<dynamic>?)?.map((e) => DealData.fromJson(e as Map<String, dynamic>)).toList();
        break;
    }
    return Section(
      name: json['name'] as String?,
      type: json['type'] as String?,
      data: data,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'data': data?.map((e) {
        if (e is ServiceData) return e.toJson();
        if (e is ReviewData) return e.toJson();
        if (e is Professional) return e.toJson();
        if (e is AboutData) return e.toJson();
        if (e is DealData) return e.toJson();
        return e;
      }).toList(),
    };
  }
}