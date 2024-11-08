import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutterfrontend/components/card.dart';
import 'package:flutterfrontend/components/formatted_duration.dart';
import 'package:flutterfrontend/components/lap_counter.dart';
import 'package:flutterfrontend/models/driver_standing_item.dart';
import 'package:flutterfrontend/state/rest_state.dart';
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
        return TranslucentCard(
          child: Container(
            padding: const EdgeInsets.all(24),
            height: 650,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Driver Standings', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w400)),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text('TRIES', style: widget.textStyle.apply(fontStyle: FontStyle.italic)),
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
                          Expanded(child: MyListIem(index: index + 1, child: Text(element.name))),
                          SizedBox(
                            width: 40,
                            child: element.change != null && element.change != PlaceChange.none
                                ? RotatedBox(
                                    quarterTurns: index == 1 ? 3 : 1,
                                    child: const Icon(ZetaIcons.chevron_left, size: 38),
                                  )
                                : const Nothing(),
                          ),
                          FormattedDuration(Duration(milliseconds: element.time), style: widget.textStyle),
                          SizedBox(width: 80, child: Text('${element.tries}', style: widget.textStyle)),
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
