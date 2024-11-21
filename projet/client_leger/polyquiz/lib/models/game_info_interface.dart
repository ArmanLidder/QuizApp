class GameInfo {
  final String gameName;
  final String startTime;
  final int playersCount;
  final int bestScore;

  GameInfo({
    required this.gameName,
    required this.startTime,
    required this.playersCount,
    required this.bestScore,
  });
}

class GameConfig {
  final String? hostUserId;
  final String? gameType;
  final bool? private;
  final String? onGoing;
  final int? price;
  final bool? friendsOnly;
  final int? prestige;
  final bool? IA;

  GameConfig({
    this.hostUserId,
    this.gameType,
    this.private,
    this.onGoing,
    this.price,
    this.friendsOnly,
    this.prestige,
    this.IA,
  });

  Map<String, dynamic> toJson() {
    return {
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
