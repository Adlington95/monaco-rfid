import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/components/card.dart';
import 'package:frontend/components/formatted_duration.dart';
import 'package:frontend/components/leaderboard_row.dart';
import 'package:frontend/models/driver_standing_item.dart';
import 'package:frontend/state/rest_state.dart';
import 'package:provider/provider.dart';
import 'package:zeta_flutter/zeta_flutter.dart';

class Leaderboard extends StatefulWidget {
  const Leaderboard({super.key});

  @override
  State<Leaderboard> createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w600,
      fontFamily: 'Titillium',
      color: Colors.white,
    );
    return const Hero(
      tag: 'leaderboard',
      key: ValueKey('leaderboard'),
      child: NewWidget(textStyle: textStyle),
    );
  }
}

class NewWidget extends StatefulWidget {
  const NewWidget({
    super.key,
    required this.textStyle,
  });

  final TextStyle textStyle;

  @override
  State<NewWidget> createState() => _NewWidgetState();
}

class _NewWidgetState extends State<NewWidget> {
  final ScrollController _scrollController = ScrollController();
  late final int length;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      length = Provider.of<RestState>(context, listen: false).driverStandings.length;

      scroll();
    });
  }

  Future<void> scroll({bool down = true}) async {
    await Future<void>.delayed(const Duration(seconds: 5));
    await _scrollController.animateTo(
      down ? _scrollController.position.maxScrollExtent : 0,
      duration: Duration(seconds: length * 2),
      curve: Curves.linear,
    );
    unawaited(scroll(down: !down));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RestState>(
      builder: (context, state, child) {
        final fastestLap = state.driverStandings.isEmpty ? 0 : state.driverStandings.first.time;

        return TranslucentCard(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Driver Standings',
                      style: TextStyle(fontSize: 42, fontWeight: FontWeight.w400, color: Colors.white),
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 80,
                          child: Center(
                            child: Text(
                              'TRIES',
                              style: widget.textStyle.apply(fontStyle: FontStyle.italic, color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 160,
                          child: Center(
                            child: Text(
                              'TIME',
                              style: widget.textStyle.apply(fontStyle: FontStyle.italic, color: Colors.white),
                            ),
                          ),
                        ),
                      ].gap(24),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.driverStandings.length,
                    shrinkWrap: true,
                    controller: _scrollController,
                    itemBuilder: (context, index) {
                      final element = state.driverStandings[index];
                      return Row(
                        children: [
                          Expanded(
                            child: LeaderboardRow(
                              index: index + 1,
                              highlighted: index == 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(element.name),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 40,
                                        child: element.change != null && element.change != PlaceChange.none
                                            ? RotatedBox(
                                                quarterTurns: element.change == PlaceChange.up ? 3 : 1,
                                                child: Icon(
                                                  ZetaIcons.chevron_right,
                                                  size: 38,
                                                  color: element.change == PlaceChange.up ? Colors.green : Colors.red,
                                                ),
                                              )
                                            : const Nothing(),
                                      ),
                                      SizedBox(
                                        width: 80,
                                        child: Center(
                                          child: Text(
                                            '${element.tries}',
                                            style: widget.textStyle.copyWith(
                                              color: index == 0 ? Zeta.of(context).colors.textDefault : null,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 160,
                                        child: Center(
                                          child: (index == 0)
                                              ? FormattedDuration(
                                                  Duration(milliseconds: fastestLap),
                                                  style: widget.textStyle.copyWith(
                                                    color: index == 0 ? Zeta.of(context).colors.textDefault : null,
                                                  ),
                                                )
                                              : FormattedGap(
                                                  Duration(milliseconds: element.time - fastestLap),
                                                  style: widget.textStyle.copyWith(
                                                    color: index == 0 ? Zeta.of(context).colors.textDefault : null,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ].gap(24),
                      ).paddingBottom(8);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
