class ScanUserBody {
  final String name;
  final String id;

  ScanUserBody(this.name, this.id);

  ScanUserBody.fromJson(Map<String, dynamic> json)
      : name = json['name'].toString(),
        id = json['id'].toString();

  Map<String, dynamic> toJson() => {'name': name, 'id': id};
}
