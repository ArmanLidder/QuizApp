import 'package:flutter/material.dart';
import 'package:polyquiz/classes/player.dart';

class PlayersDataTable extends StatefulWidget {
  const PlayersDataTable({super.key});

  @override
  State<PlayersDataTable> createState() => _PlayersDataTableState();
}

class _PlayersDataTableState extends State<PlayersDataTable> {
  int? columnIndex;
  bool isAscending = true;

  void onSort(int columnIndex, bool isAscending) {
    if (columnIndex == 0) {
      players.sort((player1, player2) {
        return isAscending
            ? player1.name.compareTo(player2.name)
            : player2.name.compareTo(player1.name);
      });
    } else if (columnIndex == 1) {
      players.sort((player1, player2) {
        return isAscending
            ? player1.points.compareTo(player2.points)
            : player2.points.compareTo(player1.points);
      });
    } else if (columnIndex == 3) {
      players.sort((player1, player2) {
        return isAscending
            ? player1.canChat
                ? -1
                : 1
            : player1.canChat
                ? 1
                : -1;
      });
    }
    setState(() {
      this.columnIndex = columnIndex;
      this.isAscending = isAscending;
    });
  }

  List<Player> players = [
    Player(name: 'Player1', points: 50, bonus: 0, canChat: true),
    Player(name: 'Player2', points: 150, bonus: 50, canChat: true),
    Player(name: 'Player3', points: 100, bonus: 0, canChat: true)
  ];

  @override
  Widget build(BuildContext context) {
    List<DataColumn> columns = [
      DataColumn(
        onSort: (columnIndex, isAscending) => onSort(columnIndex, isAscending),
        label: Expanded(child: Center(child: Text('Nom'))),
      ),
      DataColumn(
        onSort: (columnIndex, isAscending) => onSort(columnIndex, isAscending),
        label: Expanded(child: Center(child: Text('Points'))),
      ),
      DataColumn(label: Expanded(child: Center(child: Text('Bonus')))),
      DataColumn(
        onSort: (columnIndex, isAscending) => onSort(columnIndex, isAscending),
        label: Expanded(child: Center(child: Text('Chat'))),
      ),
    ];
    return Container(
      width: 650.0,
      child: DataTable(
        headingRowColor:
            WidgetStateProperty.all(Color.fromRGBO(53, 121, 246, 1)),
        headingTextStyle: TextStyle(
            color: Color.fromRGBO(255, 255, 255, 1),
            fontWeight: FontWeight.bold),
        border: TableBorder.all(),
        sortColumnIndex: columnIndex,
        sortAscending: isAscending,
        columns: columns,
        rows: players.map((player) {
          return DataRow(cells: [
            DataCell(Center(child: Text(player.name))),
            DataCell(Center(child: Text(player.points.toString()))),
            DataCell(Center(child: Text(player.bonus.toString()))),
            DataCell(Center(
                child: Switch(
                    value: player.canChat,
                    activeTrackColor: Color.fromRGBO(53, 121, 246, 1),
                    onChanged: (value) {
                      setState(() {
                        player.canChat = value;
                      });
                    })))
          ]);
        }).toList(),
      ),
    );
  }
}
