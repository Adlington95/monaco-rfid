class DriverStandingItem {
  final String name;
  final int tries;
  final String diff;
  final PlaceChange change;
  final bool isNew;

  const DriverStandingItem(this.name, this.tries, this.diff, this.change, this.isNew);
}

enum PlaceChange { up, down, none }
