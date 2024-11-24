import 'package:flutter/material.dart';
import 'package:polyquiz/constants/player_status.dart';
import 'package:polyquiz/services/interactive_list_service.dart';
import 'package:polyquiz/services/theme_service.dart';
import 'package:polyquiz/services/translationService.dart';
import 'package:polyquiz/services/waiting_room_service.dart';
import 'package:polyquiz/widgets/user_widget/smartAvatar.dart';

class PlayersDataTable extends StatefulWidget {
  final bool isHost;

  const PlayersDataTable({super.key, required this.isHost});

  @override
  State<PlayersDataTable> createState() => _PlayersDataTableState();
}

class _PlayersDataTableState extends State<PlayersDataTable> {
  int? columnIndex;
  bool isAscending = true;
  TextStyle _textStyle = TextStyle(fontSize: 16);
  final List<String> statusOrder = [
    PlayerStatus.NO_INTERACTION,
    PlayerStatus.INTERACTION,
    PlayerStatus.VALIDATION,
    PlayerStatus.LEFT,
    PlayerStatus.END_GAME,
  ];
  int currentColumnSort = 0;
  InteractiveListService _interactiveListService = InteractiveListService();
  WaitingRoomService _waitingRoomService = WaitingRoomService();
  ThemeService _themeService = ThemeService.instance;

  void onSort(int columnIndex, bool isAscending) {
    if (columnIndex == 0) {
      _interactiveListService.players.sort((player1, player2) {
        return isAscending
            ? player1.username.compareTo(player2.username)
            : player2.username.compareTo(player1.username);
      });
    } else if (columnIndex == 1) {
      _interactiveListService.players.sort((player1, player2) {
        return isAscending
            ? player1.score.compareTo(player2.score)
            : player2.score.compareTo(player1.score);
      });
    } else if (columnIndex == 2) {
      _interactiveListService.players.sort((player1, player2) {
        final index1 = statusOrder.indexOf(player1.status);
        final index2 = statusOrder.indexOf(player2.status);

        return isAscending
            ? index1.compareTo(index2)
            : index2.compareTo(index1);
      });
    }
    setState(() {
      this.columnIndex = columnIndex;
      this.isAscending = isAscending;
    });
  }

  void sortByName() {
    setState(() {
      currentColumnSort = 0;
      onSort(0, isAscending);
    });
  }

  void sortByPoints() {
    setState(() {
      currentColumnSort = 1;
      onSort(1, isAscending);
    });
  }

  void sortByStatus() {
    setState(() {
      currentColumnSort = 2;
      onSort(2, isAscending);
    });
  }

  void changeAscending() {
    setState(() {
      isAscending = !isAscending;
      onSort(currentColumnSort, isAscending);
    });
  }

  Color getColor(Player player) {
    switch (player.status) {
      case PlayerStatus.NO_INTERACTION:
        return Color.fromRGBO(246, 53, 53, 1);
      case PlayerStatus.INTERACTION:
        return Color.fromRGBO(255, 226, 108, 1);
      case PlayerStatus.VALIDATION:
        return Color.fromRGBO(123, 229, 117, 1);
      case PlayerStatus.LEFT:
        return Color.fromRGBO(26, 26, 26, 1);
      case PlayerStatus.END_GAME:
        return Color.fromRGBO(221, 221, 221, 1);
      default:
        return const Color.fromRGBO(187, 222, 251, 1);
    }
  }

  String findTeam(String userId) {
    String result = "Quitté";
    for (var teamId in _waitingRoomService.teams.keys) {
      List<String> team = _waitingRoomService.teams[teamId]!;
      if (team.contains(userId)) {
        result = teamId.toString();
        break;
      }
    }

    return result;
  }

  Map get gameText => TranslationService.instance.text['GAME_INTERFACE'];
  Map get columnText => gameText['PLAYER_LIST']['COLUMN_TITLES'];
  Map get sortText => gameText['PLAYER_LIST']['SORT_BUTTONS'];

  @override
  Widget build(BuildContext context) {
    List<DataColumn> columns = [
      DataColumn(
        label: Expanded(child: Center(child: Text(columnText['NAME']))),
      ),
      DataColumn(
        label: Expanded(child: Center(child: Text(columnText['POINTS']))),
      ),
      DataColumn(
          label: Expanded(child: Center(child: Text(columnText['BONUS'])))),
    ];

    if (_waitingRoomService.gameType == 'equipe') {
      columns.add(DataColumn(
          label: Expanded(child: Center(child: Text(columnText['TEAM'])))));
    }
    return Container(
      width: 650.0,
      child: AnimatedBuilder(
          animation: _interactiveListService,
          builder: (BuildContext context, Widget? snapshot) {
            return Column(
              children: [
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor:
                              _themeService.secondaryBackground.value),
                      onPressed: sortByName,
                      child: Text(sortText['SORT_BY_NAME'],
                          style: TextStyle(
                              color: _themeService.secondaryAccent.value,
                              fontWeight: FontWeight.normal)),
                    ),
                    SizedBox(width: 10),
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor:
                              _themeService.secondaryBackground.value),
                      onPressed: sortByPoints,
                      child: Text(sortText['SORT_BY_SCORE'],
                          style: TextStyle(
                              color: _themeService.secondaryAccent.value,
                              fontWeight: FontWeight.normal)),
                    ),
                    SizedBox(width: 10),
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor:
                              _themeService.secondaryBackground.value),
                      onPressed: sortByStatus,
                      child: Text(sortText['SORT_BY_STATUS'],
                          style: TextStyle(
                              color: _themeService.secondaryAccent.value,
                              fontWeight: FontWeight.normal)),
                    ),
                    SizedBox(width: 10),
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor:
                              _themeService.secondaryBackground.value),
                      onPressed: changeAscending,
                      child: Icon(
                        isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                        color: _themeService.secondaryAccent.value,
                      ),
                    ),
                  ],
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                        _themeService.secondaryBackground.value),
                    headingTextStyle: TextStyle(
                        color: _themeService.secondaryAccent.value,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                    border: TableBorder.all(),
                    sortColumnIndex: columnIndex,
                    sortAscending: isAscending,
                    columns: columns,
                    rows: _interactiveListService.players.map((player) {
                      TextStyle playerTextStyle = _textStyle;
                      Color rowColor = getColor(player);

                      if (player.status == PlayerStatus.LEFT) {
                        playerTextStyle = TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: Colors.white,
                            decorationThickness: 2);
                      }
                      List<DataCell> cells = [
                        DataCell(Center(
                          child: SmartAvatar(
                            userId: player.username,
                            hasName: true,
                            interactible: true,
                            applyTheme: false,
                          ),
                        )),
                        DataCell(Center(
                          child: Text(player.score.toString(),
                              style: playerTextStyle),
                        )),
                        DataCell(Center(
                            child: Text(player.bonus.toString(),
                                style: playerTextStyle))),
                      ];
                      if (_waitingRoomService.gameType == 'equipe') {
                        cells.add(DataCell(Center(
                          child: Text(findTeam(player.username)),
                        )));
                      }
                      return DataRow(
                          color: WidgetStatePropertyAll(rowColor),
                          cells: cells);
                    }).toList(),
                  ),
                ),
              ],
            );
          }),
    );
  }
}

// class Player {
//   final String username;
//   final int score;
//   final int bonus;
//   String status;
//   bool canChat;

//   Player({
//     required this.username,
//     required this.score,
//     required this.bonus,
//     required this.status,
//     required this.canChat,
//   });
// }