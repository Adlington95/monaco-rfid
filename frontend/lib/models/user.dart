class User {
  const User({
    required this.name,
    required this.previousAttempts,
    required this.employeeId,
    this.id,
    this.previousBestOverall,
    this.previousFastestLap,
    this.change,
    this.diff,
    this.newRecord,
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
  final int previousAttempts;
  final PlaceChange? change;
  final bool? newRecord;
  final int? diff;

  User copyWith({
    String? name,
    String? employeeId,
    int? previousBestOverall,
    int? previousFastestLap,
    String? id,
    int? previousAttempts,
    PlaceChange? change,
    bool? newRecord,
    int? diff,
  }) {
    return User(
      name: name ?? this.name,
      employeeId: employeeId ?? this.employeeId,
      previousBestOverall: previousBestOverall ?? this.previousBestOverall,
      previousFastestLap: previousFastestLap ?? this.previousFastestLap,
      id: id ?? this.id,
      previousAttempts: previousAttempts ?? this.previousAttempts,
      change: change ?? this.change,
      newRecord: newRecord ?? this.newRecord,
      diff: diff ?? this.diff,
    );
  }
}

enum PlaceChange { up, down, none }
