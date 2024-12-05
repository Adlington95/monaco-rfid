import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/components/card.dart';
import 'package:frontend/components/formatted_duration.dart';
import 'package:frontend/components/leaderboard_row.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/state/game_state.dart';
import 'package:frontend/state/rest_state.dart';
import 'package:provider/provider.dart';
import 'package:zeta_flutter/zeta_flutter.dart';

enum LapType { lap, overall }

extension on PlaceChange {
  Color get color => this == PlaceChange.up
      ? Colors.green
      : this == PlaceChange.down
          ? Colors.red
          : Colors.black;
}

extension on LapType {
  Color get color => this == LapType.lap ? Colors.purple : Colors.white;
}

class Leaderboard extends StatefulWidget {
  const Leaderboard({super.key, this.lapType = LapType.overall});
  final LapType lapType;

  @override
  State<Leaderboard> createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  final ScrollController _scrollController = ScrollController();

  bool showGap = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => scroll());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> scroll({bool down = true}) async {
    await Future<void>.delayed(const Duration(seconds: 5));
    if (mounted) {
      await _scrollController.animateTo(
        down ? _scrollController.position.maxScrollExtent : 0,
        duration: context.read<RestState>().lapLeaderboard != null
            ? Duration(seconds: context.read<RestState>().lapLeaderboard!.length - 8)
            : Duration.zero,
        curve: Curves.linear,
      );
    }
    unawaited(scroll(down: !down));
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w600,
      fontFamily: 'Titillium',
      color: Colors.white,
    );

    return Hero(
      tag: widget.lapType.name,
      child: Consumer<RestState>(
        builder: (context, state, child) {
          final fastestLap = state.lapLeaderboard == null || state.lapLeaderboard!.isEmpty
              ? 0
              : state.lapLeaderboard!.first.previousFastestLap;

          return TranslucentCard(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.lapType == LapType.overall ? 'Driver Standings' : 'Fastest Lap',
                        style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w400, color: Colors.white),
                      ),
                      Row(
                        children: [
                          if (widget.lapType == LapType.overall)
                            SizedBox(
                              width: 80,
                              child: Center(
                                child: Text(
                                  'TRIES',
                                  style: textStyle.apply(fontStyle: FontStyle.italic, color: Colors.white),
                                ),
                              ),
                            ),
                          SizedBox(
                            width: 100,
                            child: Center(
                              child: Text(
                                'TIME',
                                style: textStyle.apply(fontStyle: FontStyle.italic, color: Colors.white),
                              ),
                            ),
                          ),
                        ].gap(24),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.lapType == LapType.overall
                          ? state.overallLeaderboard?.length
                          : state.lapLeaderboard?.length,
                      shrinkWrap: true,
                      controller: _scrollController,
                      itemBuilder: (context, index) {
                        final element = widget.lapType == LapType.overall
                            ? state.overallLeaderboard![index]
                            : state.lapLeaderboard![index];

                        var dataToShow = widget.lapType == LapType.overall
                            ? element.previousBestOverall
                            : element.previousFastestLap;

                        final isCurrentUser = element.employeeId == context.read<GameState>().loggedInUser?.employeeId;

                        if (showGap && dataToShow != null && fastestLap != null && index != 0) {
                          dataToShow -= fastestLap;
                        }

                        final highlightColor = isCurrentUser
                            ? (element.change ?? PlaceChange.none).color
                            : index == 0
                                ? widget.lapType.color
                                : null;
                        return Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => showGap = !showGap),
                                onLongPress: () {
                                  showZetaDialog(
                                    context,
                                    message: 'Delete user?',
                                    primaryButtonLabel: 'Confirm',
                                    secondaryButtonLabel: 'Cancel',
                                    onPrimaryButtonPressed: () async {
                                      await context.read<RestState>().removeUser(element.employeeId);
                                      if (context.mounted) Navigator.of(context).pop();
                                    },
                                    onSecondaryButtonPressed: () => Navigator.of(context).pop(),
                                  );
                                },
                                child: LeaderboardRow(
                                  index: index + 1,
                                  highlightColor: highlightColor,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: FittedBox(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            element.name.trim().toUpperCase(),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                      ),
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
                                                      color: element.change?.color,
                                                    ),
                                                  )
                                                : const Nothing(),
                                          ),
                                          if (widget.lapType == LapType.overall)
                                            SizedBox(
                                              width: 80,
                                              child: Center(
                                                child: Text(
                                                  '${element.previousAttempts}',
                                                  style: textStyle.copyWith(
                                                    color: highlightColor?.onColor,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          SizedBox(
                                            width: 120,
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: dataToShow != null && (index == 0 || !showGap)
                                                  ? FormattedDuration(
                                                      Duration(milliseconds: dataToShow),
                                                      style: textStyle.copyWith(
                                                        color: highlightColor?.onColor,
                                                      ),
                                                    )
                                                  : dataToShow != null && index != 0
                                                      ? FormattedGap(
                                                          Duration(milliseconds: dataToShow),
                                                          style: textStyle.copyWith(
                                                            color: highlightColor?.onColor,
                                                          ),
                                                        )
                                                      : const Nothing(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ].gap(2),
                        ).paddingBottom(8);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
