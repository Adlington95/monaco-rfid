class User {
  const User({
    required this.name,
    required this.previousAttempts,
    required this.employeeId,
    this.id,
    this.previousBestOverall,
    this.previousFastestLap,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final int? previousOverall;
    final int previousAttempts;
    final int? previousFastestLap;

    if (json.containsKey('lap_time')) {
      previousFastestLap = int.parse(json['lap_time'] as String);
    } else {
      previousFastestLap = null;
    }
    if (json.containsKey('attempts')) {
      previousAttempts = (json['attempts'] as int) + 1;
    } else {
      previousAttempts = 0;
    }
    if (json.containsKey('overall_time')) {
      previousOverall = int.parse(json['overall_time'] as String);
    } else {
      previousOverall = null;
    }

    return User(
      employeeId: json['employee_id'] as String,
      id: json['id'].toString(),
      name: json['name'] as String,
      previousAttempts: previousAttempts,
      previousBestOverall: previousOverall,
      previousFastestLap: previousFastestLap,
    );
  }

  final String name;
  final String employeeId;
  final int? previousBestOverall;
  final int? previousFastestLap;
  final String? id;
  final int? previousAttempts;
}
