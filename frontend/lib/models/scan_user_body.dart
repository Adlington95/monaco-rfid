import 'dart:convert';

class ScanUserBody {
  ScanUserBody(this.name, this.id);

  factory ScanUserBody.fromJsonString(String jsonString) {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;

      return ScanUserBody(json['name'].toString(), json['id'].toString());
    } catch (e) {
      return ScanUserBody(jsonString, jsonString);
    }
  }

  final String name;
  final String id;

  Map<String, dynamic> toJson() => {'name': name, 'id': id};
}
