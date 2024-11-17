class GameConfig {
  final String? hostUserId;
  final String? gameType;
  final bool? private;
  final String? onGoing;
  final int? price;
  final bool? friendsOnly;

  GameConfig(this.hostUserId, this.gameType, this.private, this.onGoing,
      this.price, this.friendsOnly);
}
