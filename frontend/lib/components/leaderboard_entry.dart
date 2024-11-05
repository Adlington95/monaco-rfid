import 'package:flutter/material.dart';
import 'package:flutterfrontend/models/constructor_standing_item.dart';
import 'package:flutterfrontend/models/driver_standing_item.dart';
import 'package:zeta_flutter/zeta_flutter.dart';

class LeaderboardEntry extends StatelessWidget {
  const LeaderboardEntry({
    super.key,
    this.driver,
    this.index,
    this.isDriverHeader = false,
    this.constructor,
  });

  final DriverStandingItem? driver;
  final ConstructorStandingItem? constructor;
  final bool isDriverHeader;
  final int? index;

  @override
  Widget build(BuildContext context) {
    final String? name = driver?.name ?? constructor?.name;
    final PlaceChange? change = driver?.change ?? constructor?.change;
    final Color numberColor = constructor != null ? constructor!.color.darken(10) : Zeta.of(context).colors.textDefault;
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            height: 30,
            width: 40,
            decoration: index == null
                ? null
                : BoxDecoration(
                    color: numberColor,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
                  ),
            child: Center(
                child: index != null
                    ? Text(
                        index.toString(),
                        style: TextStyle(color: numberColor.onColor),
                      )
                    : const Nothing()),
          ),
          Flexible(
            flex: 3,
            child: Container(
              height: 30,
              decoration: name == null
                  ? null
                  : BoxDecoration(
                      color: Zeta.of(context).colors.textSubtle.withOpacity(0.5),
                      borderRadius:
                          const BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
                    ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (name != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(name),
                    ),
                ],
              ),
            ),
          ),
          Flexible(
            flex: 2,
            child: Row(
              children: [
                const SizedBox(width: 2),
                SizedBox(
                  width: 20,
                  child: change != null && change != PlaceChange.none
                      ? Container(
                          margin: EdgeInsets.only(left: change == PlaceChange.up ? 27 : 0),
                          child: RotatedBox(
                            quarterTurns: change == PlaceChange.up ? 1 : 3,
                            child: Icon(
                              ZetaIcons.chevron_left,
                              color: change == PlaceChange.up ? Colors.green : Colors.red,
                              size: 28,
                            ),
                          ),
                        )
                      : const Nothing(),
                ),
                SizedBox(width: 80, child: driver != null ? Center(child: Text(driver!.diff)) : const Nothing()),
                // if (constructor != null)
                SizedBox(
                  width: 60,
                  child: Center(
                    child: isDriverHeader
                        ? const Text('Tries')
                        : driver != null
                            ? Text(driver!.tries.toString())
                            : const Nothing(),
                  ),
                ),
              ].gap(16),
            ),
          )
        ],
      ),
    );
  }
}
