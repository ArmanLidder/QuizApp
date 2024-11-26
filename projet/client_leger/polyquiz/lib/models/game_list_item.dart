class GameListItem {
  final int room;
  final String quizId;
  final int numberOfPlayers;
  final String hostUserId;
  final String gameType;
  final bool private;
  final bool onGoing;
  final double price;
  final bool friendsOnly;
  final int prestige;
  int numberOfObs = 0;

  GameListItem(
      {required this.room,
      required this.quizId,
      required this.numberOfPlayers,
      required this.hostUserId,
      required this.gameType,
      required this.private,
      required this.onGoing,
      required this.price,
      required this.friendsOnly,
      required this.prestige,
      required this.numberOfObs});

  factory GameListItem.fromJson(Map<String, dynamic> json) {
    return GameListItem(
        room: json['room'],
        quizId: json['quizId'],
        numberOfPlayers: json['numberOfPlayers'],
        hostUserId: json['hostUserId'],
        gameType: json['gameType'],
        private: json['private'],
        onGoing: json['onGoing'],
        price: json['price'].toDouble(),
        friendsOnly: json['friendsOnly'],
        prestige: json['prestige'],
        numberOfObs: json['numberOfObs']);
  }

  Map<String, dynamic> toJson() {
    return {
      'room': room,
      'quizId': quizId,
      'numberOfPlayers': numberOfPlayers,
      'hostUserId': hostUserId,
      'gameType': gameType,
      'private': private,
      'onGoing': onGoing,
      'price': price,
      'friendsOnly': friendsOnly,
      'prestige': prestige,
    };
  }
}
