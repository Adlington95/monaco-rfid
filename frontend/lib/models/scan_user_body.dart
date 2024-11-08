class ScanUserBody {

  ScanUserBody(this.name, this.id);

  ScanUserBody.fromJson(Map<String, dynamic> json)
      : name = json['name'].toString(),
        id = json['id'].toString();
  final String name;
  final String id;

  Map<String, dynamic> toJson() => {'name': name, 'id': id};
}
