class User {
  const User({
    required this.name,
    required this.previousAttempts,
    required this.id,
    this.previousBest,
    this.teamName,
    this.employeeId,
  });
  factory User.fromJson(Map<String, dynamic> json) {
    final int? previousBest;
    final int previousAttempts;

    if (json.containsKey('lap_time')) {
      previousBest = int.parse(json['lap_time'] as String);
    } else {
      previousBest = null;
    }
    if (json.containsKey('attempts')) {
      previousAttempts = (json['attempts'] as int) + 1;
    } else {
      previousAttempts = 0;
    }
    return User(
      employeeId: json['employee_id'] as String,
      id: json['id'].toString(),
      name: json['name'] as String,
      previousAttempts: previousAttempts,
      previousBest: previousBest,
      teamName: json['team_name'] as String,
    );
  }
  final String name;
  final int? previousBest;
  final String? teamName;
  final String? employeeId;
  final int previousAttempts;
  final String id;
}
