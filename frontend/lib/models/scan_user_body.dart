class ScanUserBody {
  ScanUserBody(this.firstName, this.surname, this.country, this.email);

  factory ScanUserBody.fromJsonString(String jsonString) {
    String firstName;
    String surname;
    String country;
    String email;

    final regex = RegExp(r'^(.*?)\^(.*?)\^(.*?)\^(.*?)$');
    final match = regex.firstMatch(jsonString);

    if (match != null) {
      firstName = match.group(1) ?? '';
      surname = match.group(2) ?? '';
      country = match.group(3) ?? '';
      email = match.group(4) ?? '';
    } else {
      throw const FormatException('Invalid scan result format');
    }

    return ScanUserBody(firstName, surname, country, email);
  }

  final String firstName;
  final String surname;
  final String country;
  final String email;

  Map<String, dynamic> toJson() => {'name': '$firstName $surname', 'id': email};
}
