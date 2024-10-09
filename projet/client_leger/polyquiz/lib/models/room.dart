import 'player.dart';

class Room {
  final String id;
  final String code;
  final List<Player> players;

  Room({required this.id, required this.code, required this.players});

  factory Room.fromJson(Map<String, dynamic> json) {
    var playersList = json['players'] as List;
    List<Player> players = playersList.map((p) => Player.fromJson(p)).toList();

    return Room(
      id: json['_id'],
      code: json['code'],
      players: players,
    );
  }
}