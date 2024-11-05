import 'package:flutter/material.dart';
import 'package:flutterfrontend/models/driver_standing_item.dart';

class ConstructorStandingItem {
  final String name;
  final PlaceChange change;
  final bool isNew;
  final Color color;

  ConstructorStandingItem(this.name, this.change, this.isNew, {this.color = Colors.black});
}
