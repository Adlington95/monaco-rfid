class DriverStandingItem {
  const DriverStandingItem(this.name, this.id, this.tries, this.time, {this.change, this.diff, this.newRecord});
  factory DriverStandingItem.fromJson(Map<String, dynamic> json) {
    return DriverStandingItem(
      json['name'] as String,
      json['employee_id'] as String,
      (json['attempts'] as int) + 1,
      int.tryParse(json['lap_time'] as String) ?? 0,
    );
  }
  final String name;
  final String id;
  final int tries;
  final PlaceChange? change;
  final int time;
  final int? diff;
  final bool? newRecord;

  DriverStandingItem copyWith({
    String? name,
    String? id,
    int? tries,
    PlaceChange? change,
    int? time,
    int? diff,
    bool? newRecord,
  }) {
    return DriverStandingItem(
      name ?? this.name,
      id ?? this.id,
      tries ?? this.tries,
      time ?? this.time,
      change: change ?? this.change,
      diff: diff ?? this.diff,
      newRecord: newRecord ?? this.newRecord,
    );
  }
}

enum PlaceChange { up, down, none }
